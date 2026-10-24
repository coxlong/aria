import 'package:acp/acp.dart';
import 'package:aria/core/error_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapAriaError', () {
    test('maps transport failures to network', () {
      expect(
        mapAriaError(const AcpTransportClosed('boom')).kind,
        AriaErrorKind.network,
      );
    });

    test('maps timeouts', () {
      expect(
        mapAriaError(const AcpRequestTimeout('initialize')).kind,
        AriaErrorKind.timeout,
      );
    });

    test('maps protocol failures', () {
      expect(
        mapAriaError(const AcpProtocolError('bad frame')).kind,
        AriaErrorKind.protocol,
      );
    });

    test('maps an unknown agent method to an agent error', () {
      final error = mapAriaError(
        const AcpRemoteError(JsonRpcCode.methodNotFound, 'Method not found'),
      );

      expect(error.kind, AriaErrorKind.agent);
      expect(error.code, JsonRpcCode.methodNotFound);
    });

    test('detects a lost session', () {
      final error = mapAriaError(
        const AcpRemoteError(JsonRpcCode.serverError, 'session not found'),
      );

      expect(error.kind, AriaErrorKind.sessionLost);
    });

    test('detects an authentication failure', () {
      final error = mapAriaError(
        const AcpRemoteError(JsonRpcCode.serverError, 'invalid token'),
      );

      expect(error.kind, AriaErrorKind.auth);
    });

    test('falls back to unknown', () {
      expect(
        mapAriaError(const FormatException('x')).kind,
        AriaErrorKind.unknown,
      );
    });
  });
}
