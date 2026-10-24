import 'dart:math' as math;

import 'package:aria/core/theme/aria_colors.dart';
import 'package:aria/core/theme/aria_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// WCAG AA for normal text.
const double _aa = 4.5;

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  final lighter = math.max(a, b);
  final darker = math.min(a, b);
  return (lighter + 0.05) / (darker + 0.05);
}

void _expectPairs(AriaColors colors, String theme) {
  final pairs = <(String, Color, Color)>[
    ('text on canvas', colors.text, colors.canvas),
    ('text on surface', colors.text, colors.surface),
    ('text on inset', colors.text, colors.inset),
    ('text on selected', colors.text, colors.selected),
    ('secondary on canvas', colors.textSecondary, colors.canvas),
    ('secondary on surface', colors.textSecondary, colors.surface),
    ('muted on canvas', colors.textMuted, colors.canvas),
    ('muted on surface', colors.textMuted, colors.surface),
    ('onPrimary on primary', colors.onPrimary, colors.primary),
    ('primary on primary-soft', colors.primary, colors.primarySoft),
    ('success on success-soft', colors.success, colors.successSoft),
    ('warning on warning-soft', colors.warning, colors.warningSoft),
    ('attention on attention-soft', colors.attention, colors.attentionSoft),
    ('error on error-soft', colors.error, colors.errorSoft),
  ];

  for (final (label, foreground, background) in pairs) {
    test('$theme: $label meets AA', () {
      expect(
        _contrast(foreground, background),
        greaterThanOrEqualTo(_aa),
        reason: '$label is ${_contrast(foreground, background)}:1',
      );
    });
  }
}

void main() {
  _expectPairs(AriaColors.light(), 'light');
  _expectPairs(AriaColors.dark(), 'dark');

  test('Chinese type keeps its own leading and drops negative tracking', () {
    final latin = AriaType.latin();
    final chinese = AriaType.zh();

    expect(latin.body.height, 1.65);
    expect(chinese.body.height, 1.72);
    expect(latin.display.letterSpacing, lessThan(0));
    expect(chinese.display.letterSpacing, 0);
    expect(chinese.title.letterSpacing, 0);
  });

  test('every text style declares the system CJK fallback chain', () {
    final type = AriaType.latin();
    for (final style in <TextStyle>[
      type.display,
      type.headline,
      type.title,
      type.body,
      type.ui,
      type.label,
      type.caption,
      type.code,
    ]) {
      expect(style.fontFamilyFallback, contains('PingFang SC'));
      expect(style.fontFamilyFallback, contains('Noto Sans CJK SC'));
      expect(style.fontFamilyFallback, contains('Microsoft YaHei'));
    }
  });
}
