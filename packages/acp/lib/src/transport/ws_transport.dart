import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../protocol/errors.dart';
import '../protocol/methods.dart';
import 'acp_transport.dart';
import 'ndjson.dart';

/// Retry and buffering policy for [WsTransport].
final class ReconnectPolicy {
  /// Delay before the first retry.
  final Duration initialDelay;

  /// Upper bound for the exponential backoff.
  final Duration maxDelay;

  /// Backoff multiplier applied after every failed attempt.
  final double multiplier;

  /// Maximum frames kept while the socket is down. Oldest frames are dropped.
  final int maxOutboxFrames;

  const ReconnectPolicy({
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.multiplier = 2,
    this.maxOutboxFrames = 200,
  });

  Duration delayForAttempt(int attempt) {
    var delay = initialDelay.inMilliseconds * _pow(multiplier, attempt);
    final capped = delay.clamp(0, maxDelay.inMilliseconds).toInt();
    return Duration(milliseconds: capped);
  }

  static num _pow(double base, int exponent) {
    var value = 1.0;
    for (var i = 0; i < exponent; i++) {
      value *= base;
      if (value >= 1e9) break;
    }
    return value;
  }
}

/// WebSocket transport for ACP over `ws://` and `wss://`.
///
/// The transport is deliberately resilient:
/// - it speaks the `acp.v1` subprotocol and sends the bearer token on upgrade;
/// - it reuses the bridge-assigned client id via `X-Client-Id`;
/// - it sends `$/ping` every 25 seconds so idle links are not reaped;
/// - it reconnects with exponential backoff and keeps [frames] open, so the
///   protocol layer never observes a transient drop;
/// - it buffers outbound frames while the socket is down and flushes them in
///   order after reconnecting;
/// - it filters the bridge preambles (`connected` / `reconnect`).
final class WsTransport implements AcpTransport {
  static const String subprotocol = 'acp.v1';

  final Uri url;
  final String? token;
  final Duration connectTimeout;
  final Duration heartbeatInterval;
  final ReconnectPolicy policy;
  final void Function(String clientId)? onClientId;

  final Map<String, String> _extraHeaders;
  final StreamController<String> _frames = StreamController<String>(sync: true);
  final StreamController<AcpTransportState> _states =
      StreamController<AcpTransportState>.broadcast(sync: true);
  final NdjsonDecoder _decoder = NdjsonDecoder();
  final List<String> _outbox = <String>[];

  WebSocket? _socket;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  AcpTransportState _state = AcpTransportState.connecting;
  String? _clientId;
  bool _closedByOwner = false;
  bool _reconnecting = false;
  int _attempt = 0;

  WsTransport._({
    required this.url,
    this.token,
    required String? initialClientId,
    this.connectTimeout = const Duration(seconds: 15),
    this.heartbeatInterval = const Duration(seconds: 25),
    this.policy = const ReconnectPolicy(),
    this.onClientId,
    Map<String, String>? headers,
  }) : _clientId = initialClientId,
       _extraHeaders = headers ?? const <String, String>{};

  /// Opens the socket and returns a live transport.
  ///
  /// Throws when the first connection attempt fails. Later drops are handled
  /// internally and are not surfaced as errors.
  static Future<WsTransport> connect(
    Uri url, {
    String? token,
    String? initialClientId,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration heartbeatInterval = const Duration(seconds: 25),
    ReconnectPolicy policy = const ReconnectPolicy(),
    void Function(String clientId)? onClientId,
    Map<String, String>? headers,
  }) async {
    final transport = WsTransport._(
      url: url,
      token: token,
      initialClientId: initialClientId,
      connectTimeout: connectTimeout,
      heartbeatInterval: heartbeatInterval,
      policy: policy,
      onClientId: onClientId,
      headers: headers,
    );
    try {
      await transport._open(isReconnect: false);
    } catch (_) {
      await transport._disposeControllers();
      rethrow;
    }
    return transport;
  }

  @override
  Stream<String> get frames => _frames.stream;

  @override
  Stream<AcpTransportState> get states => _states.stream;

  @override
  AcpTransportState get state => _state;

  @override
  String? get clientId => _clientId;

  Future<void> _open({required bool isReconnect}) async {
    if (_closedByOwner) return;
    _setState(
      isReconnect
          ? AcpTransportState.reconnecting
          : AcpTransportState.connecting,
    );
    final socket =
        await WebSocket.connect(
          url.toString(),
          protocols: const <String>[subprotocol],
          headers: _headers(),
        ).timeout(
          connectTimeout,
          onTimeout: () {
            throw AcpProtocolError('WebSocket connection timed out: $url');
          },
        );

    if (_closedByOwner) {
      await socket.close();
      return;
    }

    _socket = socket;
    _decoder.reset();
    socket.listen(
      _onData,
      onDone: _onSocketClosed,
      onError: (Object _) => _onSocketClosed(),
      cancelOnError: false,
    );
    _startHeartbeat();
    _flushOutbox();
    _attempt = 0;
    _reconnecting = false;
    _setState(AcpTransportState.connected);
  }

  Map<String, String> _headers() {
    return <String, String>{
      ..._extraHeaders,
      if (token != null && token!.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $token',
      if (_clientId != null && _clientId!.isNotEmpty) 'X-Client-Id': _clientId!,
    };
  }

  void _onData(dynamic data) {
    final text = data is String ? data : utf8.decode(data as List<int>);
    final lines = <String>[
      ..._decoder.add(text),
      ..._decoder.flushIfComplete(),
    ];
    for (final line in lines) {
      if (_consumePreamble(line)) continue;
      if (!_frames.isClosed) _frames.add(line);
    }
  }

  /// Returns true when [line] is a bridge preamble that must not reach the
  /// protocol layer.
  bool _consumePreamble(String line) {
    final isConnected = line.startsWith('{"type":"connected"');
    final isReconnect = line.startsWith('{"type":"reconnect"');
    if (!isConnected && !isReconnect) return false;
    try {
      final Object? decoded = jsonDecode(line);
      if (decoded is Map<String, dynamic>) {
        final id = decoded['clientId'];
        if (id is String && id.isNotEmpty && id != _clientId) {
          _clientId = id;
          onClientId?.call(id);
        }
      }
    } on FormatException {
      // A malformed preamble is still not an ACP frame; drop it.
    }
    return true;
  }

  void _onSocketClosed() {
    _stopHeartbeat();
    _socket = null;
    if (_closedByOwner) return;
    _decoder.reset();
    _setState(AcpTransportState.reconnecting);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_closedByOwner || _reconnecting) return;
    _reconnecting = true;
    final delay = policy.delayForAttempt(_attempt);
    _attempt++;
    _reconnectTimer = Timer(delay, () async {
      if (_closedByOwner) return;
      try {
        await _open(isReconnect: true);
      } catch (_) {
        _reconnecting = false;
        _setState(AcpTransportState.reconnecting);
        _scheduleReconnect();
      }
    });
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      final socket = _socket;
      if (socket == null) return;
      try {
        socket.add(
          '${jsonEncode(<String, Object?>{'jsonrpc': '2.0', 'method': AcpMethods.ping})}\n',
        );
      } on Object {
        // The socket teardown path will schedule the reconnect.
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _flushOutbox() {
    final socket = _socket;
    if (socket == null || _outbox.isEmpty) return;
    final pending = List<String>.of(_outbox);
    _outbox.clear();
    for (final frame in pending) {
      socket.add(frame);
    }
  }

  void _setState(AcpTransportState next) {
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }

  @override
  Future<void> send(String line) async {
    final frame = line.endsWith('\n') ? line : '$line\n';
    final socket = _socket;
    if (socket != null) {
      try {
        socket.add(frame);
        return;
      } on Object {
        // Fall through to the outbox.
      }
    }
    _outbox.add(frame);
    if (_outbox.length > policy.maxOutboxFrames) {
      _outbox.removeAt(0);
    }
  }

  @override
  Future<void> close() async {
    if (_closedByOwner) return;
    _closedByOwner = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopHeartbeat();
    _outbox.clear();
    final socket = _socket;
    _socket = null;
    _setState(AcpTransportState.closed);
    await _disposeControllers();
    if (socket != null) {
      try {
        await socket.close();
      } on Object {
        // The socket is already gone; nothing left to release.
      }
    }
  }

  Future<void> _disposeControllers() async {
    // A single-subscription controller's done future never completes while
    // nobody listens, so closing it must not be awaited here.
    if (!_frames.isClosed) unawaited(_frames.close());
    if (!_states.isClosed) await _states.close();
  }
}
