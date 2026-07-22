// ======================================================
// HegyGO
// File: lib/core/theme/app_text_styles.dart
// ======================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heroWhite = TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.05,
  );

  static const TextStyle heroGreen = TextStyle(
    fontSize: 46,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.05,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle searchHint = TextStyle(
    fontSize: 18,
    color: Colors.white70,
  );

  static const TextStyle bottomNavigation = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}