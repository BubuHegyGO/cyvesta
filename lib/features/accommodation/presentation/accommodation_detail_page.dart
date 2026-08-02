import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hegygo/features/chat/chat_page.dart';
import 'package:hegygo/features/profile/host_registration_page.dart';

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
  // Demo bejelentkezési állapot (Firebase összekötésnél ezt az Auth állapot alapján vizsgáljuk)
  final bool _isLoggedIn = false; 

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A hívás elindítása nem sikerült.')),
        );
      }
    }
  }

  void _handleChatClick(Map<String, dynamic> data) {
    if (!_isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E261C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF8BC541)),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF8BC541)),
              SizedBox(width: 8),
              Text('Bejelentkezés szükséges', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: const Text(
            'A szállásadóval való közvetlen chatezéshez regisztrált fiókra van szükség.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mégse', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC541),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HostRegistrationPage()),
                );
              },
              child: const Text('Regisztráció / Belépés', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            accommodationData: Map<String, String>.from(
              data.map((key, value) => MapEntry(key, value.toString())),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.accommodationData ?? {};
    
    final String title = data['title'] ?? 'PANORÁMA';
    final String location = data['location'] ?? 'Mátra - Mátraháza';
    final String imagePath = data['imagePath'] ?? data['image'] ?? 'assets/images/default_accommodation.png';
    final String description = data['description'] ?? 'Gyönyörű erdei panorámás vendégház a Mátra szívében.';
    final String phone = data['phone'] ?? '+36301234567';
    
    final dynamic rawPrice = data['price'] ?? 35000;
    final int pricePerNight = rawPrice is int ? rawPrice : 35000;

    final int maxGuests = data['maxGuests'] ?? 4;
    final int roomsCount = data['roomsCount'] ?? 2;
    final int bedsCount = data['bedsCount'] ?? 3;
    
    final List<String> features = data['features'] is List<String>
        ? List<String>.from(data['features'])
        : ['Állatbarát', 'Önellátó', 'Wellness', 'Medencés', 'Romantikus 2 fős'];

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
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_accommodation.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                      colors: [
                        Colors.transparent,
                        const Color(0xFF121212).withAlpha(230),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildSpecCard(Icons.people_outline, '$maxGuests fő', 'Max. felnőtt'),
                      const SizedBox(width: 10),
                      _buildSpecCard(Icons.meeting_room_outlined, '$roomsCount szoba', 'Szobák száma'),
                      const SizedBox(width: 10),
                      _buildSpecCard(Icons.bed_outlined, '$bedsCount ágy', 'Férőhely / Ágy'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (features.isNotEmpty) ...[
                    const Text(
                      'Szállás jellemzői',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: features.map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A261C),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF8BC541).withOpacity(0.6), width: 1),
                          ),
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Color(0xFF8BC541),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.language, color: Colors.black, size: 20),
                        label: const Text(
                          'A szállás weboldala',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  const Text(
                    'Közvetlen Kapcsolat a Szállásadóval 📞',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleChatClick(data),
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 20),
                      label: const Text(
                        'Chat indítása a szállásadóval',
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
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(phone),
                      icon: const Icon(Icons.phone_outlined, color: Colors.white70, size: 18),
                      label: const Text('Hívás', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF8BC541), size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}