import 'package:material_ui/material_ui.dart';

/// The semantic color scale.
///
/// Widgets must read colors from this extension, never from literals. The
/// light and dark sets are complete and independent: dark is not a filter over
/// light.
@immutable
final class AriaColors extends ThemeExtension<AriaColors> {
  const AriaColors({
    required this.canvas,
    required this.surface,
    required this.raised,
    required this.inset,
    required this.selected,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryHover,
    required this.primarySoft,
    required this.onPrimary,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.attention,
    required this.attentionSoft,
    required this.error,
    required this.errorSoft,
  });

  /// Light theme values straight from the design tokens.
  factory AriaColors.light() => const AriaColors(
    canvas: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFFFFFFF),
    inset: Color(0xFFEFF1F5),
    selected: Color(0xFFEEEFFF),
    text: Color(0xFF181B20),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF626D7D),
    border: Color(0xFFDDE2E8),
    borderStrong: Color(0xFFC2CBD5),
    primary: Color(0xFF494FE0),
    primaryHover: Color(0xFF383DC4),
    primarySoft: Color(0xFFEEEFFF),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF147D57),
    successSoft: Color(0xFFE7F5EF),
    warning: Color(0xFF6E5A00),
    warningSoft: Color(0xFFF7F3DF),
    attention: Color(0xFF8A4B00),
    attentionSoft: Color(0xFFFFF0E0),
    error: Color(0xFFBD3542),
    errorSoft: Color(0xFFFCECEF),
  );

  /// Dark theme values. Every semantic state has a soft fill of its own.
  factory AriaColors.dark() => const AriaColors(
    canvas: Color(0xFF0E1013),
    surface: Color(0xFF15181D),
    raised: Color(0xFF1B1F26),
    inset: Color(0xFF111419),
    selected: Color(0xFF25294A),
    text: Color(0xFFF1F3F6),
    textSecondary: Color(0xFFBAC2CD),
    textMuted: Color(0xFF929DAB),
    border: Color(0xFF303640),
    borderStrong: Color(0xFF3D4551),
    primary: Color(0xFFAEB4FF),
    primaryHover: Color(0xFFC6CBFF),
    primarySoft: Color(0xFF272B4B),
    onPrimary: Color(0xFF171A44),
    success: Color(0xFF65D6A6),
    successSoft: Color(0xFF15352B),
    warning: Color(0xFFD8CB8A),
    warningSoft: Color(0xFF2E2C18),
    attention: Color(0xFFF7BE7A),
    attentionSoft: Color(0xFF3B2412),
    error: Color(0xFFFF9AA3),
    errorSoft: Color(0xFF3A2027),
  );

  /// Page background.
  final Color canvas;

  /// Cards, composer, sheets.
  final Color surface;

  /// Overlays that sit above [surface] in dark mode.
  final Color raised;

  /// User messages and quiet grouping.
  final Color inset;

  /// The selected row in a list.
  final Color selected;

  final Color text;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color borderStrong;

  /// The single accent. Marks actions and focus.
  final Color primary;
  final Color primaryHover;
  final Color primarySoft;
  final Color onPrimary;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;

  /// A decision is waiting on the user. The only state allowed to fill a card.
  final Color attention;
  final Color attentionSoft;

  final Color error;
  final Color errorSoft;

  @override
  AriaColors copyWith({
    Color? canvas,
    Color? surface,
    Color? raised,
    Color? inset,
    Color? selected,
    Color? text,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? primaryHover,
    Color? primarySoft,
    Color? onPrimary,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? attention,
    Color? attentionSoft,
    Color? error,
    Color? errorSoft,
  }) => AriaColors(
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    raised: raised ?? this.raised,
    inset: inset ?? this.inset,
    selected: selected ?? this.selected,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    border: border ?? this.border,
    borderStrong: borderStrong ?? this.borderStrong,
    primary: primary ?? this.primary,
    primaryHover: primaryHover ?? this.primaryHover,
    primarySoft: primarySoft ?? this.primarySoft,
    onPrimary: onPrimary ?? this.onPrimary,
    success: success ?? this.success,
    successSoft: successSoft ?? this.successSoft,
    warning: warning ?? this.warning,
    warningSoft: warningSoft ?? this.warningSoft,
    attention: attention ?? this.attention,
    attentionSoft: attentionSoft ?? this.attentionSoft,
    error: error ?? this.error,
    errorSoft: errorSoft ?? this.errorSoft,
  );

  @override
  AriaColors lerp(AriaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AriaColors(
      canvas: mix(canvas, other.canvas),
      surface: mix(surface, other.surface),
      raised: mix(raised, other.raised),
      inset: mix(inset, other.inset),
      selected: mix(selected, other.selected),
      text: mix(text, other.text),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      border: mix(border, other.border),
      borderStrong: mix(borderStrong, other.borderStrong),
      primary: mix(primary, other.primary),
      primaryHover: mix(primaryHover, other.primaryHover),
      primarySoft: mix(primarySoft, other.primarySoft),
      onPrimary: mix(onPrimary, other.onPrimary),
      success: mix(success, other.success),
      successSoft: mix(successSoft, other.successSoft),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      attention: mix(attention, other.attention),
      attentionSoft: mix(attentionSoft, other.attentionSoft),
      error: mix(error, other.error),
      errorSoft: mix(errorSoft, other.errorSoft),
    );
  }
}

/// Shorthand for `Theme.of(context).extension<AriaColors>()!`.
extension AriaColorsContext on BuildContext {
  AriaColors get ariaColors =>
      Theme.of(this).extension<AriaColors>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AriaColors.dark()
          : AriaColors.light());
}
