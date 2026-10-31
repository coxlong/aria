@Tags(<String>['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:aria/core/format/aria_format.dart';
import 'package:aria/core/providers.dart';
import 'package:aria/core/storage/preferences.dart';
import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/domain/chat/chat_session.dart';
import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:aria/domain/decision/decision.dart';
import 'package:aria/domain/profile/server_profile.dart';
import 'package:aria/domain/session/agent_connection.dart';
import 'package:aria/domain/session/agent_session.dart';
import 'package:aria/domain/session/session_ref.dart';
import 'package:aria/features/chat/presentation/chat_page.dart';
import 'package:aria/features/chat/presentation/chat_stream.dart';
import 'package:aria/features/chat/presentation/widgets/permission_sheet.dart';
import 'package:aria/features/chat/presentation/widgets/run_sheet.dart';
import 'package:aria/features/connection/application/agent_manager.dart';
import 'package:aria/features/connection/application/agent_manager_state.dart';
import 'package:aria/features/home/presentation/home_page.dart';
import 'package:aria/features/settings/presentation/settings_sheet.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The home, chat and sheet surfaces with a fixed connection, so their
/// geometry can be reviewed without a live agent.
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

final ServerProfile _profile = ServerProfile(
  id: 'p1',
  name: 'Studio Mac',
  description: 'Local executor for tests and builds.',
  url: 'ws://127.0.0.1:3000',
  cwd: '/workspace/aria',
);

final AgentSessionSummary _current = AgentSessionSummary(
  id: 's1',
  title: '0.5 release notes',
  cwd: '/workspace/aria',
  updatedAt: DateTime(2026, 10, 27, 9, 30),
);

const SessionRef _currentRef = SessionRef('p1', 's1');

const SessionSurfaces _surfaces = SessionSurfaces(
  models: <SessionOption>[
    SessionOption(id: 'm1', label: 'Aria 0.5'),
    SessionOption(id: 'm2', label: 'Aria 0.5 mini'),
  ],
  currentModelId: 'm1',
  modes: <SessionOption>[
    SessionOption(id: 'execute', label: 'Execute'),
    SessionOption(id: 'plan', label: 'Plan'),
  ],
  currentModeId: 'execute',
  efforts: <SessionOption>[
    SessionOption(id: 'low', label: 'Low'),
    SessionOption(id: 'medium', label: 'Medium'),
    SessionOption(id: 'high', label: 'High'),
  ],
  currentEffortValue: 'medium',
);

AgentManagerState _state({List<Decision>? decisions}) => AgentManagerState(
  agents: <String, AgentConnection>{
    'p1': AgentConnection(
      profile: _profile,
      status: AgentStatus.connected,
      capabilities: const AgentCapabilities(canListSessions: true),
      sessions: <AgentSessionSummary>[
        _current,
        AgentSessionSummary(
          id: 's2',
          title: 'Friday review',
          cwd: '/workspace/aria',
          updatedAt: DateTime(2026, 10, 27, 7, 10),
        ),
        AgentSessionSummary(
          id: 's3',
          title: 'Cloud renewal',
          cwd: '/workspace/finance',
          updatedAt: DateTime(2026, 10, 26, 18, 0),
        ),
      ],
    ),
  },
  order: const <String>['p1'],
  activeAgentId: 'p1',
  sessions: <SessionRef, ChatSession>{
    _currentRef: ChatSession(
      ref: _currentRef,
      cwd: '/workspace/aria',
      loaded: true,
      surfaces: _surfaces,
      decisions:
          decisions ??
          <Decision>[
            Decision(
              id: 'd1',
              prompt: 'Allow publishing the beta?',
              options: const <DecisionOption>[],
              createdAt: DateTime(2026, 10, 27, 9, 31),
            ),
          ],
    ),
  },
  openSessions: const <String, String>{'p1': 's1'},
);

final class _FakeManager extends AgentManager {
  _FakeManager(this.snapshot);

  final AgentManagerState snapshot;

  @override
  AgentManagerState build() => snapshot;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    ariaNow = () => DateTime(2026, 10, 27, 10, 0);
    await _loadFonts();
  });

  tearDownAll(() => ariaNow = DateTime.now);

  Future<Widget> app(
    Widget child, {
    bool waiting = true,
    AgentManagerState? snapshot,
    Brightness brightness = Brightness.dark,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'aria.profiles': jsonEncode(<Object>[
        <String, Object?>{
          'id': 'p1',
          'name': 'Aria',
          'description': 'Takes what you hand over and closes it.',
          'url': 'wss://acp.aria.dev/ws',
          'cwd': '/workspace/aria',
        },
        <String, Object?>{
          'id': 'p2',
          'name': 'Studio Mac',
          'description': 'Local executor for tests and builds.',
          'url': 'ws://127.0.0.1:3000',
          'cwd': '/workspace/aria',
        },
      ]),
      'aria.activeProfile': 'p1',
      'aria.locale': 'en',
      'aria.theme': 'dark',
    });
    final preferences = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(AriaPreferences(preferences)),
        agentManagerProvider.overrideWith(
          () => _FakeManager(
            waiting ? snapshot ?? _state() : const AgentManagerState(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: buildAriaTheme(brightness: brightness, chinese: false),
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        home: child,
      ),
    );
  }

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('home', (tester) async {
    phone(tester);
    await tester.pumpWidget(await app(const HomePage()));
    await tester.pump();

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/home.png'),
    );
  });

  testWidgets('home in light', (tester) async {
    phone(tester);
    await tester.pumpWidget(
      await app(const HomePage(), brightness: Brightness.light),
    );
    await tester.pump();

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/home-light.png'),
    );
  });

  testWidgets('chat shell with model row', (tester) async {
    phone(tester);
    await tester.pumpWidget(
      await app(
        const ChatPage(),
        snapshot: _state(decisions: const <Decision>[]),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await expectLater(
      find.byType(ChatPage),
      matchesGoldenFile('goldens/chat-shell.png'),
    );

    await tester.tap(find.text('Aria 0.5'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/model-sheet.png'),
    );
  });

  testWidgets('permission', (tester) async {
    phone(tester);
    final decision = Decision(
      id: 'p1',
      prompt: 'Allow publishing the beta?',
      detail: 'npm publish aria@0.1.0-beta.1 --tag beta',
      highImpact: true,
      createdAt: DateTime(2026, 10, 27, 9, 31),
      options: const <DecisionOption>[
        DecisionOption(
          id: 'allow_once',
          label: 'Allow once',
          kind: DecisionOptionKind.allowOnce,
        ),
        DecisionOption(
          id: 'allow_always',
          label: 'Always allow',
          kind: DecisionOptionKind.allowAlways,
        ),
        DecisionOption(
          id: 'reject_once',
          label: 'Not now',
          kind: DecisionOptionKind.rejectOnce,
        ),
      ],
    );
    await tester.pumpWidget(
      await app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showPermission(
                  context,
                  decision,
                  queued: 1,
                  onAnswer: (_) {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/permission.png'),
    );
  });

  testWidgets('run sheet', (tester) async {
    phone(tester);
    final run = RunItem(
      id: 'r1',
      folded: true,
      running: false,
      steps: <RunStep>[
        const ThoughtStep(
          ThoughtBlock(
            id: 'th1',
            text: 'Check the release checklist and run the suite before deploying.',
          ),
        ),
        ToolStep(
          ToolBlock(
            step: const WorkStep(
              id: 't1',
              title: 'Read the release checklist',
              status: StepStatus.completed,
              output: '12 items, 3 blocked',
            ),
          ),
        ),
        ToolStep(
          ToolBlock(
            step: const WorkStep(
              id: 't2',
              title: 'Run the integration suite',
              status: StepStatus.failed,
              output: '2 tests failed',
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      await app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showRunSheet(context, run: run),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/run-sheet.png'),
    );

    await tester.tap(find.text('Run the integration suite'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/step-detail.png'),
    );
  });

  testWidgets('agents', (tester) async {
    phone(tester);
    await tester.pumpWidget(
      await app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showSettings(context, openAgents: true),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/agents.png'),
    );

    await tester.tap(find.text('Aria'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/agent-edit.png'),
    );
  });

  testWidgets('settings', (tester) async {
    phone(tester);
    await tester.pumpWidget(
      await app(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showSettings(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Overlay).first,
      matchesGoldenFile('goldens/settings.png'),
    );
  });
}
