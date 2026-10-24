import 'dart:async';

/// Lifecycle of the transport as seen by the UI.
enum AcpTransportState {
  /// The first connection attempt is in progress.
  connecting,

  /// The socket is open and frames can be delivered.
  connected,

  /// The socket dropped; the transport is retrying in the background.
  reconnecting,

  /// The transport is closed and will not reconnect.
  closed,
}

/// A bidirectional stream of complete JSON lines.
///
/// Implementations MUST keep [frames] open across transient socket drops when
/// they reconnect, so the protocol layer never observes the interruption.
abstract interface class AcpTransport {
  /// Complete JSON lines, without the trailing newline.
  Stream<String> get frames;

  /// Connection state changes for the UI.
  Stream<AcpTransportState> get states;

  /// Current state.
  AcpTransportState get state;

  /// Sends one JSON line. Implementations append framing as needed.
  Future<void> send(String line);

  /// Closes the transport permanently.
  Future<void> close();

  /// The bridge-assigned client id, when known.
  String? get clientId;
}
