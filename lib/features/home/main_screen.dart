import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../favorites/favorites_page.dart';
import '../map/map_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';
import 'home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MapPage(),
    const FavoritesPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final lang = locale;

        // Nyelvek szerinti alsó menü feliratok
        String homeLabel = 'Kezdőlap';
        String mapLabel = 'Térkép';
        String favLabel = 'Kedvencek';
        String alertsLabel = 'Értesítések';
        String profileLabel = 'Fiók';

        if (lang == 'en') {
          homeLabel = 'Home';
          mapLabel = 'Map';
          favLabel = 'Favorites';
          alertsLabel = 'Alerts';
          profileLabel = 'Profile';
        } else if (lang == 'ru') {
          homeLabel = 'Главная';
          mapLabel = 'Карта';
          favLabel = 'Избранное';
          alertsLabel = 'Уведомления';
          profileLabel = 'Профиль';
        } else if (lang == 'de') {
          homeLabel = 'Startseite';
          mapLabel = 'Karte';
          favLabel = 'Favoriten';
          alertsLabel = 'Benachrichtigungen';
          profileLabel = 'Profil';
        } else if (lang == 'el') {
          homeLabel = 'Αρχική';
          mapLabel = 'Χάρτης';
          favLabel = 'Αγαπημένα';
          alertsLabel = 'Ειδοποιήσεις';
          profileLabel = 'Προφίλ';
        }

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: _pages[_currentIndex],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF99FF99), width: 1.2),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF061822),
              selectedItemColor: const Color(0xFF99FF99),
              unselectedItemColor: Colors.white54,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: homeLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.map_rounded),
                  label: mapLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite_rounded),
                  label: favLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.notifications_rounded),
                  label: alertsLabel,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_rounded),
                  label: profileLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}