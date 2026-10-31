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
    ('ink on ground', colors.ink, colors.ground),
    ('ink on sheet', colors.ink, colors.sheet),
    ('ink on panel', colors.ink, colors.panel),
    ('ink on panel-2', colors.ink, colors.panel2),
    ('ink-2 on ground', colors.ink2, colors.ground),
    ('ink-2 on panel', colors.ink2, colors.panel),
    ('muted on ground', colors.muted, colors.ground),
    ('muted on sheet', colors.muted, colors.sheet),
    ('muted on panel', colors.muted, colors.panel),
    ('gold on ground', colors.gold, colors.ground),
    ('gold on gold-soft', colors.gold, colors.goldSoft),
    ('gold-ink on gold-fill', colors.goldInk, colors.goldFill),
    ('key-ink on key', colors.keyInk, colors.key),
    ('key-muted on key', colors.keyMuted, colors.key),
    ('danger on ground', colors.danger, colors.ground),
    ('danger on danger-soft', colors.danger, colors.dangerSoft),
  ];

  for (final (label, foreground, background) in pairs) {
    test('$theme: $label meets AA', () {
      // Surfaces are translucent light over the ground, so contrast is measured
      // on what actually reaches the eye, not on the raw token.
      final surface = Color.alphaBlend(background, colors.ground);
      final ink = Color.alphaBlend(foreground, surface);
      final ratio = _contrast(ink, surface);
      expect(ratio, greaterThanOrEqualTo(_aa), reason: '$label is $ratio:1');
    });
  }
}

void main() {
  _expectPairs(AriaColors.light(), 'light');
  _expectPairs(AriaColors.dark(), 'dark');

  test('Chinese body keeps a little more leading', () {
    final latin = AriaType.latin();
    final chinese = AriaType.zh();
    expect(chinese.body.height, greaterThan(latin.body.height ?? 0));
  });

  test('the hero carries the design tracking', () {
    final type = AriaType.latin();
    expect(type.hero.fontSize, 34);
    expect(type.hero.letterSpacing, lessThan(0));
    expect(type.kicker.letterSpacing, greaterThan(0));
  });

  test('every text style declares the system CJK fallback chain', () {
    final type = AriaType.latin();
    for (final style in <TextStyle>[
      type.hero,
      type.headline,
      type.brand,
      type.sheetTitle,
      type.title,
      type.chatTitle,
      type.body,
      type.quote,
      type.ui,
      type.label,
      type.small,
      type.run,
      type.caption,
      type.tiny,
      type.kicker,
      type.code,
    ]) {
      expect(style.fontFamilyFallback, contains('PingFang SC'));
      expect(style.fontFamilyFallback, contains('Noto Sans CJK SC'));
      expect(style.fontFamilyFallback, contains('Microsoft YaHei'));
    }
  });
}
