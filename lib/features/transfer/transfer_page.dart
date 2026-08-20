import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  String _direction = 'to_stay'; // 'to_stay' vagy 'to_airport'
  String _selectedAirport = 'Larnaca (LCA) ✈️';
  int _passengers = 2;

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _flightNumberController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  final List<String> _airports = [
    'Larnaca (LCA) ✈️',
    'Paphos (PFO) ✈️',
    'Ercan (ECN) ✈️',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    _flightNumberController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _sendQuoteRequest() async {
    final dest = _destinationController.text.trim();
    final phone = _contactPhoneController.text.trim();
    final flight = _flightNumberController.text.trim();

    if (dest.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: deepBlueIcon,
          content: Text(
            AppLanguage.tr('transfer_fill_required'),
            style: const TextStyle(color: sunnyGold, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    final dirText = _direction == 'to_stay'
        ? AppLanguage.tr('transfer_dir_to_stay')
        : AppLanguage.tr('transfer_dir_to_airport');

    final msg = Uri.encodeComponent(
      "🚖 *CYVESTA Transfer Request*\n\n"
      "📍 Direction: $dirText\n"
      "🛫 Airport: $_selectedAirport\n"
      "🏨 Destination: $dest\n"
      "👥 Passengers: $_passengers\n"
      "✈️ Flight Number: ${flight.isEmpty ? 'N/A' : flight}\n"
      "📞 Contact: $phone\n\n"
      "Please provide price quote and availability!"
    );

    final uri = Uri.parse("https://wa.me/35799123456?text=$msg");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FEJLÉC
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: deepBlueIcon,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLanguage.tr('transfer_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // TÁJÉKOZTATÓ KÁRTYA
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: turquoiseGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: mintGreenBorder, width: 1.4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: deepBlueIcon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_car_rounded, color: sunnyGold, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLanguage.tr('transfer_header_title'),
                                style: const TextStyle(color: textDark, fontSize: 14.5, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLanguage.tr('transfer_header_desc'),
                                style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 11.5, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. TRANSZFER IRÁNYA
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
                          AppLanguage.tr('transfer_step1_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDirectionTab(
                                id: 'to_stay',
                                label: AppLanguage.tr('transfer_dir_to_stay'),
                                isSelected: _direction == 'to_stay',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDirectionTab(
                                id: 'to_airport',
                                label: AppLanguage.tr('transfer_dir_to_airport'),
                                isSelected: _direction == 'to_airport',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. JÁRAT & ÚTI CÉL RÉSZLETEI
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
                          AppLanguage.tr('transfer_step2_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Repülőtér legördülő
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF093753),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAirport,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF072A40),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: mintGreenBorder),
                              items: _airports.map((String airport) {
                                return DropdownMenuItem<String>(
                                  value: airport,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flight_takeoff_rounded, color: sunnyGold, size: 18),
                                      const SizedBox(width: 10),
                                      Text(airport, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedAirport = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Szállás / Célállomás mező
                        TextField(
                          controller: _destinationController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF093753),
                            hintText: AppLanguage.tr('transfer_dest_hint'),
                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                            prefixIcon: const Icon(Icons.location_on_rounded, color: sunnyGold, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Utasok száma & Járatszám
                        Row(
                          children: [
                            // Utasok száma
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF093753),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.group_rounded, color: sunnyGold, size: 18),
                                    Text('$_passengers', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (_passengers > 1) setState(() => _passengers--);
                                          },
                                          child: const Icon(Icons.remove_circle_outline, color: mintGreenBorder, size: 20),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () {
                                            if (_passengers < 15) setState(() => _passengers++);
                                          },
                                          child: const Icon(Icons.add_circle_outline, color: mintGreenBorder, size: 20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Járatszám
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _flightNumberController,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF093753),
                                  hintText: AppLanguage.tr('transfer_flight_num'),
                                  hintStyle: const TextStyle(color: Colors.white54, fontSize: 11.5),
                                  prefixIcon: const Icon(Icons.airplane_ticket_rounded, color: sunnyGold, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Telefonszám / WhatsApp elérhetőség
                        TextField(
                          controller: _contactPhoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF093753),
                            hintText: AppLanguage.tr('transfer_phone_hint'),
                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                            prefixIcon: const Icon(Icons.phone_rounded, color: sunnyGold, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // AJÁNLATKÉRÉS GOMB (WhatsApp)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.chat_rounded, size: 20),
                      label: Text(
                        AppLanguage.tr('transfer_submit_btn'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      onPressed: _sendQuoteRequest,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDirectionTab({required String id, required String label, required bool isSelected}) {
    return GestureDetector(
      onTap: () => setState(() => _direction = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? sunnyGold : const Color(0xFF093753),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.white : mintGreenBorder.withValues(alpha: 0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) const Icon(Icons.check_rounded, color: textDark, size: 16),
            if (isSelected) const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? textDark : Colors.white70,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}