import 'package:flutter/material.dart';

class StepPricing extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceController;
  final String selectedHighlight;
  final Function(String) onHighlightChanged;

  const StepPricing({
    super.key,
    required this.formKey,
    required this.priceController,
    required this.selectedHighlight,
    required this.onHighlightChanged,
  });

  @override
  State<StepPricing> createState() => _StepPricingState();
}

class _StepPricingState extends State<StepPricing> {
  static const Color accent = Color(0xFF8BC541);

  final List<Map<String, String>> _highlightOptions = [
    {
      'id': 'free',
      'title': 'Ingyenes alap megjelenés',
      'desc': 'Normál listázás a keresési találatok között.',
      'price': '0 Ft',
    },
    {
      'id': 'bronze',
      'title': 'Bronz kiemelés',
      'desc': 'Kiemelt jelvény a kártyán és előkelőbb hely a keresőben.',
      'price': '4.990 Ft / hó',
    },
    {
      'id': 'gold',
      'title': 'Arany / Főoldali kiemelés 🏆',
      'desc': 'Megjelenés a HegyGO főoldali kiemelt kártyái között!',
      'price': '9.990 Ft / hó',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Árazás & Megjelenés',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Állítsd be az alapvető éjszakánkénti árat és válaszd ki a hirdetésed kiemelési csomagját!',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Alapár mező
            const Text(
              'Alapár (Ft / éjszaka) *',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: _buildInputDecoration('pl. 25000'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Kérjük, add meg az alapárat!';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Kérjük, csak számokat adj meg!';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'Kiemelési csomagok',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Csomagválasztó opciók (Egyedi rádiógomb dizájn)
            Column(
              children: _highlightOptions.map((option) {
                final isSelected = widget.selectedHighlight == option['id'];
                return InkWell(
                  onTap: () => widget.onHighlightChanged(option['id']!),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? accent.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? accent : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Egyedi kör rádiógomb jelölő
                        Container(
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? accent : Colors.white38,
                              width: isSelected ? 6 : 2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      option['title']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    option['price']!,
                                    style: TextStyle(
                                      color: isSelected ? accent : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['desc']!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.all(16),
      suffixText: 'Ft / éj',
      suffixStyle: const TextStyle(color: accent, fontWeight: FontWeight.bold),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accent, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
    );
  }
}