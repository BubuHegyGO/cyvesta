import 'package:flutter/material.dart';
import 'widgets/booking_calendar_widget.dart';

class AccommodationDetailPage extends StatefulWidget {
  final Map<String, dynamic> accommodationData;

  const AccommodationDetailPage({
    super.key,
    required this.accommodationData,
  });

  @override
  State<AccommodationDetailPage> createState() => _AccommodationDetailPageState();
}

class _AccommodationDetailPageState extends State<AccommodationDetailPage> {
  static const Color bgColor = Color(0xFF07130A);
  static const Color accent = Color(0xFF8BC541);

  DateTimeRange? _bookingRange;
  int _calculatedTotalPrice = 0;

  // Szállásadó minta adatai
  final String _hostPhone = '+36301234567';
  final String _hostEmail = 'info@matraipanoramavendeghaz.hu';

  int _parsePrice(String priceStr) {
    final clean = priceStr.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(clean) ?? 25000;
  }

  // 📞 Telefonhívás indítása
  void _makePhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0D2113),
        content: Text(
          'Hívás indítása: $_hostPhone',
          style: const TextStyle(color: accent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // 💬 In-App Chat indítása
  void _openChatModal() {
    final dateText = _bookingRange == null
        ? 'Még nincs kiválasztott dátum'
        : '${_bookingRange!.start.toString().split(' ')[0]} - ${_bookingRange!.end.toString().split(' ')[0]}';

    final priceInfo = _calculatedTotalPrice > 0
        ? ' (Várható összeg: $_calculatedTotalPrice Ft)'
        : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D2113),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final chatController = TextEditingController(
          text: 'Szia! Érdeklődni szeretnék a szállással kapcsolatban. Kiválasztott időszak: $dateText$priceInfo.',
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded, color: accent, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Közvetlen Chat',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),

              const Text('Üzenet a szállásadónak:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),

              TextField(
                controller: chatController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.35),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accent)),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Üzenet Küldése (Chat)', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF0D2113),
                        content: Text('Chat üzenet elküldve a szállásadónak!', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✉️ E-mail küldése
  void _sendEmail() {
    final dateText = _bookingRange == null
        ? 'Még nincs kiválasztott dátum'
        : '${_bookingRange!.start.toString().split(' ')[0]} - ${_bookingRange!.end.toString().split(' ')[0]}';

    final priceInfo = _calculatedTotalPrice > 0
        ? '\nKalkulált várható összeg: $_calculatedTotalPrice Ft'
        : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D2113),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final messageController = TextEditingController(
          text: 'Üdvözlöm!\nÉrdeklődni szeretnék a megadott időszakra: $dateText.$priceInfo\nVárható létszám: 2 fő.\n\nÜdvözlettel,',
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Közvetlen E-mail a Szállásadónak',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              const SizedBox(height: 10),

              Text('Címzett: $_hostEmail', style: const TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextField(
                controller: messageController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.35),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: accent)),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Üzenet Küldése', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF0D2113),
                        content: Text('E-mail sikeresen elküldve a szállásadónak!', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.accommodationData;
    final int basePrice = _parsePrice(data['price'] ?? '');

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. KÉPES FEJLÉC
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: bgColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                data['image'] ?? 'assets/images/matra_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. SZÁLLÁS ADATOK & NAPTÁR
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
                          data['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            data['rating'] ?? '5.0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // HELYSZÍN & JUTALÉKMENTES JELZÉS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: accent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            data['location'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accent.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          '0% Jutalék / Közvetlen',
                          style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // FOGLALÁSI NAPTÁR WIDGET (PONTOS DÁTUM + ÉJSZAKA + ÁRKALKUÁCIÓ)
                  BookingCalendarWidget(
                    pricePerNight: basePrice,
                    onBookingSelected: (range, total) {
                      setState(() {
                        _bookingRange = range;
                        _calculatedTotalPrice = total;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // KÖZVETLEN KAPCSOLATFELVÉTELI SZEKCIÓ CÍME
                  const Text(
                    'Közvetlen Kapcsolat a Szállásadóval',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Foglald le közvetlenül a szállásadótól jutalékmentesen!',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 14),

                  // KAPCSOLATFELVÉTELI GOMBOK (HÍVÁS / CHAT / EMAIL)
                  Row(
                    children: [
                      // TELEFON
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.phone_rounded,
                          label: 'Hívás',
                          color: accent,
                          textColor: Colors.black,
                          onTap: _makePhoneCall,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // CHAT
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.chat_bubble_rounded,
                          label: 'Chat',
                          color: Colors.black.withValues(alpha: 0.35),
                          textColor: Colors.white,
                          isOutlined: true,
                          onTap: _openChatModal,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // EMAIL
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.email_rounded,
                          label: 'E-mail',
                          color: Colors.black.withValues(alpha: 0.35),
                          textColor: Colors.white,
                          isOutlined: true,
                          onTap: _sendEmail,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: color,
          foregroundColor: textColor,
          side: isOutlined ? const BorderSide(color: accent) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: isOutlined ? 0 : 3,
        ),
        icon: Icon(icon, size: 18, color: isOutlined ? accent : textColor),
        label: Text(label, style: TextStyle(color: isOutlined ? accent : textColor, fontWeight: FontWeight.bold, fontSize: 13)),
        onPressed: onTap,
      ),
    );
  }
}