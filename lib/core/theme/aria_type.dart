import 'package:material_ui/material_ui.dart';

/// The type scale from the design.
///
/// Latin text is set in the bundled Inter variable font; Chinese falls back to
/// the platform face. Sizes, leading and tracking are the design's own values.
@immutable
final class AriaType extends ThemeExtension<AriaType> {
  const AriaType({
    required this.hero,
    required this.headline,
    required this.brand,
    required this.sheetTitle,
    required this.title,
    required this.chatTitle,
    required this.body,
    required this.quote,
    required this.ui,
    required this.label,
    required this.small,
    required this.run,
    required this.caption,
    required this.tiny,
    required this.kicker,
    required this.code,
  });

  /// Latin metrics.
  factory AriaType.latin() => AriaType._build(bodyHeight: 1.68);

  /// Chinese keeps a little more air between lines.
  factory AriaType.zh() => AriaType._build(bodyHeight: 1.72);

  factory AriaType._build({required double bodyHeight}) {
    TextStyle sans(
      double size,
      FontWeight weight,
      double height,
      double trackingEm,
    ) => TextStyle(
      fontFamily: _latinFamily,
      fontFamilyFallback: _cjkFallback,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: size * trackingEm,
      color: null,
    );

    return AriaType(
      hero: sans(34, FontWeight.w600, 1.18, -0.045),
      headline: sans(24, FontWeight.w600, 1.28, -0.03),
      brand: sans(21, FontWeight.w600, 1.0, -0.04),
      sheetTitle: sans(22, FontWeight.w600, 1.35, -0.032),
      title: sans(16, FontWeight.w600, 1.4, -0.018),
      chatTitle: sans(15, FontWeight.w600, 1.35, -0.012),
      body: sans(16, FontWeight.w400, bodyHeight, -0.006),
      quote: sans(15, FontWeight.w400, 1.75, -0.006),
      ui: sans(14, FontWeight.w400, 1.5, -0.006),
      label: sans(14, FontWeight.w600, 1.3, -0.006),
      small: sans(13.5, FontWeight.w400, 1.55, -0.006),
      run: sans(14, FontWeight.w400, 1.45, -0.004),
      caption: sans(12, FontWeight.w400, 1.5, 0),
      tiny: sans(11.5, FontWeight.w500, 1.45, 0.005),
      kicker: sans(10.5, FontWeight.w600, 1.4, 0.16),
      code: const TextStyle(
        fontFamily: _monoFamily,
        fontFamilyFallback: _cjkFallback,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.65,
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

  /// Tabular figures for counts and versions.
  static const List<FontFeature> tabularFigures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// 33px: the home question.
  final TextStyle hero;

  /// 24px: empty states and section heads.
  final TextStyle headline;

  /// 20px: the word Aria.
  final TextStyle brand;

  /// 22px: a sheet's title.
  final TextStyle sheetTitle;

  /// 16px: conversation titles, row titles.
  final TextStyle title;

  /// 15px: the chat header and quote text.
  final TextStyle chatTitle;

  /// 16px: prose.
  final TextStyle body;

  /// 15px: a thought read on its own.
  final TextStyle quote;

  /// 14px: controls and secondary lines.
  final TextStyle ui;

  /// 14px semibold: buttons and field labels.
  final TextStyle label;

  /// 13.5px: list descriptions.
  final TextStyle small;

  /// 13px: one step in a run.
  final TextStyle run;

  /// 12px: metadata.
  final TextStyle caption;

  /// 11.5px: the quietest metadata.
  final TextStyle tiny;

  /// 10.5px, wide tracked: eyebrows above a sheet title.
  final TextStyle kicker;

  /// Monospaced data.
  final TextStyle code;

  /// The old name for the largest style.
  TextStyle get display => hero;

  @override
  AriaType copyWith({
    TextStyle? hero,
    TextStyle? headline,
    TextStyle? brand,
    TextStyle? sheetTitle,
    TextStyle? title,
    TextStyle? chatTitle,
    TextStyle? body,
    TextStyle? quote,
    TextStyle? ui,
    TextStyle? label,
    TextStyle? small,
    TextStyle? run,
    TextStyle? caption,
    TextStyle? tiny,
    TextStyle? kicker,
    TextStyle? code,
  }) => AriaType(
    hero: hero ?? this.hero,
    headline: headline ?? this.headline,
    brand: brand ?? this.brand,
    sheetTitle: sheetTitle ?? this.sheetTitle,
    title: title ?? this.title,
    chatTitle: chatTitle ?? this.chatTitle,
    body: body ?? this.body,
    quote: quote ?? this.quote,
    ui: ui ?? this.ui,
    label: label ?? this.label,
    small: small ?? this.small,
    run: run ?? this.run,
    caption: caption ?? this.caption,
    tiny: tiny ?? this.tiny,
    kicker: kicker ?? this.kicker,
    code: code ?? this.code,
  );

  @override
  AriaType lerp(AriaType? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t) ?? b;
    return AriaType(
      hero: mix(hero, other.hero),
      headline: mix(headline, other.headline),
      brand: mix(brand, other.brand),
      sheetTitle: mix(sheetTitle, other.sheetTitle),
      title: mix(title, other.title),
      chatTitle: mix(chatTitle, other.chatTitle),
      body: mix(body, other.body),
      quote: mix(quote, other.quote),
      ui: mix(ui, other.ui),
      label: mix(label, other.label),
      small: mix(small, other.small),
      run: mix(run, other.run),
      caption: mix(caption, other.caption),
      tiny: mix(tiny, other.tiny),
      kicker: mix(kicker, other.kicker),
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
