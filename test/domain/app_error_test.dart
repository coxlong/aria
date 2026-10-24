import 'package:acp/acp.dart';
import 'package:aria/core/error/app_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a closed transport is a network failure', () {
    final error = AppError.from(const AcpTransportClosed('socket gone'));
    expect(error, isA<NetworkUnavailable>());
    expect(error.technicalDetail, contains('socket gone'));
  });

  test('a remote error keeps its code', () {
    final error = AppError.from(const AcpRemoteError(401, 'unauthorized'));
    expect(error, isA<RemoteRejected>());
    expect((error as RemoteRejected).code, 401);
  });

  test('a malformed frame is a protocol mismatch', () {
    final error = AppError.from(const AcpProtocolError('bad frame'));
    expect(error, isA<ProtocolMismatch>());
  });

  test('an unknown failure still carries its detail', () {
    final error = AppError.from(ArgumentError('oops'));
    expect(error, isA<UnknownFailure>());
    expect(error.technicalDetail, contains('oops'));
  });

  test('an AppError passes through unchanged', () {
    const original = StorageFailure('disk full');
    expect(AppError.from(original), same(original));
  });
}
