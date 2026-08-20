import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/services/data_service.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';

class ExperienceDetailPage extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const ExperienceDetailPage({super.key, required this.itemData});

  @override
  State<ExperienceDetailPage> createState() => _ExperienceDetailPageState();
}

class _ExperienceDetailPageState extends State<ExperienceDetailPage> {
  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = 'morning';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: sunnyGold,
              onPrimary: textDark,
              surface: Color(0xFF072A40),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _launchWhatsApp(String phone, String title) async {
    final msg = Uri.encodeComponent("Hello! I would like to book: $title on ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} ($_selectedSlot)");
    final uri = Uri.parse("https://wa.me/$phone?text=$msg");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemData['title']?.toString() ?? 'BLUE LAGOON CRUISE ⛵';
    final location = widget.itemData['location']?.toString() ?? 'Latchi Harbor & Akamas Marina';
    final price = widget.itemData['price']?.toString() ?? '€45 / person';
    final rating = widget.itemData['rating']?.toString() ?? '4.98';
    final desc = widget.itemData['description']?.toString() ?? 'Luxury yacht cruise to the Crystal Blue Lagoon with swimming and Cypriot buffet lunch.';
    final imagePath = widget.itemData['imagePath']?.toString() ?? 'assets/images/yacht.png';
    final whatsapp = widget.itemData['whatsapp']?.toString() ?? '+35799123456';

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isEn = locale != 'hu';

        final List<String> tags = isEn
            ? ['Snorkeling Gear', 'Buffet Lunch', 'Cold Drinks', 'Music on Deck']
            : ['Sznorkel felszerelés', 'Büféebéd', 'Hűsítő italok', 'Zene a fedélzeten'];

        final priceLabel = isEn ? 'from €45 / person' : '€45 / fő-től';

        return CyvestaScaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // FELSŐ KÉP + VISSZA GOMB
                  SliverAppBar(
                    expandedHeight: 260,
                    pinned: true,
                    backgroundColor: darkBg,
                    leading: CircleAvatar(
                      backgroundColor: deepBlueIcon.withValues(alpha: 0.8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: mintGreenBorder, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: DataService.favoriteItems,
                        builder: (context, favs, child) {
                          final isFav = DataService.isFavorite(widget.itemData);
                          return CircleAvatar(
                            backgroundColor: deepBlueIcon.withValues(alpha: 0.8),
                            child: IconButton(
                              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : Colors.white, size: 20),
                              onPressed: () => DataService.toggleFavorite(widget.itemData),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: deepBlueIcon),
                      ),
                    ),
                  ),

                  // TARTALOM
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CÍM & ÁR KÁRTYA
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: turquoiseGlass,
                              borderRadius: BorderRadius.circular(16),
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
                                        style: const TextStyle(color: textDark, fontSize: 16.5, fontWeight: FontWeight.w900),
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
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: deepBlueIcon, size: 16),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: TextStyle(color: textDark.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(priceLabel, style: const TextStyle(color: deepBlueIcon, fontSize: 14.5, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // GOMBOK (WhatsApp / Belső Chat)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.chat_rounded, size: 18),
                                  label: const Text('WhatsApp Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                  onPressed: () => _launchWhatsApp(whatsapp, title),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: deepBlueIcon,
                                    foregroundColor: mintGreenBorder,
                                    side: const BorderSide(color: mintGreenBorder, width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.forum_outlined, size: 18),
                                  label: Text(isEn ? 'In-App Chat' : 'Belső Chat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(isEn ? 'Connecting to tour guide...' : 'Kapcsolódás a túravezetőhöz...')),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // LEÍRÁS & SZOLGÁLTATÁSOK
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.sailing_rounded, color: sunnyGold, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEn ? 'About the Tour ⛵' : 'A Hajókirándulásról ⛵',
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tags.map((t) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF093753),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 1. DÁTUM VÁLASZTÁS
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEn ? '1. Select Tour Date 📅' : '1. Válassz Túra Dátumot 📅',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: turquoiseGlass,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: mintGreenBorder),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_rounded, color: deepBlueIcon, size: 18),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${_selectedDate.year}. ${_selectedDate.month.toString().padLeft(2, '0')}. ${_selectedDate.day.toString().padLeft(2, '0')}',
                                              style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          isEn ? 'Change ✏️' : 'Módosítás ✏️',
                                          style: const TextStyle(color: deepBlueIcon, fontSize: 11.5, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // 2. IDŐSÁV VÁLASZTÁS
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: deepBlueIcon,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: mintGreenBorder.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEn ? '2. Select Departure Time ⏰' : '2. Válassz Indulási Idősávot ⏰',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                _buildSlotOption(
                                  id: 'morning',
                                  title: isEn ? '09:30 - 14:00 (Morning Cruise)' : '09:30 - 14:00 (Délelőtti Túra)',
                                  subtitle: isEn ? 'Includes buffet lunch & Blue Lagoon swim' : 'Büféebéddel és fürdőzéssel a Kék Lagúnánál',
                                ),
                                const SizedBox(height: 8),
                                _buildSlotOption(
                                  id: 'sunset',
                                  title: isEn ? '15:30 - 19:30 (Sunset Cruise)' : '15:30 - 19:30 (Naplemente Túra)',
                                  subtitle: isEn ? 'Sunset views & cocktails on board' : 'Naplemente nézés és koktélok a fedélzeten',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotOption({required String id, required String title, required String subtitle}) {
    final isSelected = _selectedSlot == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedSlot = id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? sunnyGold : const Color(0xFF093753),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : mintGreenBorder.withValues(alpha: 0.5), width: 1.3),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? textDark : mintGreenBorder,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? textDark : Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? textDark.withValues(alpha: 0.8) : Colors.white60,
                      fontSize: 11,
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