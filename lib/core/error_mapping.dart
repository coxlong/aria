import 'dart:async';
import 'dart:io';

import 'package:acp/acp.dart';

/// Coarse error categories the UI can localize.
enum AriaErrorKind {
  network,
  auth,
  protocol,
  timeout,
  sessionLost,
  agent,
  unknown,
}

/// A protocol error mapped to something the UI can explain.
final class AriaError {
  final AriaErrorKind kind;
  final int? code;
  final Object cause;

  const AriaError(this.kind, this.cause, {this.code});

  String get technicalMessage => cause.toString();
}

AriaError mapAriaError(Object error) {
  if (error is AcpRemoteError) {
    final message = error.remoteMessage.toLowerCase();
    final isSessionLost =
        message.contains('session') &&
        (message.contains('not found') ||
            message.contains('unknown') ||
            message.contains('no such') ||
            message.contains('expired'));
    if (isSessionLost) {
      return AriaError(AriaErrorKind.sessionLost, error, code: error.code);
    }
    if (error.code == JsonRpcCode.serverError ||
        message.contains('auth') ||
        message.contains('token')) {
      return AriaError(AriaErrorKind.auth, error, code: error.code);
    }
    return AriaError(AriaErrorKind.agent, error, code: error.code);
  }
  if (error is AcpRequestTimeout || error is TimeoutException) {
    return AriaError(AriaErrorKind.timeout, error);
  }
  if (error is AcpProtocolError) {
    return AriaError(AriaErrorKind.protocol, error);
  }
  if (error is AcpTransportClosed ||
      error is SocketException ||
      error is WebSocketException ||
      error is HttpException) {
    return AriaError(AriaErrorKind.network, error);
  }
  return AriaError(AriaErrorKind.unknown, error);
}
