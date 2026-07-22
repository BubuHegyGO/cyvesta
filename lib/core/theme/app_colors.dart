// ======================================================
// HegyGO
// File: lib/core/theme/app_colors.dart
// ======================================================

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF8BC541);
  static const Color primaryDark = Color(0xFF6FA52E);

  // Background
  static const Color background = Color(0xFF07130A);
  static const Color surface = Color(0xFF102117);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBFC7BF);

  // Icons
  static const Color icon = Colors.white;
  static const Color iconActive = primary;

  // Notification badge
  static const Color notification = primary;

  // Glass
  static const Color glass = Color.fromARGB(35, 255, 255, 255);
  static const Color glassBorder = Color.fromARGB(45, 255, 255, 255);

  // Card
  static const Color card = Color(0xFF102117);

  // Shadows
  static const Color shadow = Color.fromARGB(60, 0, 0, 0);

  // Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(40, 0, 0, 0),
      Color.fromARGB(150, 7, 19, 10),
      Color(0xFF07130A),
    ],
  );
}