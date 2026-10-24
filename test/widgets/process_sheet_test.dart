import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/domain/chat/chat_turn.dart';
import 'package:aria/domain/chat/work_step.dart';
import 'package:aria/features/chat/presentation/widgets/process_sheet.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The process sheet is the only place reasoning and intermediate prose can be
/// read, so both pages have to actually carry their text.
void main() {
  const thought = 'Checking the release checklist first.';
  const commentary =
      'The checklist has three blocked entries, which I handled by asking the '
      'release owner before touching anything.';

  final turn = ChatTurn(
    id: 't1',
    userText: 'Ship the beta.',
    running: false,
    blocks: <TurnBlock>[
      const ThoughtBlock(id: 'th1', text: thought),
      ToolBlock(
        step: WorkStep(
          id: 'tc1',
          title: 'Read the release checklist',
          status: StepStatus.completed,
          input: '--dry-run',
          output: '12 items',
        ),
      ),
      const TextBlock(id: 'p0', text: commentary),
      const TextBlock(id: 'p1', text: 'The build is ready.'),
    ],
  );

  Future<void> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAriaTheme(brightness: Brightness.light, chinese: false),
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showProcessSheet(context, turn),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a thought opens with its text', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Thinking'));
    await tester.pumpAndSettle();

    expect(find.textContaining(thought), findsOneWidget);
  });

  testWidgets('an intermediate prose block opens with its full text', (
    tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.textContaining('The checklist has three'));
    await tester.pumpAndSettle();

    // The row only had room for the first line; this sentence is further down.
    expect(
      find.textContaining('release owner before touching'),
      findsOneWidget,
    );
  });

  testWidgets('a tool opens with its input and output', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Read the release checklist'));
    await tester.pumpAndSettle();

    expect(find.text('--dry-run'), findsOneWidget);
    expect(find.textContaining('12 items'), findsOneWidget);
  });
}
