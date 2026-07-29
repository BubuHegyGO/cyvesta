import 'package:flutter/material.dart';
import 'widgets/booking_calendar_widget.dart';

class AccommodationDetailPage extends StatefulWidget {
  final Map<String, dynamic>? accommodationData;

  const AccommodationDetailPage({
    super.key,
    this.accommodationData,
  });

  @override
  State<AccommodationDetailPage> createState() => _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {
  @override
  Widget build(BuildContext context) {
    final data = widget.accommodationData ?? {};
    final String title = data['title'] ?? 'Mátrai Panoráma Vendégház';
    final String location = data['location'] ?? 'Mátraszentimre, Mátra';
    final String imagePath = data['image'] ?? 'assets/images/default_accommodation.png';
    final dynamic rawPrice = data['price'] ?? 35000;
    final int pricePerNight = rawPrice is int ? rawPrice : 35000;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CÍMLAPKÉP HÁTTÉR - VILÁGOS, TISZTA ÁTMENETTEL
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/default_accommodation.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/matra_background.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                // LÁGY ÉS VILÁGOS GRADIENT (CSAK AZ ALJA SÖTÉTÜL)
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0], // 50%-ig teljesen átlátszó/világos marad a kép
                      colors: [
                        Colors.transparent,
                        const Color(0xFF121212).withAlpha(230), // Csak az alja mosódik át a sötét háttérbe
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // TARTALMI RÉSZ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF8BC541), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Gyönyörű erdei panorámás vendégház a Mátra szívében.',
                    style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // FOGLALTSÁG ÉS ÁRAK SZEKCIÓ (ÚJ NAPTÁR WIDGET)
                  const Row(
                    children: [
                      Text(
                        'Foglaltság és Árak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('📅', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A zöld színezésű napok szabadok, a pirosak már foglaltságot jelentenek.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 14),

                  // NAPTÁR WIDGET
                  BookingCalendarWidget(
                    pricePerNight: pricePerNight,
                  ),

                  const SizedBox(height: 28),

                  // KÖZVETLEN KAPCSOLAT A SZÁLLÁSADÓVAL
                  const Text(
                    'Közvetlen Kapcsolat a Szállásadóval 📞',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CHAT GOMB
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 20),
                      label: const Text(
                        'Chat indítása (Kovács János)',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC541),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // HÍVÁS ÉS SMS GOMBOK
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_outlined, color: Colors.white70, size: 18),
                          label: const Text('Hívás', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.sms_outlined, color: Colors.white70, size: 18),
                          label: const Text('SMS', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ár / éjszaka',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
                Text(
                  '${pricePerNight.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Ft / éj',
                  style: const TextStyle(
                    color: Color(0xFF8BC541),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bookmark_border, color: Colors.black, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Foglalás',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}