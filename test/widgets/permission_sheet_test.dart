import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/domain/decision/decision.dart';
import 'package:aria/features/chat/presentation/widgets/permission_sheet.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The approval sheet is the one place the product cannot let a stray gesture
/// through: the agent is blocked until an answer arrives.
void main() {
  final decision = Decision(
    id: 'd1',
    prompt: 'Publish the beta?',
    detail: 'npm publish',
    options: const <DecisionOption>[
      DecisionOption(
        id: 'allow',
        label: 'Allow once',
        kind: DecisionOptionKind.allowOnce,
      ),
      DecisionOption(
        id: 'reject',
        label: 'Not now',
        kind: DecisionOptionKind.rejectOnce,
      ),
    ],
    createdAt: DateTime(2026, 10, 24),
  );

  /// Pumps the sheet over an empty page and returns what it answers with.
  Future<List<DecisionOption?>> openSheet(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final answers = <DecisionOption?>[];
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
                onPressed: () => showPermission(
                  context,
                  decision,
                  queued: 0,
                  onAnswer: answers.add,
                ),
                child: const Text('ask'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    return answers;
  }

  const wide = Size(1200, 800);
  const narrow = Size(420, 800);

  for (final (label, size) in <(String, Size)>[
    ('dialog', wide),
    ('sheet', narrow),
  ]) {
    testWidgets('$label: the system back button cannot dismiss it', (
      tester,
    ) async {
      final answers = await openSheet(tester, size: size);
      expect(find.text('Publish the beta?'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Publish the beta?'), findsOneWidget);
      expect(answers, isEmpty);
    });

    testWidgets('$label: every agent option and cancel answer it once', (
      tester,
    ) async {
      final answers = await openSheet(tester, size: size);

      await tester.tap(find.text('Allow once'));
      await tester.pumpAndSettle();

      expect(find.text('Publish the beta?'), findsNothing);
      expect(answers, <DecisionOption?>[decision.options.first]);
    });

    testWidgets('$label: cancel reports the cancelled outcome', (tester) async {
      final answers = await openSheet(tester, size: size);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(answers, <DecisionOption?>[null]);
    });
  }
}
