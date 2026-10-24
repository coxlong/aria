import 'package:material_ui/material_ui.dart';

/// The type scale.
///
/// Latin text is set in the bundled Inter variable font. Chinese falls back to
/// the platform face; the fallback chain is declared once here and never per
/// widget. [AriaType.zh] carries the Chinese line-height and tracking
/// adjustments, so widgets stay locale-agnostic.
@immutable
final class AriaType extends ThemeExtension<AriaType> {
  const AriaType({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.ui,
    required this.label,
    required this.caption,
    required this.code,
  });

  /// Latin metrics, as specified.
  factory AriaType.latin() => AriaType._build(
    bodyHeight: 1.65,
    captionHeight: 1.45,
    tightTracking: true,
  );

  /// Chinese metrics: taller body leading, no negative tracking.
  factory AriaType.zh() => AriaType._build(
    bodyHeight: 1.72,
    captionHeight: 1.5,
    tightTracking: false,
  );

  factory AriaType._build({
    required double bodyHeight,
    required double captionHeight,
    required bool tightTracking,
  }) {
    double em(double size, double tracking) =>
        tightTracking ? size * tracking : 0;

    TextStyle sans(
      double size,
      FontWeight weight,
      double height,
      double tracking,
    ) => TextStyle(
      fontFamily: _latinFamily,
      fontFamilyFallback: _cjkFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: tracking,
      color: null,
    );

    return AriaType(
      display: sans(32, FontWeight.w600, 1.2, em(32, -0.022)),
      headline: sans(24, FontWeight.w600, 1.28, em(24, -0.016)),
      title: sans(17, FontWeight.w600, 1.35, em(17, -0.004)),
      body: sans(16, FontWeight.w400, bodyHeight, 0),
      ui: sans(14, FontWeight.w400, 1.5, 0),
      label: sans(14, FontWeight.w600, 1.3, 0),
      caption: sans(12, FontWeight.w400, captionHeight, 0),
      code: const TextStyle(
        fontFamily: _monoFamily,
        fontFamilyFallback: _cjkFallback,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
    );
  }

  static const String _latinFamily = 'Inter';
  static const String _monoFamily = 'JetBrains Mono';

  /// Latin first (Inter has no CJK glyphs), then each platform's own face.
  static const List<String> _cjkFallback = <String>[
    'PingFang SC',
    'Noto Sans CJK SC',
    'Microsoft YaHei',
  ];

  /// Tabular figures for durations, counts, costs, and versions. Without this,
  /// a ticking value shifts every glyph beside it.
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle ui;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle code;

  @override
  AriaType copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? ui,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? code,
  }) => AriaType(
    display: display ?? this.display,
    headline: headline ?? this.headline,
    title: title ?? this.title,
    body: body ?? this.body,
    ui: ui ?? this.ui,
    label: label ?? this.label,
    caption: caption ?? this.caption,
    code: code ?? this.code,
  );

  @override
  AriaType lerp(AriaType? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t) ?? b;
    return AriaType(
      display: mix(display, other.display),
      headline: mix(headline, other.headline),
      title: mix(title, other.title),
      body: mix(body, other.body),
      ui: mix(ui, other.ui),
      label: mix(label, other.label),
      caption: mix(caption, other.caption),
      code: mix(code, other.code),
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AriaType>()!`.
extension AriaTypeContext on BuildContext {
  AriaType get ariaType =>
      Theme.of(this).extension<AriaType>() ??
      (Localizations.localeOf(this).languageCode == 'zh'
          ? AriaType.zh()
          : AriaType.latin());
}
