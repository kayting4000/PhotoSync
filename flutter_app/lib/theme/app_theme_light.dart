import 'package:flutter/material.dart';
import 'app_theme.dart';

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7C3AED),
      secondary: Color(0xFF9D4EDD),
      surface: lGlass,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: lBgBase,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: lTextPrimary),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTypography.heading.copyWith(color: lTextPrimary, fontSize: 32),
      headlineMedium: AppTypography.heading.copyWith(color: lTextPrimary, fontSize: 26),
      headlineSmall: AppTypography.subheading.copyWith(color: lTextPrimary, fontSize: 20),
      titleLarge: AppTypography.subheading.copyWith(color: lTextPrimary, fontSize: 18),
      titleMedium: AppTypography.bodyBold.copyWith(color: lTextPrimary, fontSize: 16),
      titleSmall: AppTypography.bodyBold.copyWith(color: lTextPrimary, fontSize: 14),
      bodyLarge: AppTypography.body.copyWith(color: lTextPrimary, fontSize: 16),
      bodyMedium: AppTypography.body.copyWith(color: lTextSecondary, fontSize: 14),
      bodySmall: AppTypography.body.copyWith(color: lTextSecondary, fontSize: 12),
      labelLarge: AppTypography.label.copyWith(color: lTextPrimary, fontSize: 14),
      labelMedium: AppTypography.label.copyWith(color: lTextSecondary, fontSize: 12),
      labelSmall: AppTypography.caption.copyWith(color: lTextTertiary, fontSize: 10),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    dialogBackgroundColor: Colors.transparent,
    popupMenuTheme: PopupMenuThemeData(
      color: lGlass,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: lGlassBorder, thickness: 0.5, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: lGlass,
      labelStyle: AppTypography.caption.copyWith(color: lTextPrimary, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: lGlassBorder),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: AppTypography.label.copyWith(color: lTextPrimary, fontSize: 12),
      unselectedLabelStyle: AppTypography.caption.copyWith(color: lTextSecondary, fontSize: 12),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );
}
