import 'dart:convert';

import 'package:acp/acp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/server_profile.dart';

/// Local persistence for server profiles, tokens, sessions and settings.
///
/// Metadata goes to SharedPreferences; tokens go to secure storage and are
/// never written to prefs.
final class ServerStore {
  static const String serversKey = 'aria.servers';
  static const String localeKey = 'aria.locale';
  static const String _tokenPrefix = 'aria.token.';
  static const String _sessionPrefix = 'aria.sessions.';

  final FlutterSecureStorage secure;

  const ServerStore({this.secure = const FlutterSecureStorage()});

  Future<List<ServerProfile>> loadServers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(serversKey);
    if (raw == null || raw.isEmpty) return <ServerProfile>[];

    final List<ServerProfile> profiles;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      profiles = decoded
          .whereType<Map<String, dynamic>>()
          .map(ServerProfile.fromJson)
          .toList();
    } on Object {
      return <ServerProfile>[];
    }

    for (var i = 0; i < profiles.length; i++) {
      final token = await readToken(profiles[i].id);
      if (token != null && token.isNotEmpty) {
        profiles[i] = profiles[i].copyWith(token: token);
      }
    }
    return profiles;
  }

  Future<void> saveServers(List<ServerProfile> servers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      serversKey,
      jsonEncode(servers.map((profile) => profile.toJson()).toList()),
    );
  }

  Future<String?> readToken(String id) async {
    try {
      return await secure.read(key: '$_tokenPrefix$id');
    } on Object {
      return null;
    }
  }

  Future<void> writeToken(String id, String token) async {
    try {
      await secure.write(key: '$_tokenPrefix$id', value: token);
    } on Object {
      // Secure storage is unavailable on some platforms; the caller keeps the
      // token in memory for the current run.
    }
  }

  Future<void> deleteToken(String id) async {
    try {
      await secure.delete(key: '$_tokenPrefix$id');
    } on Object {
      // Nothing to delete.
    }
  }

  Future<List<SessionSummary>> loadSessions(String serverId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_sessionPrefix$serverId');
    if (raw == null || raw.isEmpty) return <SessionSummary>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SessionSummary.fromJson)
          .toList();
    } on Object {
      return <SessionSummary>[];
    }
  }

  Future<void> saveSessions(
    String serverId,
    List<SessionSummary> sessions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_sessionPrefix$serverId',
      jsonEncode(sessions.map((session) => session.toJson()).toList()),
    );
  }

  Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(localeKey) ?? 'system';
  }

  Future<void> saveLocale(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, value);
  }
}
