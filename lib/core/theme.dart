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
      textTheme: const TextTheme(
        // Tier 1: 15 px (Headers & Titles)
        headlineLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        headlineMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        headlineSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        titleLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),

        // Tier 2: 12 px (Body, Inputs, Buttons, Subtitles)
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        bodyLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.primaryText),
        bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.secondaryText),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryText),

        // Tier 3: 10 px (Captions, Badges, Timestamps, Metadata)
        bodySmall: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: AppColors.secondaryText),
        labelMedium: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.secondaryText),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 12,
          color: AppColors.secondaryText,
          height: 1.4,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.background,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryText,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          side: const BorderSide(color: AppColors.border),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: AppColors.background,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(
          color: AppColors.secondaryText.withValues(alpha: 0.6),
          fontSize: 12,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 12,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        helperStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 10,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
