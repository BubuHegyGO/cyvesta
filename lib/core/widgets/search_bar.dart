import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // Modern színkezelés .withValues() használatával
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.white70,
            size: 28,
          ),

          SizedBox(width: 15),

          Expanded(
            child: Text(
              'Magyarország melyik részére mennél?',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}