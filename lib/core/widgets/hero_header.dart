import 'package:flutter/material.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  static const Color accent = Color(0xFF8BC541);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/hegygo_logo.png',
                  height: 32,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.terrain_rounded, color: accent, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'HegyGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Fedezd fel a Mátra és Bükk kincseit',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}