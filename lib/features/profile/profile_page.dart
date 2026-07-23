import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import 'host_packages_page.dart';
import 'host_registration_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

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
              // FEJLÉC
              const Text(
                'Profil & Fiók 👤',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // BEJELENTKEZÉS / REGISZTRÁCIÓ KÁRTYA
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person_outline_rounded, color: accent, size: 32),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vendég Fiók',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Jelentkezz be a kedvencek és foglalások kezeléséhez.',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // BEJELENTKEZÉS / REGISZTRÁCIÓ GOMB
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.login_rounded, color: Colors.black),
                  label: const Text(
                    'Bejelentkezés / Regisztráció',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // HEGYGO PARTNER SZEKCIÓ
              const Text(
                'HegyGO Partner Program 🌲',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // SZÁLLÁSADÓ REGISZTRÁCIÓ
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                tileColor: Colors.black.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white12),
                ),
                leading: const Icon(Icons.add_business_rounded, color: accent),
                title: const Text(
                  'Szálláshely regisztrációja',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Hirdesd szállásodat jutalékmentesen',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HostRegistrationPage()),
                  );
                },
              ),

              const SizedBox(height: 10),

              // CSOMAGOK ÉS ÁRAK
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                tileColor: Colors.black.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white12),
                ),
                leading: const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
                title: const Text(
                  'Partner Csomagok & Hirdetések',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Tekintsd meg a szállásadói és vállalkozói opciókat',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HostPackagesPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}