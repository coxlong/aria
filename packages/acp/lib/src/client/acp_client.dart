import 'dart:async';
import 'dart:convert';

import '../models/config_surfaces.dart';
import '../models/content.dart';
import '../models/permission.dart';
import '../models/session.dart';
import '../models/session_update.dart';
import '../models/tool_call.dart';
import '../protocol/errors.dart';
import '../protocol/methods.dart';
import '../transport/acp_transport.dart';

part 'acp_session.dart';

/// Client side of an ACP connection.
///
/// The client owns JSON-RPC request correlation, the session registry and
/// agent-to-client request routing. It never knows how the transport
/// reconnects: a transient socket drop is invisible here.
final class AcpClient {
  /// Timeout applied to every request except `session/prompt`, which only
  /// resolves when the turn ends.
  final Duration requestTimeout;

  /// How long [AcpSession.cancel] waits for the agent to acknowledge the
  /// cancellation before completing the turn locally.
  final Duration cancelTimeout;

  final AcpTransport _transport;
  final Map<int, _PendingRequest> _pending = <int, _PendingRequest>{};
  final Map<String, AcpSession> _sessions = <String, AcpSession>{};
  final Map<String, List<PermissionRequest>> _permissionsBySession =
      <String, List<PermissionRequest>>{};
  final StreamController<PermissionRequest> _permissionRequests =
      StreamController<PermissionRequest>.broadcast(sync: true);

  StreamSubscription<String>? _frameSubscription;
  int _nextId = 1;
  bool _closing = false;

  AcpClient(
    this._transport, {
    this.requestTimeout = const Duration(seconds: 60),
    this.cancelTimeout = const Duration(seconds: 15),
  }) {
    _frameSubscription = _transport.frames.listen(
      _onFrame,
      onDone: _onTransportClosed,
      onError: (Object _) => _onTransportClosed(),
    );
  }

  /// Transport state changes, for the reconnect banner.
  Stream<AcpTransportState> get states => _transport.states;

  /// Current transport state.
  AcpTransportState get state => _transport.state;

  /// Bridge-assigned client id, when the bridge provides one.
  String? get clientId => _transport.clientId;

  /// Agent permission requests. The UI must answer each one.
  Stream<PermissionRequest> get permissionRequests =>
      _permissionRequests.stream;

  /// Performs the ACP handshake.
  Future<InitializeResult> initialize({ClientInfo? clientInfo}) async {
    final response = await _request(AcpMethods.initialize, <String, Object?>{
      'protocolVersion': 1,
      'clientCapabilities': <String, Object?>{
        'fs': <String, Object?>{'readTextFile': false, 'writeTextFile': false},
      },
      'clientInfo':
          (clientInfo ??
                  const ClientInfo(
                    name: 'aria',
                    title: 'Aria',
                    version: '1.0.0',
                  ))
              .toJson(),
    });
    return InitializeResult.fromJson(_result(response));
  }

  /// Authenticates with an advertised method id.
  Future<void> authenticate({required String methodId}) async {
    await _request(AcpMethods.authenticate, <String, Object?>{
      'methodId': methodId,
    });
  }

  /// Creates a new session and registers it.
  Future<AcpSession> newSession({required String cwd}) async {
    final response = await _request(AcpMethods.newSession, <String, Object?>{
      'cwd': cwd,
      'mcpServers': const <Object?>[],
    });
    final result = _result(response);
    final sessionId = result['sessionId'] as String? ?? '';
    if (sessionId.isEmpty) {
      throw const AcpProtocolError('session/new returned no sessionId');
    }
    final existing = _sessions.remove(sessionId);
    existing?._dispose();
    final session = AcpSession._(
      client: this,
      id: sessionId,
      cwd: cwd,
      initial: result,
    );
    _sessions[sessionId] = session;
    return session;
  }

  /// Loads a session. History is replayed through the returned session's
  /// [AcpSession.updates] stream before this future completes; updates are
  /// buffered until the caller subscribes.
  Future<AcpSession> loadSession({
    required String sessionId,
    required String cwd,
  }) async {
    final existing = _sessions.remove(sessionId);
    existing?._dispose();

    final session = AcpSession._(
      client: this,
      id: sessionId,
      cwd: cwd,
      initial: const <String, Object?>{},
    );
    _sessions[sessionId] = session;
    session._beginReplay();
    try {
      final response = await _request(AcpMethods.loadSession, <String, Object?>{
        'sessionId': sessionId,
        'cwd': cwd,
        'mcpServers': const <Object?>[],
      });
      session._applySessionResult(_result(response));
      return session;
    } on Object {
      _sessions.remove(sessionId);
      session._dispose();
      rethrow;
    } finally {
      session._endReplay();
    }
  }

  /// Lists sessions known to the agent.
  Future<List<SessionSummary>> listSessions({String? cwd}) async {
    final response = await _request(AcpMethods.listSessions, <String, Object?>{
      if (cwd != null && cwd.isNotEmpty) 'cwd': cwd,
    });
    final result = _result(response);
    final raw = result['sessions'];
    if (raw is! List) return const <SessionSummary>[];
    return raw
        .whereType<Map<String, Object?>>()
        .map(SessionSummary.fromJson)
        .toList(growable: false);
  }

  /// Deletes a session from the agent's history.
  ///
  /// Gated by `agentCapabilities.sessionCapabilities.delete`; agents without
  /// it may fail the request.
  Future<void> deleteSession(String sessionId) async {
    await _request(AcpMethods.deleteSession, <String, Object?>{
      'sessionId': sessionId,
    });
    _sessions.remove(sessionId)?._dispose();
    _permissionsBySession.remove(sessionId);
  }

  /// Drops a session the caller is no longer following, without deleting it.
  ///
  /// Local teardown is immediate — pending permissions are denied, an
  /// in-flight prompt settles, and the update stream closes — while the agent
  /// is told in the background. A client that switches sessions must call
  /// this: a session left registered keeps buffering every update for it,
  /// because its stream is single-subscription and nobody is listening.
  Future<void> releaseSession(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) return;
    await _answerPermissionsFor(sessionId);
    _forgetSession(session);
    session._dispose();
    unawaited(() async {
      try {
        await _notify(AcpMethods.closeSession, <String, Object?>{
          'sessionId': sessionId,
        });
      } on Object {
        // Best effort: the agent may already be gone.
      }
    }());
  }

  /// Returns the registered session with [sessionId], if any.
  AcpSession? session(String sessionId) => _sessions[sessionId];

  /// Closes the connection permanently.
  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    final error = const AcpTransportClosed('client closed');
    for (final pending in _pending.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(error);
      }
    }
    _pending.clear();
    for (final session in _sessions.values.toList(growable: false)) {
      session._dispose();
    }
    _sessions.clear();
    _permissionsBySession.clear();
    await _frameSubscription?.cancel();
    _frameSubscription = null;
    await _transport.close();
    if (!_permissionRequests.isClosed) await _permissionRequests.close();
  }

  // ── Inbound routing ─────────────────────────────────────────────────────

  void _onFrame(String line) {
    final Object? decoded;
    try {
      decoded = jsonDecode(line);
    } on FormatException {
      return; // Malformed frame: JSON-RPC allows no reply without an id.
    }
    if (decoded is! Map<String, Object?>) return;

    final rawId = decoded['id'];
    final method = decoded['method'];

    if (rawId != null && method is String) {
      _handleAgentRequest(rawId, method, decoded['params']);
      return;
    }
    if (rawId != null) {
      _handleResponse(rawId, decoded);
      return;
    }
    if (method == AcpMethods.sessionUpdate) {
      _handleSessionUpdate(decoded['params']);
    }
    // Other notifications (including $/ping echoes) are ignored.
  }

  void _handleResponse(Object rawId, Map<String, Object?> frame) {
    final id = _idOf(rawId);
    if (id == null) return;
    final pending = _pending.remove(id);
    if (pending == null) return;

    final error = frame['error'];
    if (error is Map<String, Object?>) {
      pending.completer.completeError(
        AcpRemoteError(
          (error['code'] as num?)?.toInt() ?? JsonRpcCode.internalError,
          error['message'] as String? ?? 'Unknown error',
          error['data'],
        ),
      );
      return;
    }
    pending.completer.complete(frame);
  }

  void _handleAgentRequest(Object rawId, String method, Object? rawParams) {
    final id = _idOf(rawId);
    if (id == null) return; // Cannot answer without a request id.
    final params = rawParams is Map<String, Object?>
        ? rawParams
        : const <String, Object?>{};

    switch (method) {
      case AcpMethods.requestPermission:
        _handlePermissionRequest(id, params);
      default:
        _send(<String, Object?>{
          'jsonrpc': '2.0',
          'id': id,
          'error': <String, Object?>{
            'code': JsonRpcCode.methodNotFound,
            'message': 'Method not found: $method',
          },
        });
    }
  }

  void _handlePermissionRequest(int requestId, Map<String, Object?> params) {
    final sessionId = params['sessionId'] as String? ?? '';
    final rawToolCall = params['toolCall'];
    final rawOptions = params['options'];

    late final PermissionRequest request;
    request = PermissionRequest(
      sessionId: sessionId,
      toolCall: ToolCallInfo.fromJson(
        rawToolCall is Map<String, Object?>
            ? rawToolCall
            : const <String, Object?>{},
      ),
      options: (rawOptions is List ? rawOptions : const <Object?>[])
          .whereType<Map<String, Object?>>()
          .map(PermissionOption.fromJson)
          .toList(growable: false),
      respond: (optionId) {
        _permissionsBySession[sessionId]?.remove(request);
        return _send(<String, Object?>{
          'jsonrpc': '2.0',
          'id': requestId,
          'result': <String, Object?>{
            'outcome': optionId == null
                ? <String, Object?>{'outcome': 'cancelled'}
                : <String, Object?>{
                    'outcome': 'selected',
                    'optionId': optionId,
                  },
          },
        });
      },
    );
    (_permissionsBySession[sessionId] ??= <PermissionRequest>[]).add(request);
    if (!_permissionRequests.isClosed) _permissionRequests.add(request);
  }

  void _handleSessionUpdate(Object? rawParams) {
    if (rawParams is! Map<String, Object?>) return;
    final sessionId = rawParams['sessionId'] as String? ?? '';
    final update = rawParams['update'];
    if (update is! Map<String, Object?>) return;
    final kind = update['sessionUpdate'] as String? ?? '';
    final parsed = _parseUpdate(sessionId, kind, update);
    _sessions[sessionId]?._emit(parsed);
  }

  static SessionUpdate _parseUpdate(
    String sessionId,
    String kind,
    Map<String, Object?> update,
  ) {
    switch (kind) {
      case SessionUpdateKind.userMessageChunk:
        return UserMessageChunk(sessionId, _textOf(update));
      case SessionUpdateKind.agentMessageChunk:
        return AgentMessageChunk(sessionId, _textOf(update));
      case SessionUpdateKind.agentThoughtChunk:
        return AgentThoughtChunk(sessionId, _textOf(update));
      case SessionUpdateKind.toolCall:
        final raw = update['toolCall'];
        return ToolCallStarted(
          sessionId,
          ToolCallInfo.fromJson(raw is Map<String, Object?> ? raw : update),
        );
      case SessionUpdateKind.toolCallUpdate:
        final rawContent = update['content'];
        final rawMeta = update['_meta'];
        return ToolCallPatched(
          sessionId,
          toolCallId: update['toolCallId'] as String? ?? '',
          title: update['title'] as String?,
          status: update['status'] as String?,
          rawInput: update['rawInput'],
          rawOutput: update['rawOutput'],
          content: rawContent is List
              ? rawContent.whereType<Map<String, Object?>>().toList(
                  growable: false,
                )
              : null,
          meta: rawMeta is Map<String, Object?> ? rawMeta : null,
        );
      case SessionUpdateKind.currentModeUpdate:
        return CurrentModeUpdate(
          sessionId,
          update['currentModeId'] as String? ?? '',
        );
      case SessionUpdateKind.configOptionUpdate:
        final raw = update['configOptions'];
        return ConfigOptionUpdate(
          sessionId,
          raw is List
              ? raw.whereType<Map<String, Object?>>().toList(growable: false)
              : const <Map<String, Object?>>[],
        );
      default:
        return UnknownSessionUpdate(sessionId, kind, update);
    }
  }

  static String _textOf(Map<String, Object?> update) {
    final content = update['content'];
    if (content is Map<String, Object?>) {
      return content['text'] as String? ?? '';
    }
    return '';
  }

  void _onTransportClosed() {
    if (_closing) return;
    final error = const AcpTransportClosed('frames stream ended');
    for (final pending in _pending.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(error);
      }
    }
    _pending.clear();
    for (final session in _sessions.values) {
      session._onTransportClosed();
    }
  }

  // ── Outbound plumbing (shared with AcpSession) ──────────────────────────

  Future<Map<String, Object?>> _request(
    String method,
    Map<String, Object?> params, {
    Duration? timeout,
    bool noTimeout = false,
    void Function(int requestId)? onId,
  }) {
    final id = _nextId++;
    final completer = Completer<Map<String, Object?>>();
    _pending[id] = _PendingRequest(completer, method);
    unawaited(
      _transport.send(
        jsonEncode(<String, Object?>{
          'jsonrpc': '2.0',
          'id': id,
          'method': method,
          'params': params,
        }),
      ),
    );
    onId?.call(id);

    final effective = noTimeout ? null : (timeout ?? requestTimeout);
    if (effective == null) return completer.future;
    return completer.future.timeout(
      effective,
      onTimeout: () {
        _pending.remove(id);
        throw AcpRequestTimeout(method);
      },
    );
  }

  Future<void> _notify(String method, Map<String, Object?> params) =>
      _transport.send(
        jsonEncode(<String, Object?>{
          'jsonrpc': '2.0',
          'method': method,
          'params': params,
        }),
      );

  Future<void> _send(Map<String, Object?> frame) =>
      _transport.send(jsonEncode(frame));

  /// Completes an in-flight request locally (used by the cancel watchdog).
  void _abandon(int requestId, String stopReason) {
    final pending = _pending.remove(requestId);
    if (pending == null || pending.completer.isCompleted) return;
    pending.completer.complete(<String, Object?>{
      'result': <String, Object?>{'stopReason': stopReason},
    });
  }

  /// Answers every unresolved permission request for [sessionId] as cancelled.
  Future<void> _answerPermissionsFor(String sessionId) async {
    final list = _permissionsBySession[sessionId];
    if (list == null) return;
    final pending = list.where((request) => !request.isAnswered).toList();
    for (final request in pending) {
      await request.deny();
    }
    list.removeWhere((request) => request.isAnswered);
    if (list.isEmpty) _permissionsBySession.remove(sessionId);
  }

  void _forgetSession(AcpSession session) {
    if (_sessions[session.id] != session) return;
    _sessions.remove(session.id);
    _permissionsBySession.remove(session.id);
  }

  static Map<String, Object?> _result(Map<String, Object?> response) {
    final result = response['result'];
    return result is Map<String, Object?> ? result : const <String, Object?>{};
  }

  static int? _idOf(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

final class _PendingRequest {
  final Completer<Map<String, Object?>> completer;
  final String method;

  _PendingRequest(this.completer, this.method);
}
