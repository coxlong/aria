import 'package:material_ui/material_ui.dart';

/// Aria's color tokens, straight from the design.
///
/// One continuous ground, surfaces made of light rather than lines, and a
/// single warm accent that means Aria is present or waiting.
@immutable
final class AriaColors extends ThemeExtension<AriaColors> {
  const AriaColors({
    required this.ground,
    required this.sheet,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.panel,
    required this.panel2,
    required this.panel3,
    required this.panelDeep,
    required this.gold,
    required this.goldFill,
    required this.goldInk,
    required this.goldSoft,
    required this.goldGlow,
    required this.danger,
    required this.dangerSoft,
    required this.key,
    required this.keyInk,
    required this.keyMuted,
    required this.focus,
    required this.scrim,
  });

  factory AriaColors.dark() => const AriaColors(
    ground: Color(0xFF09090B),
    sheet: Color(0xFF151517),
    ink: Color(0xFFF6F4EF),
    ink2: Color(0xFFD0CDC6),
    muted: Color(0xFF9B9891),
    // Surfaces are light, not lines: translucent white over the ground.
    panel: Color(0x0EFFFFFF),
    panel2: Color(0x17FFFFFF),
    panel3: Color(0x24FFFFFF),
    panelDeep: Color(0x4D000000),
    gold: Color(0xFFF0BA79),
    goldFill: Color(0xFFF0BA79),
    goldInk: Color(0xFF1A1105),
    goldSoft: Color(0x21F0BA79),
    goldGlow: Color(0x66F0BA79),
    danger: Color(0xFFFF9B8F),
    dangerSoft: Color(0x1FFF9B8F),
    key: Color(0xFFF5F3EE),
    keyInk: Color(0xFF0B0B0C),
    keyMuted: Color(0x9E0B0B0C),
    focus: Color(0xFFF0BA79),
    scrim: Color(0x94040405),
  );

  factory AriaColors.light() => const AriaColors(
    ground: Color(0xFFF4F4F1),
    sheet: Color(0xFFFCFCF9),
    ink: Color(0xFF131416),
    ink2: Color(0xFF3B3D41),
    muted: Color(0xFF636569),
    panel: Color(0x0E101113),
    panel2: Color(0x16101113),
    panel3: Color(0x21101113),
    panelDeep: Color(0x0D101113),
    gold: Color(0xFF8A570F),
    goldFill: Color(0xFF9C6318),
    goldInk: Color(0xFFFFF8EC),
    goldSoft: Color(0x1A8F5C12),
    goldGlow: Color(0x47A86C1C),
    danger: Color(0xFFA33228),
    dangerSoft: Color(0x17A33228),
    key: Color(0xFF141518),
    keyInk: Color(0xFFF7F6F2),
    keyMuted: Color(0xA8F7F6F2),
    focus: Color(0xFF8F5C12),
    scrim: Color(0x94040405),
  );

  /// The page.
  final Color ground;

  /// A sheet lifted off the page.
  final Color sheet;

  /// Primary text.
  final Color ink;

  /// Body text.
  final Color ink2;

  /// Quiet labels, metadata.
  final Color muted;

  /// The first surface: a whisper of light over the ground.
  final Color panel;

  /// The second surface: hover, pressed, user bubbles.
  final Color panel2;

  /// The third surface: the strongest quiet fill.
  final Color panel3;

  /// A well set into the page: code, input frames.
  final Color panelDeep;

  /// The one accent, as text.
  final Color gold;

  /// The one accent, as a fill.
  final Color goldFill;

  /// Text and icons on [goldFill].
  final Color goldInk;

  /// A quiet gold-washed surface.
  final Color goldSoft;

  /// The halo around something live.
  final Color goldGlow;

  final Color danger;
  final Color dangerSoft;

  /// The high-contrast surface: primary buttons, selected rows.
  final Color key;

  /// Text on [key].
  final Color keyInk;

  /// Secondary text on [key].
  final Color keyMuted;

  final Color focus;
  final Color scrim;

  // ── Older names, kept as aliases while the screens migrate ──────────────

  Color get canvas => ground;
  Color get surface => panel;
  Color get raised => panel2;
  Color get inset => panel;
  Color get selected => key;
  Color get text => ink;
  Color get textSecondary => ink2;
  Color get textMuted => muted;
  Color get border => panel;
  Color get borderStrong => panel3;
  Color get primary => gold;
  Color get primaryHover => goldFill;
  Color get primarySoft => goldSoft;
  Color get onPrimary => goldInk;
  Color get success => ink2;
  Color get successSoft => panel;
  Color get warning => gold;
  Color get warningSoft => goldSoft;
  Color get attention => gold;
  Color get attentionSoft => goldSoft;
  Color get error => danger;
  Color get errorSoft => dangerSoft;

  @override
  AriaColors copyWith({
    Color? ground,
    Color? sheet,
    Color? ink,
    Color? ink2,
    Color? muted,
    Color? panel,
    Color? panel2,
    Color? panel3,
    Color? panelDeep,
    Color? gold,
    Color? goldFill,
    Color? goldInk,
    Color? goldSoft,
    Color? goldGlow,
    Color? danger,
    Color? dangerSoft,
    Color? key,
    Color? keyInk,
    Color? keyMuted,
    Color? focus,
    Color? scrim,
  }) => AriaColors(
    ground: ground ?? this.ground,
    sheet: sheet ?? this.sheet,
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    muted: muted ?? this.muted,
    panel: panel ?? this.panel,
    panel2: panel2 ?? this.panel2,
    panel3: panel3 ?? this.panel3,
    panelDeep: panelDeep ?? this.panelDeep,
    gold: gold ?? this.gold,
    goldFill: goldFill ?? this.goldFill,
    goldInk: goldInk ?? this.goldInk,
    goldSoft: goldSoft ?? this.goldSoft,
    goldGlow: goldGlow ?? this.goldGlow,
    danger: danger ?? this.danger,
    dangerSoft: dangerSoft ?? this.dangerSoft,
    key: key ?? this.key,
    keyInk: keyInk ?? this.keyInk,
    keyMuted: keyMuted ?? this.keyMuted,
    focus: focus ?? this.focus,
    scrim: scrim ?? this.scrim,
  );

  @override
  AriaColors lerp(AriaColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? b;
    return AriaColors(
      ground: mix(ground, other.ground),
      sheet: mix(sheet, other.sheet),
      ink: mix(ink, other.ink),
      ink2: mix(ink2, other.ink2),
      muted: mix(muted, other.muted),
      panel: mix(panel, other.panel),
      panel2: mix(panel2, other.panel2),
      panel3: mix(panel3, other.panel3),
      panelDeep: mix(panelDeep, other.panelDeep),
      gold: mix(gold, other.gold),
      goldFill: mix(goldFill, other.goldFill),
      goldInk: mix(goldInk, other.goldInk),
      goldSoft: mix(goldSoft, other.goldSoft),
      goldGlow: mix(goldGlow, other.goldGlow),
      danger: mix(danger, other.danger),
      dangerSoft: mix(dangerSoft, other.dangerSoft),
      key: mix(key, other.key),
      keyInk: mix(keyInk, other.keyInk),
      keyMuted: mix(keyMuted, other.keyMuted),
      focus: mix(focus, other.focus),
      scrim: mix(scrim, other.scrim),
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
