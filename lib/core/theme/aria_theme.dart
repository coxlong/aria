import 'package:material_ui/material_ui.dart';

import 'aria_colors.dart';
import 'aria_tokens.dart';
import 'aria_type.dart';

/// Builds the one theme, entirely from the token layer in this directory.
///
/// Two complete configurations are produced — light and dark — and the type
/// scale is built for the active language, so Chinese gets its own leading and
/// tracking without any widget knowing about it.
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
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    primaryContainer: colors.primarySoft,
    onPrimaryContainer: colors.primary,
    secondary: colors.textSecondary,
    onSecondary: colors.surface,
    secondaryContainer: colors.inset,
    onSecondaryContainer: colors.text,
    error: colors.error,
    onError: colors.surface,
    errorContainer: colors.errorSoft,
    onErrorContainer: colors.error,
    surface: colors.surface,
    onSurface: colors.text,
    onSurfaceVariant: colors.textSecondary,
    outline: colors.borderStrong,
    outlineVariant: colors.border,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: colors.text,
    onInverseSurface: colors.surface,
    inversePrimary: colors.primarySoft,
    surfaceTint: Colors.transparent,
  );

  TextStyle onCanvas(TextStyle style) => style.copyWith(color: colors.text);

  final TextTheme textTheme = TextTheme(
    displayLarge: onCanvas(type.display),
    displayMedium: onCanvas(type.display),
    displaySmall: onCanvas(type.headline),
    headlineLarge: onCanvas(type.headline),
    headlineMedium: onCanvas(type.title),
    headlineSmall: onCanvas(type.title),
    titleLarge: onCanvas(type.title),
    titleMedium: onCanvas(type.label),
    titleSmall: onCanvas(type.label),
    bodyLarge: onCanvas(type.body),
    bodyMedium: onCanvas(type.ui),
    bodySmall: onCanvas(type.caption),
    labelLarge: onCanvas(type.label),
    labelMedium: onCanvas(type.label),
    labelSmall: onCanvas(type.caption),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.canvas,
    canvasColor: colors.canvas,
    dividerColor: colors.border,
    textTheme: textTheme,
    extensions: <ThemeExtension<dynamic>>[colors, type],
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.canvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AriaSpacing.md,
      toolbarHeight: 56,
      titleTextStyle: onCanvas(type.title),
      shape: Border(bottom: BorderSide(color: colors.border)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AriaSpacing.md,
          vertical: AriaSpacing.xs,
        ),
        textStyle: type.label,
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.mdAll),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: colors.text,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AriaSpacing.md,
          vertical: AriaSpacing.xs,
        ),
        textStyle: type.label,
        side: BorderSide(color: colors.borderStrong),
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.mdAll),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AriaSpacing.sm,
          vertical: AriaSpacing.xs,
        ),
        textStyle: type.label,
        shape: const RoundedRectangleBorder(borderRadius: AriaRadius.mdAll),
      ),
    ),
    iconTheme: IconThemeData(color: colors.textSecondary, size: 20),
    dividerTheme: DividerThemeData(
      color: colors.border,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AriaRadius.xl),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.raised,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.lgAll),
      titleTextStyle: onCanvas(type.title),
      contentTextStyle: onCanvas(type.body),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colors.textSecondary,
      textColor: colors.text,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AriaSpacing.md,
        vertical: AriaSpacing.xxs,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.mdAll),
      minVerticalPadding: AriaSpacing.xs,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      hintStyle: type.body.copyWith(color: colors.textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AriaSpacing.md,
        vertical: AriaSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide(color: colors.borderStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide(color: colors.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AriaRadius.mdAll,
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.primary,
      linearTrackColor: colors.inset,
      circularTrackColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.text,
      contentTextStyle: type.ui.copyWith(color: colors.canvas),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AriaRadius.mdAll),
    ),
  );
}
