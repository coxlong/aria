import 'dart:convert';

import 'package:aria/app.dart';
import 'package:aria/core/providers.dart';
import 'package:aria/core/storage/preferences.dart';
import 'package:aria/core/storage/secure_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tool/fake_bridge.dart';

/// Runs the real app against a scripted ACP bridge: connect, send, watch the
/// work, answer the one decision, resume another session.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeBridge bridge;

  setUp(() async {
    bridge = await FakeBridge.start();
  });

  tearDown(() async {
    await bridge.close();
  });

  /// Waits on the bridge's own state instead of guessing at a delay: the round
  /// trip back to the script is not on any frame schedule.
  Future<bool> pumpUntilTrue(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (condition()) return true;
      await tester.pump(const Duration(milliseconds: 50));
    }
    return condition();
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final found = await pumpUntilTrue(
      tester,
      () => finder.evaluate().isNotEmpty,
      timeout: timeout,
    );
    if (!found) fail('Timed out waiting for $finder');
  }

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'aria.profiles': jsonEncode(<Object>[
        <String, Object?>{
          'id': 'p1',
          'name': 'Local bridge',
          'url': bridge.url,
          'cwd': '/work',
        },
      ]),
      'aria.locale': 'en',
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(AriaPreferences(preferences)),
          secureStoreProvider.overrideWithValue(_EmptySecureStore()),
        ],
        child: const AriaApp(),
      ),
    );
    await pumpUntil(tester, find.text('Pick an executor to connect to.'));
  }

  testWidgets('connect, ask, decide, resume', (tester) async {
    await pumpApp(tester);

    // The app opens on the server list, never on an empty workspace.
    expect(find.text('Pick an executor to connect to.'), findsOneWidget);
    expect(find.text('Local bridge'), findsWidgets);
    expect(find.text('Connect'), findsOneWidget);

    await tester.tap(find.text('Connect'));
    await pumpUntil(tester, find.text('Prepare the beta release'));

    // The agent's session list, with the one we are in.
    expect(find.text('Audit the billing migration'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);

    // Send a turn.
    await tester.enterText(
      find.byType(TextField).first,
      'Ship the public beta by Friday.',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump();

    await pumpUntil(tester, find.text('Ship the public beta by Friday.'));
    await pumpUntil(tester, find.textContaining('The build is ready'));

    // The process pill summarises the tool calls rather than spilling them.
    await pumpUntil(tester, find.textContaining('steps'));

    // The one decision. That it also refuses the system back button is pinned
    // by test/widgets/permission_sheet_test.dart, where a route pop can be
    // driven directly.
    await pumpUntil(tester, find.text('Allow publishing the beta?'));
    expect(find.text('Allow once'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);

    await tester.tap(find.text('Allow once'));
    final answered = await pumpUntilTrue(
      tester,
      () => bridge.answeredPermission,
    );
    expect(answered, isTrue, reason: 'the bridge never received an answer');
    expect(bridge.lastPermissionOptionId, 'allow_once');
    expect(bridge.permissionAllowed, isTrue);

    await pumpUntil(tester, find.textContaining('The beta is published'));

    // Switching to another session replays that session's history, not the
    // one still on screen.
    await tester.tap(find.text('Audit the billing migration'));
    await pumpUntil(tester, find.textContaining('The migration is clean'));
    expect(bridge.lastLoadedSessionId, FakeBridge.previousSessionId);
  });
}

/// Token storage is not what this flow is about.
final class _EmptySecureStore extends SecureStore {
  @override
  Future<String?> readToken(String profileId) async => null;

  @override
  Future<void> writeToken(String profileId, String token) async {}

  @override
  Future<void> deleteToken(String profileId) async {}
}
