import '../../../core/storage/preferences.dart';
import '../../../core/storage/secure_store.dart';
import '../../../domain/profile/server_profile.dart';

/// Saved endpoints and their credentials.
///
/// Metadata is written to preferences; the token is written to secure storage
/// and only ever read back in memory.
final class ProfileRepository {
  ProfileRepository(this._preferences, this._secure);

  final AriaPreferences _preferences;
  final SecureStore _secure;

  List<ServerProfile> readAll() => _preferences.readProfiles();

  String? readActiveId() => _preferences.readActiveProfileId();

  Future<void> saveAll(List<ServerProfile> profiles) =>
      _preferences.writeProfiles(profiles);

  Future<void> setActive(String? id) => _preferences.writeActiveProfileId(id);

  Future<void> writeToken(String profileId, String token) =>
      _secure.writeToken(profileId, token);

  Future<void> deleteToken(String profileId) => _secure.deleteToken(profileId);

  Future<String?> readToken(String profileId) => _secure.readToken(profileId);
}
