import 'package:flutter/material.dart';

class CyvestaScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const CyvestaScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  static const Color darkBg = Color(0xFF061822);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // 1. TENGERI HÁTTÉRKÉP
          Positioned.fill(
            child: Image.asset(
              'assets/icons/backroundimage.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: darkBg),
            ),
          ),

          // 2. SÖTÉTÍTŐ KONTRASZT RÉTEG
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    darkBg.withValues(alpha: 0.85),
                    darkBg.withValues(alpha: 0.40),
                    darkBg.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // 3. TARTALOM
          SafeArea(
            child: body,
          ),
        ],
      ),
    );
  }
}