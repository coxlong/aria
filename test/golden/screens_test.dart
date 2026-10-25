@Tags(<String>['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:aria/core/providers.dart';
import 'package:aria/core/storage/preferences.dart';
import 'package:aria/core/theme/aria_colors.dart';
import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/core/theme/aria_type.dart';
import 'package:aria/core/widgets/aria_composer.dart';
import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:aria/features/chat/application/chat_view.dart';
import 'package:aria/features/chat/presentation/widgets/message_list.dart';
import 'package:aria/features/connect/presentation/connect_page.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
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

  // Icons come from the SDK's Material font; without it every glyph renders
  // as an empty box and the golden would lie about the layout.
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
    await _loadFonts();
  });

  Widget harness(Widget child) {
    return MaterialApp(
      theme: buildAriaTheme(brightness: Brightness.light, chinese: false),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  void sizeTo(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('connect', (tester) async {
    sizeTo(tester, const Size(1200, 800));
    SharedPreferences.setMockInitialValues(<String, Object>{
      'aria.profiles': jsonEncode(<Object>[
        <String, Object?>{
          'id': 'p1',
          'name': 'Studio Mac',
          'url': 'ws://192.168.1.20:3000',
          'cwd': '/Users/me/work',
        },
        <String, Object?>{
          'id': 'p2',
          'name': '',
          'url': 'wss://agent.example.com',
          'cwd': '/srv/app',
        },
      ]),
      'aria.locale': 'en',
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
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ConnectPage),
      matchesGoldenFile('goldens/connect.png'),
    );
  });

  testWidgets('chat', (tester) async {
    // A desktop-sized shot, so the composer shows its options even though the
    // test binding would otherwise default to a phone platform.
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    sizeTo(tester, const Size(1200, 800));

    final now = DateTime(2026, 10, 24, 9, 30);
    final turn = ChatTurn(
      id: 't1',
      userText:
          'Ship the public beta by Friday. Nothing goes out without my '
          'approval.',
      blocks: <TurnBlock>[
        const ThoughtBlock(
          id: 'th1',
          text: 'Checking the release checklist first.',
        ),
        ToolBlock(
          step: WorkStep(
            id: 'tc1',
            title: 'Read the release checklist',
            status: StepStatus.completed,
            startedAt: now,
            endedAt: now.add(const Duration(seconds: 8)),
          ),
        ),
        ToolBlock(
          step: WorkStep(
            id: 'tc2',
            title: 'Run the integration suite',
            status: StepStatus.completed,
            startedAt: now.add(const Duration(seconds: 9)),
            endedAt: now.add(const Duration(seconds: 41)),
          ),
        ),
        const ToolBlock(
          step: WorkStep(
            id: 'tc3',
            title: 'Publish the beta',
            status: StepStatus.running,
          ),
        ),
        TextBlock(
          id: 'p1',
          text:
              'The build is ready and the notes are written.\n\n'
              '**Blocked on you:** publishing reaches outside the workspace.\n\n'
              '```bash\n'
              'npm publish aria@0.1.0-beta.1 --tag beta\n'
              '```',
        ),
      ],
      running: true,
    );

    await tester.pumpWidget(
      harness(
        Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 56),
                    Expanded(
                      child: MessageList(
                        view: ChatView(
                          sessionId: 's1',
                          turns: <ChatTurn>[turn],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: AriaComposer(
                        hint: 'What should Aria do?',
                        running: true,
                        onStop: () {},
                        onSubmit: (text) async => true,
                        chips: const <Widget>[
                          _Chip('Sonnet 4.5'),
                          _Chip('Default'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/chat.png'),
    );

    // The running process pill keeps a timer alive; tear the tree down so the
    // binding does not complain about it after the test.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    debugDefaultTargetPlatformOverride = null;
  });
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.inset,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.ariaType.caption.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
