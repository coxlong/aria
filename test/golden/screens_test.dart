@Tags(<String>['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:aria/core/format/aria_format.dart';
import 'package:aria/core/providers.dart';
import 'package:aria/core/storage/preferences.dart';
import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/core/widgets/aria_viewport.dart';
import 'package:aria/domain/chat/chat_session.dart';
import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:aria/domain/session/session_ref.dart';
import 'package:aria/features/chat/presentation/widgets/message_list.dart';
import 'package:aria/features/connect/presentation/connect_page.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// These render the real theme and the bundled fonts, so the files in
/// `test/golden/goldens/` are what the product actually looks like.
Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final loader = FontLoader(family)
      ..addFont(
        File(path).readAsBytes().then((bytes) => ByteData.view(bytes.buffer)),
      );
    await loader.load();
  }

  await load('Inter', 'assets/fonts/InterVariable.ttf');
  await load('JetBrains Mono', 'assets/fonts/JetBrainsMono-Regular.ttf');

  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    final iconFont = File(
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (iconFont.existsSync()) await load('MaterialIcons', iconFont.path);
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    ariaNow = () => DateTime(2026, 10, 27, 10, 0);
    await _loadFonts();
  });

  tearDownAll(() => ariaNow = DateTime.now);

  Widget harness(Widget child) {
    return MaterialApp(
      theme: buildAriaTheme(brightness: Brightness.dark, chinese: false),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: child,
    );
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('connect', (tester) async {
    phone(tester);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'aria.profiles': jsonEncode(<Object>[
        <String, Object?>{
          'id': 'p1',
          'name': 'Aria',
          'description': 'Takes what you hand over, splits it, and closes it.',
          'url': 'wss://acp.aria.dev/ws',
          'cwd': '/workspace/aria',
        },
        <String, Object?>{
          'id': 'p2',
          'name': 'Studio Mac',
          'description': 'Local executor for tests and builds.',
          'url': 'ws://127.0.0.1:3000',
          'cwd': '/Users/me/work',
        },
        <String, Object?>{
          'id': 'p3',
          'name': '',
          'description': '',
          'url': 'wss://agent.example.com',
          'cwd': '/srv/app',
        },
      ]),
      'aria.locale': 'en',
      'aria.activeProfile': 'p1',
      'aria.theme': 'dark',
    });
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(AriaPreferences(preferences)),
        ],
        child: harness(const ConnectPage()),
      ),
    );
    // The wake aura breathes forever; settle to a fixed point instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(ConnectPage),
      matchesGoldenFile('goldens/connect.png'),
    );
  });

  testWidgets('chat stream', (tester) async {
    phone(tester);

    final turn = ChatTurn(
      id: 't1',
      userText: 'Write the 0.5 release notes. I need them today.',
      blocks: <TurnBlock>[
        const ThoughtBlock(
          id: 'th1',
          text:
              'Read the last 14 commits and the six review notes; keep only '
              'what changed for the outside.',
        ),
        ToolBlock(
          step: const WorkStep(
            id: 'read',
            title: 'Read the commit log',
            status: StepStatus.completed,
            output: '14 commits',
          ),
        ),
        ToolBlock(
          step: const WorkStep(
            id: 'write',
            title: 'Group the changes',
            status: StepStatus.completed,
            output: 'Six groups',
          ),
        ),
        const TextBlock(
          id: 'p1',
          text:
              'Three things are worth saying: a new home, delegable steps, '
              'and outcomes that open on their own. The rest are fixes.',
        ),
        const ThoughtBlock(
          id: 'th2',
          text:
              'Write the artifacts section: read the draft, add a paragraph, '
              'then read the whole piece.',
        ),
        ToolBlock(
          step: const WorkStep(
            id: 'read2',
            title: 'Read the draft',
            status: StepStatus.completed,
            output: 'Current draft and latest notes',
          ),
        ),
        ToolBlock(
          step: const WorkStep(
            id: 'write2',
            title: 'Write the artifacts section',
            status: StepStatus.running,
          ),
        ),
      ],
      running: true,
    );

    await tester.pumpWidget(
      harness(
        AriaViewport(
          child: MessageList(
            session: ChatSession(
              ref: const SessionRef('a', 's1'),
              turns: <ChatTurn>[turn],
              running: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(AriaViewport),
      matchesGoldenFile('goldens/chat.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
