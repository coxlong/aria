/// Error types raised by the ACP client.
///
/// Error messages are English and protocol-oriented. The application layer is
/// responsible for mapping these types to user-facing localized messages.
library;

/// Base class for every error raised by this package.
sealed class AcpError implements Exception {
  const AcpError();

  /// Short, English, protocol-level description.
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// The agent replied with a JSON-RPC error object.
final class AcpRemoteError extends AcpError {
  final int code;
  final String remoteMessage;
  final Object? data;

  const AcpRemoteError(this.code, this.remoteMessage, [this.data]);

  @override
  String get message => 'ACP error $code: $remoteMessage';
}

/// A request did not receive a response before its timeout.
final class AcpRequestTimeout extends AcpError {
  final String method;

  const AcpRequestTimeout(this.method);

  @override
  String get message => 'Request timed out: $method';
}

/// The transport closed (voluntarily or because reconnection was abandoned).
final class AcpTransportClosed extends AcpError {
  final String reason;

  const AcpTransportClosed(this.reason);

  @override
  String get message => 'Transport closed: $reason';
}

/// The peer sent a frame that does not match the ACP wire format.
final class AcpProtocolError extends AcpError {
  @override
  final String message;

  const AcpProtocolError(this.message);
}

/// JSON-RPC error codes used by the client.
abstract final class JsonRpcCode {
  static const int parseError = -32700;
  static const int invalidRequest = -32600;
  static const int methodNotFound = -32601;
  static const int invalidParams = -32602;
  static const int internalError = -32603;

  /// Authentication or session-level failure reported by the agent.
  static const int serverError = -32000;
}
