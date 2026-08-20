// ======================================================
// CYVESTA
// File: lib/core/theme/app_text_styles.dart
// ======================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Főcím stílusok (Sötét háttérre)
  static const TextStyle heroWhite = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static const TextStyle heroTurquoise = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.1,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // Kártya stílusok (Türkiz üvegkártyák sötét felirataihoz)
  static const TextStyle cardTitleDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
  );

  static const TextStyle cardSubtitleDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1E293B),
  );

  // Hagyományos kártya stílusok (Fallback / sötét kártyákhoz)
  static const TextStyle cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mintGreenBorder,
  );

  // Törzsszöveg és keresők
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle searchHint = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bottomNavigation = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );
}