import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';
import '../../chat/chat_detail_page.dart';
import '../../map/map_page.dart';

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
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final item = widget.accommodationData;
    final title = item['title']?.toString() ?? 'CYVESTA Ingatlan';
    final location = item['location']?.toString() ?? 'Ciprus';
    final price = item['price']?.toString() ?? '';
    final rating = item['rating']?.toString() ?? '4.95';
    final imagePath = item['imagePath']?.toString() ?? 'assets/images/szarvas.png';
    final category = item['category']?.toString().toLowerCase() ?? '';
    
    final bool isSale = category == 'sale' || price.contains('€320') || price.contains('000');

    return CyvestaScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.asset(
                    imagePath,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 260,
                      color: deepBlueIcon,
                      child: const Icon(Icons.villa_rounded, size: 70, color: mintGreenBorder),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: CircleAvatar(
                      backgroundColor: deepBlueIcon,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: turquoiseGlass,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: mintGreenBorder, width: 1.4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: sunnyGold, size: 14),
                                    const SizedBox(width: 4),
                                    Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: deepBlueIcon, size: 16),
                              const SizedBox(width: 4),
                              Text(location, style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (price.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: deepBlueIcon, borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                price,
                                style: const TextStyle(color: sunnyGold, fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.chat_rounded, size: 18),
                            label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                            onPressed: () async {
                              final url = Uri.parse('https://wa.me/35799000000?text=Érdeklődöm a következő ingatlan iránt: $title');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: deepBlueIcon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: mintGreenBorder, width: 1),
                            ),
                            icon: const Icon(Icons.forum_rounded, size: 18),
                            label: const Text('Belső Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatDetailPage(
                                    partnerName: 'Eladó / Tulajdonos',
                                    partnerSubtitle: 'CYVESTA Partner',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isSale) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF093753),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: sunnyGold, width: 1.4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ingatlan Adatok & Tulajdonos 🏠',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const Divider(color: Colors.white24, height: 16),
                            _buildInfoRow(Icons.aspect_ratio_rounded, 'Alapterület:', '145 m² + 40 m² terasz'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.meeting_room_rounded, 'Szobák száma:', '4 szoba (3 hálószoba + nappali)'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.stairs_rounded, 'Emelet:', '2. emelet (Lift van)'),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.person_outline_rounded, 'Eladó / Ügynök:', 'CYVESTA Exclusive Partner'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF093753),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: mintGreenBorder, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Foglaltsági Naptár & iCal 📅',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDateRange = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: turquoiseGlass,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, color: textDark, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedDateRange == null
                                              ? 'Dátum kiválasztása 🗓️'
                                              : '${_selectedDateRange!.start.toString().substring(5, 10)} ➔ ${_selectedDateRange!.end.toString().substring(5, 10)}',
                                          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 12.5),
                                        ),
                                      ],
                                    ),
                                    const Text('Módosítás ✍️', style: TextStyle(color: textDark, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF093753),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Leírás & Részletek 📖', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            isSale
                                ? 'Gyönyörű tengerparti exkluzív ingatlan Cipruson, prémium felszereltséggel, saját medencével, modern gépészettel és lenyűgöző kilátással. Ideális befektetés vagy luxus otthon.'
                                : 'Gyönyörű szálláshely prémium felszereltséggel, kiváló elhelyezkedéssel és kényelmi szolgáltatásokkal a tökéletes ciprusi pihenéshez.',
                            style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: turquoiseGlass,
                          foregroundColor: textDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: mintGreenBorder, width: 1.2),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 20),
                        label: const Text('Megtekintés Térképen 🗺️', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: sunnyGold, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
      ],
    );
  }
}