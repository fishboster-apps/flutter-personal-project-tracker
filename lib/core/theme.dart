import 'package:flutter/material.dart';

/// PRD-defined color tokens for Personal Project Tracker.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF252528);
  static const Color primaryAccent = Color(0xFF8B9CF6);
  static const Color primaryText = Color(0xFFF5F5F5);
  static const Color secondaryText = Color(0xFFA1A1AA);
  static const Color border = Color(0xFF343438);
  static const Color success = Color(0xFF81C995);
  static const Color warning = Color(0xFFE9B96E);
  static const Color error = Color(0xFFE98282);
}

/// Minimalist Dark Theme configuration adhering to Material 3.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primaryAccent,
      onPrimary: AppColors.background,
      onSurface: AppColors.primaryText,
      error: AppColors.error,
      onError: AppColors.background,
      outline: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.background,
      ),
    );
  }
}
