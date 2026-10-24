import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/profile/server_profile.dart';

/// Simple key-value state: profiles, the active profile, language, and the
/// last opened conversation. Structured records belong in the database.
final class AriaPreferences {
  AriaPreferences(this._prefs);

  static const String _profilesKey = 'aria.profiles';
  static const String _activeProfileKey = 'aria.activeProfile';
  static const String _localeKey = 'aria.locale';
  static const String _lastConversationKey = 'aria.lastConversation';

  final SharedPreferences _prefs;

  List<ServerProfile> readProfiles() {
    final raw = _prefs.getString(_profilesKey);
    if (raw == null || raw.isEmpty) return const <ServerProfile>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <ServerProfile>[];
      return decoded
          .whereType<Map<String, Object?>>()
          .map(ServerProfile.fromJson)
          .where((profile) => profile.id.isNotEmpty)
          .toList(growable: false);
    } on FormatException {
      return const <ServerProfile>[];
    }
  }

  Future<void> writeProfiles(List<ServerProfile> profiles) => _prefs.setString(
    _profilesKey,
    jsonEncode(profiles.map((profile) => profile.toJson()).toList()),
  );

  String? readActiveProfileId() => _prefs.getString(_activeProfileKey);

  Future<void> writeActiveProfileId(String? id) async {
    if (id == null) {
      await _prefs.remove(_activeProfileKey);
    } else {
      await _prefs.setString(_activeProfileKey, id);
    }
  }

  /// `system`, `en`, or `zh`.
  String readLocale() => _prefs.getString(_localeKey) ?? 'system';

  Future<void> writeLocale(String value) => _prefs.setString(_localeKey, value);

  String? readLastConversationId() => _prefs.getString(_lastConversationKey);

  Future<void> writeLastConversationId(String? id) async {
    if (id == null) {
      await _prefs.remove(_lastConversationKey);
    } else {
      await _prefs.setString(_lastConversationKey, id);
    }
  }
}
