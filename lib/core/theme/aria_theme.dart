import 'package:material_ui/material_ui.dart';

import 'aria_colors.dart';
import 'aria_tokens.dart';
import 'aria_type.dart';

/// Builds the one theme, entirely from the tokens in this directory.
///
/// Dark is the product's own face; light is a complete second configuration,
/// not a filter over it.
ThemeData buildAriaTheme({
  required Brightness brightness,
  required bool chinese,
}) {
  final AriaColors colors = brightness == Brightness.dark
      ? AriaColors.dark()
      : AriaColors.light();
  final AriaType type = chinese ? AriaType.zh() : AriaType.latin();

  final ColorScheme scheme = ColorScheme(
    brightness: brightness,
    primary: colors.gold,
    onPrimary: colors.goldInk,
    primaryContainer: colors.goldSoft,
    onPrimaryContainer: colors.gold,
    secondary: colors.ink2,
    onSecondary: colors.ground,
    secondaryContainer: colors.panel2,
    onSecondaryContainer: colors.ink,
    error: colors.danger,
    onError: colors.ground,
    errorContainer: colors.dangerSoft,
    onErrorContainer: colors.danger,
    surface: colors.ground,
    onSurface: colors.ink,
    onSurfaceVariant: colors.ink2,
    outline: colors.panel3,
    outlineVariant: colors.panel2,
    shadow: const Color(0xFF000000),
    scrim: colors.scrim,
    inverseSurface: colors.key,
    onInverseSurface: colors.keyInk,
    inversePrimary: colors.goldFill,
    surfaceTint: Colors.transparent,
  );

  TextStyle onGround(TextStyle style) => style.copyWith(color: colors.ink);

  final TextTheme textTheme = TextTheme(
    displayLarge: onGround(type.hero),
    displayMedium: onGround(type.hero),
    displaySmall: onGround(type.headline),
    headlineLarge: onGround(type.headline),
    headlineMedium: onGround(type.sheetTitle),
    headlineSmall: onGround(type.title),
    titleLarge: onGround(type.title),
    titleMedium: onGround(type.label),
    titleSmall: onGround(type.label),
    bodyLarge: onGround(type.body),
    bodyMedium: onGround(type.ui),
    bodySmall: onGround(type.caption),
    labelLarge: onGround(type.label),
    labelMedium: onGround(type.label),
    labelSmall: onGround(type.tiny),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Inter',
    fontFamilyFallback: const <String>[
      'PingFang SC',
      'Noto Sans CJK SC',
      'Microsoft YaHei',
    ],
    scaffoldBackgroundColor: colors.ground,
    canvasColor: colors.ground,
    dividerColor: colors.panel,
    textTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[colors, type],
    splashFactory: InkRipple.splashFactory,
    highlightColor: colors.panel2,
    hoverColor: colors.panel,
    focusColor: colors.goldSoft,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.gold,
      selectionColor: colors.goldSoft,
      selectionHandleColor: colors.gold,
    ),
    iconTheme: IconThemeData(color: colors.ink2, size: 20),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.ground,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: onGround(type.chatTitle),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.key,
        foregroundColor: colors.keyInk,
        disabledBackgroundColor: colors.panel,
        disabledForegroundColor: colors.muted,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        textStyle: type.label,
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.pillAll),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.panel,
        foregroundColor: colors.ink,
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        textStyle: type.label,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.pillAll),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.ink2,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: type.ui,
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.smAll),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.panel, thickness: 1, space: 1),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.sheet,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: colors.sheet,
      modalBarrierColor: colors.scrim,
      elevation: 0,
      modalElevation: 0,
      showDragHandle: false,
      dragHandleColor: colors.panel3,
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.sheetTop),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.sheet,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.xxlAll),
      titleTextStyle: onGround(type.sheetTitle),
      contentTextStyle: onGround(type.small),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.muted,
      textColor: colors.ink,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.lgAll),
      minVerticalPadding: 10,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.panel,
      hintStyle: type.body.copyWith(color: colors.muted),
      labelStyle: type.ui.copyWith(color: colors.muted),
      floatingLabelStyle: type.caption.copyWith(color: colors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide(color: colors.focus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide(color: colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide(color: colors.danger, width: 2),
      ),
      errorStyle: type.caption.copyWith(color: colors.danger),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.gold,
      linearTrackColor: colors.panel,
      circularTrackColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.key,
      contentTextStyle: type.small.copyWith(color: colors.keyInk),
      actionTextColor: colors.keyInk,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.xlAll),
      insetPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colors.panel3,
        borderRadius: AriaRadius.smAll,
      ),
      textStyle: type.caption.copyWith(color: colors.ink),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll<Color>(colors.panel3),
      radius: const Radius.circular(999),
      thickness: const WidgetStatePropertyAll<double>(2),
      crossAxisMargin: 2,
    ),
  );
}
