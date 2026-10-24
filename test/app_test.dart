import 'package:acp/acp.dart';
import 'package:aria/app.dart';
import 'package:aria/core/persistence/server_store.dart';
import 'package:aria/state/connection_controller.dart';
import 'package:aria/state/conversation_controller.dart';
import 'package:aria/state/servers_controller.dart';
import 'package:aria/state/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ServersController servers;
  late SettingsController settings;
  late ConversationController conversation;
  late ConnectionController connection;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const store = ServerStore();
    servers = ServersController(store);
    settings = SettingsController(store);
    conversation = ConversationController();
    connection = ConnectionController(
      conversation: conversation,
      store: store,
      factory: (_) async => throw const AcpTransportClosed('offline'),
    );
    await servers.load();
    await settings.load();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      AriaApp(
        servers: servers,
        settings: settings,
        conversation: conversation,
        connection: connection,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the connect page by default', (tester) async {
    await pumpApp(tester);

    expect(find.text('Connect to an agent'), findsOneWidget);
    expect(find.text('No agents yet'), findsOneWidget);
  });

  testWidgets('switches the UI language to Chinese', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('连接一个 agent'), findsOneWidget);
    expect(find.text('还没有 agent'), findsOneWidget);
  });

  testWidgets('opens the server form from the app bar', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Add server'));
    await tester.pumpAndSettle();

    expect(find.text('Add server'), findsOneWidget);
    expect(find.text('Agent URL'), findsOneWidget);
    expect(find.text('Working directory'), findsOneWidget);
  });
}
