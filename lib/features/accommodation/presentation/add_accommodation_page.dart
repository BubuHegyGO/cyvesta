import 'package:flutter/material.dart';
import '../../../core/services/data_service.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';

class AddAccommodationPage extends StatefulWidget {
  const AddAccommodationPage({super.key});

  @override
  State<AddAccommodationPage> createState() => _AddAccommodationPageState();
}

class _AddAccommodationPageState extends State<AddAccommodationPage> {
  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _purpose = 'rent'; // rent vagy sale

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _saveAccommodation() {
    if (_formKey.currentState!.validate()) {
      final newAcc = {
        'id': 'acc_${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'price': _purpose == 'rent' ? '€${_priceCtrl.text.trim()} / éj' : '€${_priceCtrl.text.trim()}',
        'rating': '5.00',
        'purpose': _purpose,
        'status': 'pending', // ADMIN JÓVÁHAGYÁSRA VÁR
        'imagePath': 'assets/images/szarvas.png',
        'whatsapp': _phoneCtrl.text.trim(),
        'website': _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'views': 0,
        'leads': 0,
        'isFeatured': false,
        'submittedAt': 'Épp most',
      };

      final current = List<Map<String, dynamic>>.from(DataService.accommodations.value);
      current.insert(0, newAcc);
      DataService.accommodations.value = current;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: darkBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: mintGreenBorder, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: sunnyGold, size: 26),
              SizedBox(width: 8),
              Text('Hirdetés Rögzítve! ⏳', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Köszönjük a beküldést!', style: TextStyle(color: sunnyGold, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('A hirdetés minőségbiztosítási és biztonsági okokból adminisztrátori ellenőrzésre került.', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
              SizedBox(height: 8),
              Text('Jóváhagyás után (általában 1-2 órán belül) azonnal élesedik a keresőben és a kezdőlapon!', style: TextStyle(color: mintGreenBorder, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Rendben', style: TextStyle(color: mintGreenBorder, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Új Hirdetés Beküldése 🏡',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: turquoiseGlass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mintGreenBorder, width: 1.5),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: deepBlueIcon,
                      child: Icon(Icons.verified_user_rounded, color: sunnyGold, size: 22),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Moderált Prémium Hirdetési Rendszer', style: TextStyle(color: textDark, fontSize: 13.5, fontWeight: FontWeight.w900)),
                          SizedBox(height: 2),
                          Text('A beküldött hirdetéseket adminisztrátoraink ellenőrzik a csalások kiszűrése érdekében.', style: TextStyle(color: textDark, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xE6072A40),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mintGreenBorder.withValues(alpha: 0.7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alapadatok & Típus', style: TextStyle(color: sunnyGold, fontSize: 14, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Kiadó Szállás', style: TextStyle(fontWeight: FontWeight.bold))),
                            selected: _purpose == 'rent',
                            selectedColor: sunnyGold,
                            onSelected: (val) => setState(() => _purpose = 'rent'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Eladó Ingatlan', style: TextStyle(fontWeight: FontWeight.bold))),
                            selected: _purpose == 'sale',
                            selectedColor: sunnyGold,
                            onSelected: (val) => setState(() => _purpose = 'sale'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildField(_titleCtrl, 'Ingatlan / Villa Címe *', Icons.home_work_rounded, validator: (v) => v!.isEmpty ? 'Kötelező mező' : null),
                    const SizedBox(height: 10),
                    _buildField(_locationCtrl, 'Régió / Város (pl. Coral Bay, Paphos) *', Icons.location_on_rounded, validator: (v) => v!.isEmpty ? 'Kötelező mező' : null),
                    const SizedBox(height: 10),
                    _buildField(_priceCtrl, _purpose == 'rent' ? 'Ár (€ / éjszaka) *' : 'Vételár (€) *', Icons.euro_rounded, keyboard: TextInputType.number, validator: (v) => v!.isEmpty ? 'Kötelező mező' : null),
                    const SizedBox(height: 10),
                    _buildField(_phoneCtrl, 'WhatsApp / Telefonszám *', Icons.phone_rounded, keyboard: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Kötelező mező' : null),
                    const SizedBox(height: 10),

                    _buildField(_websiteCtrl, 'Saját Weboldal / Foglalási URL (pl. https://...)', Icons.language_rounded, keyboard: TextInputType.url),
                    const SizedBox(height: 10),

                    _buildField(_descCtrl, 'Részletes leírás, felszereltség, szobák száma...', Icons.description_rounded, maxLines: 3),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sunnyGold,
                    foregroundColor: textDark,
                    side: const BorderSide(color: mintGreenBorder, width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.send_rounded, color: textDark, size: 20),
                  label: const Text('Hirdetés Beküldése Ellenőrzésre 🚀', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  onPressed: _saveAccommodation,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {TextInputType keyboard = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: mintGreenBorder, fontSize: 12),
        prefixIcon: Icon(icon, color: sunnyGold, size: 18),
        filled: true,
        fillColor: deepBlueIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: mintGreenBorder)),
      ),
    );
  }
}