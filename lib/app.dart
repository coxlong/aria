import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'features/chat/chat_page.dart';
import 'features/connect/connect_page.dart';
import 'l10n/app_localizations.dart';
import 'state/connection_controller.dart';
import 'state/conversation_controller.dart';
import 'state/servers_controller.dart';
import 'state/settings_controller.dart';

/// Root widget: wires controllers, localization and the initial route.
final class AriaApp extends StatelessWidget {
  const AriaApp({
    super.key,
    required this.servers,
    required this.settings,
    required this.conversation,
    required this.connection,
  });

  final ServersController servers;
  final SettingsController settings;
  final ConversationController conversation;
  final ConnectionController connection;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      servers: servers,
      settings: settings,
      conversation: conversation,
      connection: connection,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(colorSchemeSeed: Colors.grey),
          home: const ConnectionGate(),
        ),
      ),
    );
  }
}

/// Shows the chat while a session is live, the connect page otherwise.
final class ConnectionGate extends StatelessWidget {
  const ConnectionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = AppScope.of(context).connection;
    return ListenableBuilder(
      listenable: connection,
      builder: (context, _) =>
          connection.session == null ? const ConnectPage() : const ChatPage(),
    );
  }
}
