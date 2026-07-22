import 'package:flutter/material.dart';
import 'features/home/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HegyGoApp());
}

class HegyGoApp extends StatelessWidget {
  const HegyGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HegyGO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07130A),
        fontFamily: 'Roboto',
      ),
      // ITT A LÉNYEG: A MainScreen-t adjuk meg kezdőoldalnak!
      home: const MainScreen(),
    );
  }
}