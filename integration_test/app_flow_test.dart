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

/// Runs the real app against a scripted ACP bridge: connect, open a
/// conversation, send a turn, watch the folded run, answer the one decision,
/// and resume another session.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FakeBridge bridge;

  setUp(() async {
    bridge = await FakeBridge.start();
  });

  tearDown(() async {
    await bridge.close();
  });

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
          'description': 'The scripted bridge for this flow.',
          'url': bridge.url,
          'cwd': '/work',
        },
      ]),
      'aria.locale': 'en',
      'aria.activeProfile': 'p1',
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
    await pumpUntil(tester, find.text('Connect Aria'));
  }

  testWidgets('connect, open, ask, decide, resume', (tester) async {
    await pumpApp(tester);

    // The app opens on a dormant point, never on an empty workspace.
    expect(find.text('Connect Aria'), findsOneWidget);
    expect(find.text('Local bridge · Change'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('wake-dot')));
    await pumpUntil(tester, find.text('What can Aria do for you?'));

    // Home lists the sessions the agent knows about.
    expect(find.text('Prepare the beta release'), findsOneWidget);
    expect(find.text('Audit the billing migration'), findsOneWidget);

    await tester.tap(find.text('Prepare the beta release'));
    await pumpUntil(tester, find.textContaining('The checklist is drafted'));

    // Send a turn from the composer.
    final compose = find.byKey(const ValueKey<String>('chat-compose-input'));
    await tester.tap(compose);
    await tester.enterText(compose, 'Ship the public beta by Friday.');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('chat-send')));
    await tester.pump();

    await pumpUntil(tester, find.text('Ship the public beta by Friday.'));
    await pumpUntil(tester, find.textContaining('The build is ready'));

    // The two tools and the thought before the prose fold into one line.
    await pumpUntil(tester, find.textContaining(' · 3 steps'));

    // The one decision arrives in a blocking sheet.
    await pumpUntil(tester, find.text('Allow publishing the beta?'));
    expect(find.text('Allow once'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 320));

    await tester.tap(find.text('Allow once'));
    final answered = await pumpUntilTrue(
      tester,
      () => bridge.answeredPermission,
    );
    expect(answered, isTrue, reason: 'the bridge never received an answer');
    expect(bridge.lastPermissionOptionId, 'allow_once');
    expect(bridge.permissionAllowed, isTrue);

    await pumpUntil(tester, find.textContaining('The beta is published'));

    // Back home, then open another conversation; the agent replays its history.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await pumpUntil(tester, find.text('What can Aria do for you?'));
    // Let the popped chat finish its exit transition before the next route.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Audit the billing migration'));
    await pumpUntil(tester, find.textContaining('The migration is clean'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(bridge.lastLoadedSessionId, FakeBridge.previousSessionId);

    // Back home and start a brand-new conversation. Connecting no longer
    // creates a session; the first prompt does.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await pumpUntil(tester, find.text('What can Aria do for you?'));
    await tester.pump(const Duration(milliseconds: 400));

    final newPrompt = find.byKey(const ValueKey<String>('home-compose-input'));
    await tester.tap(newPrompt);
    await tester.enterText(newPrompt, 'Write the launch note.');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('home-send')));
    await tester.pump();

    await pumpUntil(tester, find.text('Write the launch note.'));
    await pumpUntil(tester, find.textContaining('The build is ready'));
    expect(bridge.methods, contains('session/new'));

    await pumpUntil(tester, find.text('Allow publishing the beta?'));
    await tester.pump(const Duration(milliseconds: 320));
    await tester.tap(find.text('Not now'));
    await pumpUntil(
      tester,
      find.textContaining('Publishing is waiting on your approval'),
    );
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
