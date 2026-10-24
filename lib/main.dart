import 'package:flutter/material.dart';

import 'app.dart';
import 'core/persistence/server_store.dart';
import 'state/connection_controller.dart';
import 'state/conversation_controller.dart';
import 'state/servers_controller.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const store = ServerStore();
  final servers = ServersController(store);
  final settings = SettingsController(store);
  final conversation = ConversationController();
  final connection = ConnectionController(
    conversation: conversation,
    store: store,
  );

  await Future.wait([servers.load(), settings.load()]);

  runApp(
    AriaApp(
      servers: servers,
      settings: settings,
      conversation: conversation,
      connection: connection,
    ),
  );
}
