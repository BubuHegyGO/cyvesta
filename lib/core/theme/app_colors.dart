import 'package:flutter/material.dart';

class AppColors {
  // --- FŐ LAGÚNA ÉS MENTAZÖLD SZÍNEK ---
  static const Color darkBg = Color(0xFF061822);
  static const Color background = darkBg;
  static const Color scaffoldBackground = darkBg;

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color accent = mintGreenBorder;
  static const Color secondary = mintGreenBorder;

  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color primary = Color(0xFF14D1C4);
  static const Color cardBg = turquoiseGlass;

  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);

  static const Color sunnyGold = Color(0xFFFF9F1C);
  static const Color modalBg = Color(0xFF0B2535);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Üveghatású mentazöld kártya stílus
  static BoxDecoration glassCardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: turquoiseGlass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: mintGreenBorder, width: 1.6),
      boxShadow: [
        BoxShadow(
          color: mintGreenBorder.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Fő akciógomb stílus
  static ButtonStyle primaryButtonStyle({double radius = 14}) {
    return ElevatedButton.styleFrom(
      backgroundColor: sunnyGold,
      foregroundColor: textDark,
      elevation: 5,
      side: const BorderSide(color: mintGreenBorder, width: 1.5),
      shadowColor: sunnyGold.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

typedef CyvestaColors = AppColors;