// ======================================================
// CYVESTA
// File: lib/core/theme/app_theme.dart
// ======================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class CyvestaTheme {
  CyvestaTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.mintGreenBorder,
          surface: AppColors.darkBg,
          onPrimary: AppColors.textDark,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.mintGreenBorder),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkBg,
          selectedItemColor: AppColors.mintGreenBorder,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
      );
}

// Visszafelé kompatibilitás korábbi hivatkozásokhoz
typedef HegyGoTheme = CyvestaTheme;