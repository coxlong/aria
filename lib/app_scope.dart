import 'package:flutter/widgets.dart';

import 'state/connection_controller.dart';
import 'state/conversation_controller.dart';
import 'state/servers_controller.dart';
import 'state/settings_controller.dart';

/// Provides the app controllers to the widget tree.
///
/// The controllers are created once in `main()` and never replaced, so this
/// widget only exposes them; screens listen to the ones they need.
final class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.servers,
    required this.settings,
    required this.conversation,
    required this.connection,
    required super.child,
  });

  final ServersController servers;
  final SettingsController settings;
  final ConversationController conversation;
  final ConnectionController connection;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope above this widget');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      servers != oldWidget.servers ||
      settings != oldWidget.settings ||
      conversation != oldWidget.conversation ||
      connection != oldWidget.connection;
}
