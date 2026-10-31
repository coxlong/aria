import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers.dart';
import '../../../domain/profile/server_profile.dart';
import '../domain/app_settings.dart';
import 'providers.dart';

part 'settings_controller.g.dart';

/// Profiles and language. Owns every write to preferences and secure storage.
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  static const Uuid _ids = Uuid();

  @override
  AppSettings build() {
    final repository = ref.watch(profileRepositoryProvider);
    return AppSettings(
      profiles: repository.readAll(),
      activeProfileId: repository.readActiveId(),
      connectProfileId: ref.watch(preferencesProvider).readConnectProfileId(),
      locale: ref.watch(preferencesProvider).readLocale(),
      themeMode: ref.watch(preferencesProvider).readThemeMode(),
    );
  }

  /// Adds a profile and makes it active when it is the first one.
  Future<ServerProfile> addProfile({
    required String name,
    required String url,
    required String cwd,
    required String token,
    String description = '',
  }) async {
    final profile = ServerProfile(
      id: _ids.v4(),
      name: name.trim(),
      description: description.trim(),
      url: url.trim(),
      cwd: cwd.trim(),
    );
    final profiles = <ServerProfile>[...state.profiles, profile];
    final activeId = state.activeProfileId ?? profile.id;

    await _write(profiles, activeId);
    if (token.isNotEmpty) {
      await ref.read(profileRepositoryProvider).writeToken(profile.id, token);
    }
    return profile;
  }

  /// Updates metadata. A null [token] leaves the stored credential untouched.
  Future<void> updateProfile(ServerProfile profile, {String? token}) async {
    final profiles = state.profiles
        .map((existing) => existing.id == profile.id ? profile : existing)
        .toList(growable: false);
    await _write(profiles, state.activeProfileId);
    if (token != null) {
      final repository = ref.read(profileRepositoryProvider);
      if (token.isEmpty) {
        await repository.deleteToken(profile.id);
      } else {
        await repository.writeToken(profile.id, token);
      }
    }
  }

  Future<void> deleteProfile(String id) async {
    final profiles = state.profiles
        .where((profile) => profile.id != id)
        .toList(growable: false);
    final activeId = state.activeProfileId == id
        ? (profiles.isEmpty ? null : profiles.first.id)
        : state.activeProfileId;

    await _write(profiles, activeId);
    await ref.read(profileRepositoryProvider).deleteToken(id);
    if (state.connectProfileId == id) await setConnectProfile(null);
  }

  Future<void> setActiveProfile(String id) async {
    await _write(state.profiles, id);
  }

  /// Remembers who should answer next, without changing the default agent.
  Future<void> setConnectProfile(String? id) async {
    await ref.read(preferencesProvider).writeConnectProfileId(id);
    state = state.copyWith(connectProfileId: id);
  }

  Future<void> setLocale(String value) async {
    await ref.read(preferencesProvider).writeLocale(value);
    state = state.copyWith(locale: value);
  }

  Future<void> setThemeMode(String value) async {
    await ref.read(preferencesProvider).writeThemeMode(value);
    state = state.copyWith(themeMode: value);
  }

  /// Any saved profile with its token, for the executor.
  Future<ConnectedProfile?> connected(String profileId) async {
    final matches = state.profiles.where((profile) => profile.id == profileId);
    if (matches.isEmpty) return null;
    final profile = matches.first;
    final token = await ref
        .read(profileRepositoryProvider)
        .readToken(profile.id);
    return ConnectedProfile(profile: profile, token: token ?? '');
  }

  /// The active profile with its token, for the executor.
  Future<ConnectedProfile?> activeConnected() async {
    final id = state.activeProfileId;
    return id == null ? null : connected(id);
  }

  Future<void> _write(List<ServerProfile> profiles, String? activeId) async {
    final repository = ref.read(profileRepositoryProvider);
    await repository.saveAll(profiles);
    await repository.setActive(activeId);
    state = state.copyWith(profiles: profiles, activeProfileId: activeId);
  }
}
