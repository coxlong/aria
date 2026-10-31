import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/domain/decision/decision.dart';
import 'package:aria/features/chat/presentation/widgets/permission_sheet.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// An approval blocks the agent, so the sheet cannot be dismissed by tapping
/// outside, by the close affordance, or by the system back gesture.
void main() {
  final decision = Decision(
    id: 'd1',
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

  Future<_Answers> open(WidgetTester tester) async {
    final answers = _Answers();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAriaTheme(brightness: Brightness.dark, chinese: false),
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showPermission(
                  context,
                  decision,
                  queued: 1,
                  onAnswer: answers.record,
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
    return answers;
  }

  testWidgets('offers every option the agent sent, with the risk marked', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('Allow publishing the beta?'), findsOneWidget);
    expect(find.text('Allow once'), findsOneWidget);
    expect(find.text('This run only'), findsOneWidget);
    expect(find.text('Always allow'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);
    expect(find.text('1 more decision is waiting'), findsOneWidget);
    // A blocking sheet has no way out but the options and the cancel action.
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('the system back cannot dismiss it', (tester) async {
    await open(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Allow publishing the beta?'), findsOneWidget);
  });

  testWidgets('an option answers with its id', (tester) async {
    final answers = await open(tester);

    await tester.tap(find.text('Allow once'));
    await tester.pumpAndSettle();

    expect(answers.answered, isTrue);
    expect(answers.option?.id, 'allow_once');
    expect(find.text('Allow publishing the beta?'), findsNothing);
  });

  testWidgets('cancel answers with no option', (tester) async {
    final answers = await open(tester);

    await tester.tap(find.text('Cancel this'));
    await tester.pumpAndSettle();

    expect(answers.answered, isTrue);
    expect(answers.option, isNull);
    expect(find.text('Allow publishing the beta?'), findsNothing);
  });
}

final class _Answers {
  bool answered = false;
  DecisionOption? option;

  void record(DecisionOption? value) {
    answered = true;
    option = value;
  }
}
