import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hegygo/features/home/main_screen.dart'; // A projekt szerinti főképernyő importja

void main() {
  runApp(const HegyGoApp());
}

class HegyGoApp extends StatelessWidget {
  const HegyGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HegyGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D160E),
      ),
      
      // MAGYAR NYELVI ÉS NAPTÁR LOKALIZÁCIÓ
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('hu', 'HU'),
        Locale('en', 'US'),
      ],
      locale: const Locale('hu', 'HU'),

      home: const MainScreen(),
    );
  }
}