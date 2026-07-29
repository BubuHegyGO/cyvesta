import 'package:flutter/material.dart';
import 'package:hegygo/features/profile/edit_profile_page.dart';
import 'package:hegygo/features/profile/host_registration_page.dart';
import 'package:hegygo/features/profile/admin_dashboard_page.dart';
import 'package:hegygo/features/accommodation/presentation/my_accommodations_page.dart';
import 'package:hegygo/features/favorites/favorites_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D160E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A1E),
        elevation: 0,
        title: const Text(
          'Profil & Beállítások',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FEJLÉC PROFIL KÁRTYA (BENDEGÚZ) -> KATTINTHATÓ
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A261C),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Color(0xFF8BC541),
                          child: Icon(Icons.person, size: 36, color: Colors.white),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Color(0xFFFFC107),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Bendegúz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.verified, color: Color(0xFFFFC107), size: 18),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'bendeguz@hegygo.hu',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(Icons.check_circle, color: Color(0xFFFFC107), size: 14),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Igazolt Szállásadó & Vállalkozás',
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. SZÁLLÁSADÓ / ÜZLET REGISZTRÁCIÓ
            _buildMenuItem(
              icon: Icons.storefront,
              title: 'Szállásadó / Üzlet Regisztráció',
              subtitle: 'NTAK szám / Adószám megadása és elbírálás',
              borderColor: const Color(0xFFFFC107),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HostRegistrationPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // 3. ADMINISZTRÁCIÓS DASHBOARD
            _buildMenuItem(
              icon: Icons.admin_panel_settings,
              title: 'Adminisztrációs Dashboard',
              subtitle: 'Beküldött NTAK és Adószámok elbírálása',
              borderColor: Colors.redAccent,
              iconColor: Colors.redAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // AKTIVITÁS SZEKCIÓ
            const Text(
              'Aktivitás',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A261C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.home_work_outlined,
                    title: 'Saját Szállásaim',
                    subtitle: 'Hirdetések kezelése és új szállás feladása',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyAccommodationsPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _buildListTile(
                    icon: Icons.favorite_border,
                    title: 'Kedvencek',
                    subtitle: 'Elmentett szállások és élmények',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _buildListTile(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Foglalásaim',
                    subtitle: 'Aktív és korábbi foglalások',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('A foglalások lista hamarosan elérhető!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FIÓK KEZELÉSE SZEKCIÓ
            const Text(
              'Fiók Kezelése',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A261C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.logout,
                    title: 'Kijelentkezés',
                    titleColor: const Color(0xFFFFC107),
                    iconColor: const Color(0xFFFFC107),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sikeres kijelentkezés!'),
                          backgroundColor: Color(0xFF8BC541),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  _buildListTile(
                    icon: Icons.delete_forever,
                    title: 'Teszt Profil Törlése',
                    subtitle: 'Fiók törlése és kijelentkezés a Regisztrációhoz',
                    titleColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil törölve!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color borderColor = const Color(0xFF8BC541),
    Color iconColor = const Color(0xFFFFC107),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A261C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFFFFC107),
    Color titleColor = Colors.white,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }
}