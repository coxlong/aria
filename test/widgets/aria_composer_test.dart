import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/core/widgets/aria_composer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget harness({
    required Future<bool> Function(String) onSubmit,
    List<Widget> chips = const <Widget>[],
  }) {
    return MaterialApp(
      theme: buildAriaTheme(brightness: Brightness.light, chinese: false),
      home: Scaffold(
        body: AriaComposer(
          hint: 'Ask anything',
          onSubmit: onSubmit,
          chips: chips,
        ),
      ),
    );
  }

  String textOf(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('an accepted send clears the field', (tester) async {
    await tester.pumpWidget(harness(onSubmit: (text) async => true));

    await tester.enterText(find.byType(TextField), 'Ship the beta');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(textOf(tester), isEmpty);
  });

  testWidgets('a refused send keeps the draft', (tester) async {
    // A turn is already running, so the second message is not accepted. Losing
    // it here would mean silently discarding what the person typed.
    await tester.pumpWidget(harness(onSubmit: (text) async => false));

    await tester.enterText(find.byType(TextField), 'Keep this one');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(textOf(tester), 'Keep this one');
  });

  testWidgets('a phone shows one row until the keyboard opens', (tester) async {
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(
      harness(
        onSubmit: (text) async => true,
        chips: const <Widget>[Text('Model')],
      ),
    );

    // Collapsed rows stay mounted but take no space and accept no input.
    expect(find.text('Model').hitTestable(), findsNothing);
    // The send action sits beside the field instead of on a row below it.
    final field = tester.getRect(find.byType(TextField));
    final send = tester.getRect(find.byIcon(Icons.arrow_upward_rounded));
    expect(send.top, lessThan(field.bottom));
    final compactHeight = tester.getSize(find.byType(AriaComposer)).height;

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    // The options row grows in rather than snapping into place.
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Model').hitTestable(), findsOneWidget);
    expect(
      tester.getSize(find.byType(AriaComposer)).height,
      greaterThan(compactHeight),
    );

    // Dismissing the keyboard puts the composer back on one row.
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Model').hitTestable(), findsNothing);
    expect(tester.getSize(find.byType(AriaComposer)).height, compactHeight);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a computer keeps its options without a keyboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        onSubmit: (text) async => true,
        chips: const <Widget>[Text('Model')],
      ),
    );

    expect(find.text('Model'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
