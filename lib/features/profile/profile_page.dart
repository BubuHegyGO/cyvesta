import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'host_registration_page.dart';
import '../accommodation/presentation/add_accommodation_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  bool _isHost = false; // Szállásadó státusz

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FEJLÉC & FELHASZNÁLÓI PROFIL
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 2),
                      color: Colors.black38,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vendég Felhasználó',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isHost ? 'HegyGO Szállásadó 🏡' : 'Hegyvidéki Felfedező 🌲',
                        style: TextStyle(
                          color: _isHost ? accent : Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),

              // SZÁLLÁSADÓI MENÜ SZEKCIÓ
              const Text(
                'Szállásadói Menü',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              if (!_isHost) ...[
                // REGISZTRÁCIÓ SZÁLLÁSADÓNAK (NTAK SZÁMMAL)
                _buildMenuTile(
                  icon: Icons.storefront_rounded,
                  title: 'Legyél Szállásadó!',
                  subtitle: 'Regisztráld szálláshelyedet NTAK számmal',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HostRegistrationPage(),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _isHost = true;
                      });
                    }
                  },
                ),
              ] else ...[
                // ÚJ SZÁLLÁS FELTÖLTÉSE GOMB (HA MÁR SZÁLLÁSADÓ)
                _buildMenuTile(
                  icon: Icons.add_home_work_rounded,
                  title: 'Új Szálláshely Feltöltése',
                  subtitle: 'Tölts fel új szállást ellenőrzésre',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAccommodationPage(),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 24),

              // ADMIN MODERÁCIÓS SZEKCIÓ
              const Text(
                'Rendszergazda',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuTile(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Admin Moderáció',
                subtitle: 'Új szálláshelyek és NTAK adatok ellenőrzése',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardPage(),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),

              const SizedBox(height: 24),

              // BEÁLLÍTÁSOK & FIÓK
              const Text(
                'Beállítások',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuTile(
                icon: Icons.person_outline_rounded,
                title: 'Személyes Adatok',
                subtitle: 'Név, email és telefonszám módosítása',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Értesítések',
                subtitle: 'Foglalási és rendszerértesítések',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Súgó & Kapcsolat',
                subtitle: 'Gyakori kérdések és ügyfélszolgálat',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white38,
        ),
        onTap: onTap,
      ),
    );
  }
}