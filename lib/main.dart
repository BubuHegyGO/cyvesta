import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/localization/app_language.dart';
import 'core/services/auth_state.dart';
import 'features/home/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    // Munkamenet-figyelő indítása: újraindítás után is megmarad a bejelentkezés
    AuthState.init();
  } catch (e) {
    debugPrint('Firebase init warning: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          key: ValueKey(locale),
          title: 'CYVESTA',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF061822),
            fontFamily: 'Roboto',
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}