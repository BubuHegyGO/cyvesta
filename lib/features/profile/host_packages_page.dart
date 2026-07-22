import 'package:flutter/material.dart';

class HostPackagesPage extends StatefulWidget {
  const HostPackagesPage({super.key});

  @override
  State<HostPackagesPage> createState() => _HostPackagesPageState();
}

class _HostPackagesPageState extends State<HostPackagesPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  int _selectedTab = 0; // 0 = Szállásadó, 1 = Helyi Vállalkozó/Hirdető

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HegyGO Partner Csomagok',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FEJLÉC BANNER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.25), Colors.black45],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: accent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        '0% Jutalék. 100% Haszon.',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nálunk nincsenek rejtett foglalási jutalékok. Csatlakozz fix havi vagy éves díjjal, és tartsd meg a bevételed 100%-át!',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CSOPORT VÁLASZTÓ TABOK
            Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    title: 'Szállásadóknak',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    title: 'Helyi Vállalkozóknak',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CSOMAGOK LISTÁJA
            if (_selectedTab == 0) ...[
              // SZÁLLÁSADÓI CSOMAGOK
              _buildPackageCard(
                title: 'HegyGO Host Alap',
                price: '4.990 Ft / hó',
                badge: 'Kezdő',
                badgeColor: Colors.grey,
                features: const [
                  '1 szálláshely listázása',
                  'Közvetlen hívás és e-mail kapcsolat',
                  'NTAK ellenőrzött státusz',
                  'Saját foglalási naptár',
                  '0% foglalási jutalék',
                ],
                buttonText: 'Alap Csomag Választása',
                isPopular: false,
              ),
              const SizedBox(height: 16),
              _buildPackageCard(
                title: 'HegyGO Host Pro',
                price: '8.990 Ft / hó',
                badge: 'Legnépszerűbb 🌟',
                badgeColor: accent,
                features: const [
                  'Akár 3 szálláshely listázása',
                  'Kiemelt megjelenés a Kezdőlapon',
                  'Kiemelt zöld ikon a Térképen',
                  'In-App Chat közvetlen üzenetküldés',
                  'Részletes látogatottsági statisztika',
                  '0% foglalási jutalék',
                ],
                buttonText: 'Pro Csomag Indítása',
                isPopular: true,
              ),
            ] else ...[
              // VÁLLALKOZÓI / HIRDETŐI CSOMAGOK
              _buildPackageCard(
                title: 'Helyi Partner Banner',
                price: '9.900 Ft / hó',
                badge: 'Élményszolgáltató',
                badgeColor: Colors.orangeAccent,
                features: const [
                  'Kiemelt hirdetés az Élménymodulban',
                  'Közvetlen útvonaltervezés és hívás gomb',
                  'Képes bemutatkozó kártya a térképen',
                  'Kupon / Kedvezmény megjelenítés a vendégeknek',
                ],
                buttonText: 'Partner Hirdetés Indítása',
                isPopular: false,
              ),
              const SizedBox(height: 16),
              _buildPackageCard(
                title: 'Prémium Régió Sponsor',
                price: '19.900 Ft / hó',
                badge: 'Exkluzív 🚀',
                badgeColor: Colors.purpleAccent,
                features: const [
                  'Főoldali top banner hirdetés',
                  'Értesítési kiküldés a környéken tartózkodóknak',
                  'Kiemelt szponzor státusz a Mátrai kalauzban',
                  'Korlátlan promóció frissítés',
                ],
                buttonText: 'Szponzori Csatlakozás',
                isPopular: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? accent : Colors.white12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    required String badge,
    required Color badgeColor,
    required List<String> features,
    required String buttonText,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? accent : Colors.white12,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(color: accent, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          Column(
            children: features.map((f) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: accent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular ? accent : Colors.white12,
                foregroundColor: isPopular ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF0D2113),
                    content: Text(
                      'Megrendelési szándék rögzítve: $title',
                      style: const TextStyle(color: accent, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}