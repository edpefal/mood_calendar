import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_colors.dart';

/// Builds the app's [ThemeData] for one brightness from its [BrandPalette].
ThemeData buildAppTheme(Brightness brightness) {
  final palette =
      brightness == Brightness.dark ? BrandPalette.dark : BrandPalette.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: palette.ink,
    brightness: brightness,
  ).copyWith(
    primary: palette.ink,
    onPrimary: palette.onInk,
    surface: palette.background,
    onSurface: palette.text,
    onSurfaceVariant: palette.textSecondary,
    error: palette.danger,
    outline: palette.textSecondary,
    outlineVariant: palette.glassBorder,
    // Material derives its dialogs and pickers from these; keep them neutral
    // instead of the seed's tonal blues and purples.
    primaryContainer: palette.ink.withValues(alpha: 0.14),
    onPrimaryContainer: palette.text,
    secondaryContainer: palette.ink.withValues(alpha: 0.14),
    onSecondaryContainer: palette.text,
    tertiaryContainer: palette.ink.withValues(alpha: 0.14),
    onTertiaryContainer: palette.text,
    surfaceContainerHigh: palette.isDark ? palette.tabBar : Colors.white,
    surfaceContainerHighest:
        palette.isDark ? const Color(0xFF303037) : const Color(0xFFEFEFF3),
  );
  final base = ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: palette.background,
    canvasColor: palette.background,
    extensions: [palette],
  );
  final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
    bodyColor: palette.text,
    displayColor: palette.text,
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: palette.text,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor:
          palette.isDark ? palette.glassOpaque : palette.background,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black.withValues(alpha: 0.4),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.isDark ? palette.tabBar : palette.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: palette.isDark ? palette.onTabBar : palette.onInk,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.onInk
            : palette.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.ink
            : palette.glassBorder,
      ),
    ),
    dividerColor: palette.glassBorder,
    dialogTheme: DialogThemeData(
      backgroundColor: palette.isDark ? palette.tabBar : Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: palette.isDark ? palette.tabBar : Colors.white,
      hourMinuteTextColor: palette.text,
      dayPeriodTextColor: palette.text,
      dialHandColor: palette.ink,
      dialTextColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.onInk
            : palette.text,
      ),
      entryModeIconColor: palette.text,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.text),
    ),
  );
}
