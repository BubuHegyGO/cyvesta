import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  bool _isLoggedIn = true; // Teszteléshez: be van-e jelentkezve

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: accent, width: 1.5),
        ),
        title: const Text(
          'Kijelentkezés',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Biztosan ki szeretnél jelentkezni a fiókodból?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégse', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isLoggedIn = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sikeresen kijelentkeztél!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Kijelentkezés', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        // 🔑 1. KÉK IKON TÖRÖLVE A CÍMSORBÓL
        title: const Text(
          'Profil & Beállítások',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔑 2. ZÖLD ID KÁRTYA IKON & PROFIL ADATOK / KIJELENTKEZETT ÁLLAPOT
              if (_isLoggedIn)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      // Nagy Zöld ID Kártya Ikon
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2),
                        ),
                        child: const Icon(
                          Icons.badge_rounded, // 🔑 Zöld ID kártya ikon
                          color: accent,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bendegúz',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'bendeguz@hegygo.hu',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.verified_rounded, color: accent, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Igazolt Szállásadó & Vendég',
                                  style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Kijelentkezett állapot felülete
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle_outlined, color: Colors.white38, size: 60),
                      const SizedBox(height: 12),
                      const Text(
                        'Nincs bejelentkezett fiók',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Jelentkezz be a saját adataiddal a folytatáshoz!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoggedIn = true; // Visszalépés bejelentkezéshez
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Bejelentkezés / Regisztráció', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                'Aktivitás',
                style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _buildListTile(Icons.home_work_rounded, 'Saját Szállásaim', 'Hirdetések kezelése és új szállás feladása'),
              _buildListTile(Icons.favorite_rounded, 'Kedvencek', 'Elmentett szállások és élmények'),
              _buildListTile(Icons.receipt_long_rounded, 'Foglalásaim', 'Aktív és korábbi foglalások'),

              const SizedBox(height: 20),

              const Text(
                'Beállítások',
                style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _buildListTile(Icons.notifications_rounded, 'Értesítések', 'Foglalási visszajelzések és akciók'),
              _buildListTile(Icons.language_rounded, 'Nyelv', 'Magyar (HU)'),
              _buildListTile(Icons.security_rounded, 'Adatvédelem & Biztonság', 'Jelszó módosítás, adatvédelmi nyilatkozat'),

              const SizedBox(height: 24),

              // 🔑 3. LÉPTESSÉL KI INNEN (KIJELENTKEZÉS GOMB)
              if (_isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Kijelentkezés a fiókból', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
        onTap: () {},
      ),
    );
  }
}