import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  static const Color accentColor = Color(0xFF8BC541);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. BAL OLDAL: A HegyGO logó megnövelt méretben (~30%-kal nagyobb)
        Image.asset(
          'assets/images/logo.png',
          height: 70, // 52-ről 70-re növelve a látványosabb megjelenésért
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.terrain, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                const Text(
                  'HegyGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),

        // 2. JOBB OLDAL: Csengő értesítő pöttyel
        GestureDetector(
          onTap: () {},
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 32,
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF07130A),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}