import 'package:aria/core/theme/aria_theme.dart';
import 'package:aria/core/widgets/aria_composer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget harness({required Future<bool> Function(String) onSubmit}) {
    return MaterialApp(
      theme: buildAriaTheme(brightness: Brightness.light, chinese: false),
      home: Scaffold(
        body: AriaComposer(hint: 'Ask anything', onSubmit: onSubmit),
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
}
