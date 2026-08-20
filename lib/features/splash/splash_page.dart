import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../home/main_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 360 fokos Y-tengelyű forgás
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
      ),
    );

    // Szöveg lágy megjelenése
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _animController.forward();

    // 2.3 mp múlva átlépés a főoldalra
    Timer(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, anim, secondaryAnim) => const MainScreen(),
            transitionsBuilder: (context, anim, secondaryAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061822),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Tengeri háttérkép
          Image.asset(
            'assets/images/backroundimage.png',
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(color: const Color(0xFF061822)),
          ),

          // Finom sötétítő réteg a fehér felirat kontrasztjáért
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF061822).withValues(alpha: 0.45),
                  Colors.transparent,
                  const Color(0xFF061822).withValues(alpha: 0.35),
                ],
              ),
            ),
          ),

          // Középső animáció: árnyék nélküli forgó logó + fehér felirat
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateY(_rotationAnimation.value),
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Image.asset(
                          'assets/icons/app_icon.png',
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Image.asset('assets/icons/logowhite.png', fit: BoxFit.contain),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFadeAnimation.value,
                      child: Transform.scale(
                        scale: _textScaleAnimation.value,
                        child: const Column(
                          children: [
                            Text(
                              'CYVESTA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 5.0,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'CYPRUS PROPERTY & TRAVEL',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}