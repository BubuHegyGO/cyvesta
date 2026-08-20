import 'package:flutter/material.dart';
import 'core/localization/app_language.dart';
import 'features/home/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // EZ A KULCS: Amikor a nyelv változik, az EGÉSZ app újrarenderelődik a választott nyelven!
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          key: ValueKey(locale), // Erőszakos teljes UI újraépítés nyelvváltáskor!
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