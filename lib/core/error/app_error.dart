import 'package:acp/acp.dart';

/// A failure the interface can explain.
///
/// Transport-level exceptions stop at the data layer: the presentation layer
/// only ever sees one of these, and maps it to a localized sentence plus one
/// action. [technicalDetail] goes behind "Details".
sealed class AppError implements Exception {
  const AppError(this.technicalDetail);

  /// Raw message for the Details disclosure. Never shown by default.
  final String technicalDetail;

  /// Converts anything thrown by the transport or the protocol package.
  static AppError from(Object failure) => switch (failure) {
    AppError() => failure,
    AcpRemoteError(:final code, :final message) => RemoteRejected(
      code,
      message,
    ),
    AcpRequestTimeout() => const NetworkUnavailable(
      'The agent did not answer before the request timed out.',
    ),
    AcpTransportClosed(:final reason) => NetworkUnavailable(reason),
    AcpProtocolError(:final message) => ProtocolMismatch(message),
    StateError(:final message) => RemoteRejected(-32603, message),
    _ => UnknownFailure('$failure'),
  };
}

/// The agent cannot be reached.
final class NetworkUnavailable extends AppError {
  const NetworkUnavailable(super.technicalDetail);
}

/// The agent rejected the credential.
final class AuthenticationFailed extends AppError {
  const AuthenticationFailed(super.technicalDetail);
}

/// The peer does not speak ACP v1, or sent a frame we cannot parse.
final class ProtocolMismatch extends AppError {
  const ProtocolMismatch(super.technicalDetail);
}

/// The agent answered with a JSON-RPC error.
final class RemoteRejected extends AppError {
  const RemoteRejected(this.code, String message) : super(message);

  final int code;
}

/// The agent ended the turn without finishing it.
///
/// ACP reports these as a normal prompt result, so nothing was thrown — but
/// "the model hit its token limit" and "the agent stopped on an error" are not
/// the same thing as a finished answer, and the person has to be told.
final class ExecutionStopped extends AppError {
  const ExecutionStopped(this.reason) : super('stopReason: $reason');

  /// `error`, `refusal`, or `max_tokens`.
  final String reason;
}

/// Local persistence failed. Never a reason to lose the user's work.
final class StorageFailure extends AppError {
  const StorageFailure(super.technicalDetail);
}

/// A failure with no specific handling.
final class UnknownFailure extends AppError {
  const UnknownFailure(super.technicalDetail);
}
