import 'dart:async';
import 'dart:convert';

import 'package:acp/acp.dart';

/// In-memory transport for deterministic protocol tests.
final class FakeTransport implements AcpTransport {
  final StreamController<String> _frames = StreamController<String>(sync: true);
  final StreamController<AcpTransportState> _states =
      StreamController<AcpTransportState>.broadcast(sync: true);

  /// Every frame passed to [send], as raw JSON lines.
  final List<String> sent = <String>[];

  AcpTransportState _state = AcpTransportState.connected;
  String? _clientId;

  @override
  Stream<String> get frames => _frames.stream;

  @override
  Stream<AcpTransportState> get states => _states.stream;

  @override
  AcpTransportState get state => _state;

  @override
  String? get clientId => _clientId;

  @override
  Future<void> send(String line) async => sent.add(line);

  @override
  Future<void> close() async {
    _state = AcpTransportState.closed;
    _states.add(_state);
    await _frames.close();
  }

  /// Feeds one JSON-RPC message.
  void emit(Map<String, Object?> frame) => _frames.add(jsonEncode(frame));

  /// Feeds a raw line (for malformed-frame cases).
  void emitRaw(String line) => _frames.add(line);

  /// Feeds a stream error.
  void emitError(Object error) => _frames.addError(error);

  /// Closes the frames stream without marking the transport closed, simulating
  /// an external transport teardown.
  Future<void> closeFrames() => _frames.close();

  /// Last frame sent by the client, decoded.
  Map<String, Object?> get lastSent =>
      jsonDecode(sent.last) as Map<String, Object?>;
}
