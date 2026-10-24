import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/app_error.dart';

/// Credentials only. Tokens are never written to preferences, the database, or
/// a log line.
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _prefix = 'aria.token.';

  final FlutterSecureStorage _storage;

  Future<String?> readToken(String profileId) async {
    try {
      return await _storage.read(key: '$_prefix$profileId');
    } on Object catch (failure) {
      throw StorageFailure('secure storage read failed: $failure');
    }
  }

  Future<void> writeToken(String profileId, String token) async {
    try {
      await _storage.write(key: '$_prefix$profileId', value: token);
    } on Object catch (failure) {
      throw StorageFailure('secure storage write failed: $failure');
    }
  }

  Future<void> deleteToken(String profileId) async {
    try {
      await _storage.delete(key: '$_prefix$profileId');
    } on Object catch (failure) {
      throw StorageFailure('secure storage delete failed: $failure');
    }
  }
}
