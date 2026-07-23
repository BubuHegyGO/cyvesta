import 'package:flutter/material.dart';
import 'widgets/booking_calendar_widget.dart';

class AccommodationDetailPage extends StatelessWidget {
  final Map<String, dynamic> accommodationData;

  const AccommodationDetailPage({
    super.key,
    required this.accommodationData,
  });

  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  @override
  Widget build(BuildContext context) {
    final String title = accommodationData['title'] ?? 'Szálláshely';
    final String location = accommodationData['location'] ?? 'Hegyvidék';
    final String region = accommodationData['region'] ?? 'Magyarország';
    final String rating = accommodationData['rating'] ?? '5.0';
    final String image = accommodationData['image'] ?? 'assets/images/matra_background.png';

    // Minta felszereltség elemek
    const List<Map<String, dynamic>> amenities = [
      {'icon': Icons.wifi_rounded, 'label': 'Ingyenes Wi-Fi'},
      {'icon': Icons.hot_tub_rounded, 'label': 'Jakuzzi / Dézsa'},
      {'icon': Icons.local_parking_rounded, 'label': 'Ingyenes Parkoló'},
      {'icon': Icons.outdoor_grill_rounded, 'label': 'Bográcsozó & Grill'},
      {'icon': Icons.landscape_rounded, 'label': 'Panoráma'},
      {'icon': Icons.ac_unit_rounded, 'label': 'Klíma'},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // FEJLÉC KÉP ÉS VISSZA GOMB
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: bgColor,
            leading: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TARTALOM
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CÍM ÉS ÉRTÉKELÉS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // HELYSZÍN ÉS BADGE
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$location ($region)',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accent.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          '0% Jutalék / Közvetlen',
                          style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // 1. LEÍRÁS SZEKCIÓ
                  const Text(
                    'A szálláshelyről',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pihenj és töltődj fel ebben a prémium erdei vendégházban! A szálláshely gyönyörű panorámás kilátással, csendes környezetben várja a természet szerelmeseit. Ideális választás pároknak, családoknak és baráti társaságoknak egyaránt.',
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // 2. FELSZERELTSÉG / SZOLGÁLTATÁSOK SZEKCIÓ
                  const Text(
                    'Felszereltség & Szolgáltatások',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: amenities.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item['icon'] as IconData, color: accent, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              item['label'] as String,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // 3. NAPTÁR SZEKCIÓ (FOGLALTSÁG ÉS ÁRAK)
                  const Text(
                    'Foglaltság és Árak 📅',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'A zöld színezésű napok szabadok, a pirosak már foglaltságot jelentenek.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // NAPTÁR WIDGET
                  BookingCalendarWidget(
                    pricePerNight: 35000,
                    onBookingSelected: (dynamic a, dynamic b, dynamic c) {},
                  ),

                  const SizedBox(height: 32),

                  // 4. KÖZVETLEN KAPCSOLATFELVÉTEL GOMBOK
                  const Text(
                    'Közvetlen Kapcsolat a Szállásadóval 📞',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // HÍVÁS GOMB
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_rounded, color: Colors.black, size: 18),
                          label: const Text('Hívás', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // CHAT GOMB
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 18),
                          label: const Text('Üzenet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}