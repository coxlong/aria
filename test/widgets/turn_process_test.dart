import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:aria/features/chat/presentation/widgets/turn_process.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// While a turn runs the transcript has to say what is happening, without the
/// reader opening the work sheet; once it ends the cards must fold away.
void main() {
  WorkStep tool(String id, {StepStatus status = StepStatus.completed}) =>
      WorkStep(id: id, title: id, status: status);

  Future<void> show(
    WidgetTester tester,
    ChatTurn turn, {
    bool settle = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAriaTheme(brightness: Brightness.light, chinese: false),
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: TurnProcess(turn: turn),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  /// The live card keeps a pulse animation alive, which would otherwise make
  /// the binding complain about a pending ticker after the test.
  Future<void> tearDownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('a running turn names the step it is on', (tester) async {
    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        ToolBlock(step: tool('Read the checklist')),
        ToolBlock(
          step: tool('Run the integration suite', status: StepStatus.running),
        ),
      ],
    );

    await show(tester, turn);

    expect(find.text('Run the integration suite'), findsOneWidget);
    // The step behind it stays visible, so the path so far is readable.
    expect(find.text('Read the checklist'), findsOneWidget);
    // A step that is running is not also a step that finished.
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tearDownTree(tester);
  });

  testWidgets('only the last two finished steps stay in view', (tester) async {
    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        for (final title in <String>['one', 'two', 'three', 'four'])
          ToolBlock(step: tool(title)),
        ToolBlock(step: tool('now', status: StepStatus.running)),
      ],
    );

    await show(tester, turn);

    expect(find.text('one'), findsNothing);
    expect(find.text('two'), findsNothing);
    expect(find.text('three'), findsOneWidget);
    expect(find.text('four'), findsOneWidget);

    await tearDownTree(tester);
  });

  testWidgets('while the agent only thinks, the card shows the thought', (
    tester,
  ) async {
    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        const ThoughtBlock(
          id: 'th1',
          text: 'Checking the release checklist first.\nThen the build.',
        ),
      ],
    );

    await show(tester, turn);

    // The first line only: the card is a glance, not the log.
    expect(find.text('Checking the release checklist first.'), findsOneWidget);
    expect(find.textContaining('Then the build'), findsNothing);

    await tearDownTree(tester);
  });

  testWidgets('a turn that has produced nothing yet still says so', (
    tester,
  ) async {
    const turn = ChatTurn(id: 't1', userText: 'Ship it', running: true);

    await show(tester, turn);

    expect(find.text('Thinking'), findsOneWidget);

    await tearDownTree(tester);
  });

  testWidgets('a finished turn folds back to one quiet line', (tester) async {
    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      blocks: <TurnBlock>[
        ToolBlock(step: tool('Read the checklist')),
        ToolBlock(step: tool('Run the integration suite')),
        ToolBlock(step: tool('Publish the beta')),
      ],
    );

    await show(tester, turn, settle: true);

    expect(find.text('3 steps'), findsOneWidget);
    // The individual steps belong to the sheet, not the transcript.
    expect(find.text('Read the checklist'), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('a failed step is not shown as a completed turn', (tester) async {
    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      blocks: <TurnBlock>[
        ToolBlock(step: tool('Publish the beta', status: StepStatus.failed)),
      ],
    );

    await show(tester, turn, settle: true);

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('tapping the live card opens the work behind it', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final turn = ChatTurn(
      id: 't1',
      userText: 'Ship it',
      running: true,
      blocks: <TurnBlock>[
        ToolBlock(step: tool('Read the checklist')),
        ToolBlock(
          step: tool('Run the integration suite', status: StepStatus.running),
        ),
      ],
    );

    await show(tester, turn);
    await tester.tap(find.text('Run the integration suite'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Work'), findsOneWidget);
    // One in the card behind the sheet, one in the sheet's own list.
    expect(find.text('Read the checklist'), findsNWidgets(2));

    await tearDownTree(tester);
  });
}
