import 'package:flutter/foundation.dart';

import '../core/models/server_profile.dart';
import '../core/persistence/server_store.dart';

/// Saved agent connections.
final class ServersController extends ChangeNotifier {
  final ServerStore store;

  List<ServerProfile> servers = <ServerProfile>[];
  bool loading = true;

  ServersController(this.store);

  Future<void> load() async {
    servers = await store.loadServers();
    loading = false;
    notifyListeners();
  }

  Future<ServerProfile> save(ServerProfile profile) async {
    final id = profile.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : profile.id;
    final saved = ServerProfile(
      id: id,
      name: profile.name.trim(),
      url: profile.url.trim(),
      token: profile.token.trim(),
      cwd: profile.cwd.trim(),
    );

    final index = servers.indexWhere((server) => server.id == id);
    if (index >= 0) {
      servers[index] = saved;
    } else {
      servers.add(saved);
    }

    if (saved.token.isNotEmpty) {
      await store.writeToken(id, saved.token);
    } else {
      await store.deleteToken(id);
    }
    await store.saveServers(servers);
    notifyListeners();
    return saved;
  }

  Future<void> delete(String id) async {
    servers.removeWhere((server) => server.id == id);
    await store.deleteToken(id);
    await store.saveServers(servers);
    notifyListeners();
  }
}
