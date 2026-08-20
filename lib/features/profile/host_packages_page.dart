import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/auth_state.dart';
import '../../core/services/stripe_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../accommodation/presentation/steps/add_listing_wizard_page.dart';

class HostPackagesPage extends StatefulWidget {
  const HostPackagesPage({super.key});

  @override
  State<HostPackagesPage> createState() => _HostPackagesPageState();
}

class _HostPackagesPageState extends State<HostPackagesPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  void _handleStripeCheckout(String planName, String amount) async {
    final success = await StripeService.makePayment(
      context: context,
      amount: amount,
      currency: 'EUR',
      planName: planName,
    );

    if (success && mounted) {
      AuthState.isPartner.value = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddListingWizardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isEn = locale != 'hu';

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
                          isEn ? 'Membership & Registration 💎' : 'Regisztrációs & Partner Csomagok 💎',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 0% JUTALÉK BANNER
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
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: deepBlueIcon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, color: sunnyGold, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? '0% Commission. Direct Contact.' : '0% Jutalék. Közvetlen Kapcsolat.',
                                style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isEn
                                    ? 'Guest registration is free. Partners can list with annual (€240) or semi-annual (€180) fee and direct WhatsApp bookings!'
                                    : 'A vendégfiók teljesen ingyenes. Partnerek éves (€240 - havi €20) vagy féléves (€180) díjjal hirdethetnek közvetlen WhatsApp kapcsolat mellett!',
                                style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 11.5, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. VENDÉG FIÓK (INGYENES)
                  _buildPackageCard(
                    title: isEn ? 'Guest / Traveler Account 🏖️' : 'Vendég / Utazó Fiók 🏖️',
                    price: isEn ? 'FREE (0 EUR)' : 'INGYENES (0 EUR)',
                    badgeText: isEn ? 'Free Forever' : 'Örökké Ingyenes',
                    isPopular: false,
                    features: [
                      isEn ? 'Explore all Cyprus apartments & tours' : 'Minden ciprusi szállás és túra elérése',
                      isEn ? 'Save favorites to your wishlist' : 'Kedvencek mentése egy érintéssel',
                      isEn ? 'Direct WhatsApp chat with Hosts' : 'Közvetlen WhatsApp csevegés a szállásadókkal',
                      isEn ? 'In-App chat and table booking' : 'Belső chat és azonnali asztalfoglalás',
                    ],
                    btnText: isEn ? 'Create Free Guest Account' : 'Ingyenes Vendég Regisztráció',
                    btnColor: const Color(0xFF093753),
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vendég fiók kiválasztva!')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. ÉVES PARTNER CSOMAG (240 EUR / ÉV - HAVI 20 EUR) ⭐ LEGNÉPSZERŰBB
                  _buildPackageCard(
                    title: isEn ? 'Annual Partner Membership 💎' : 'Éves Partner Tagság 💎',
                    price: '€240 / év',
                    subPrice: isEn ? '(Only €20 / month!)' : '(Mindössze €20 / hó!)',
                    badgeText: isEn ? 'BEST VALUE ⭐' : 'LEGNÉPSZERŰBB ⭐',
                    isPopular: true,
                    features: [
                      isEn ? 'List up to 5 properties or services' : 'Akár 5 db szállás, villa vagy szolgáltatás hirdetése',
                      isEn ? 'Direct WhatsApp & Phone contact for 100% profit' : 'Közvetlen WhatsApp & telefon elérhetőség (100% haszon nálad)',
                      isEn ? 'Live iCal Availability Sync (Airbnb / Booking)' : 'Élő iCal naptár szinkronizáció (Airbnb / Booking)',
                      isEn ? 'Featured placement on Map & Home Carousel' : 'Kiemelt megjelenés a Kezdőlapon és a Térképen',
                      isEn ? 'Priority CRM Lead Tracking & Support' : 'Kiemelt CRM érdeklődő követés és statisztikák',
                    ],
                    btnText: isEn ? 'Pay with Stripe (€240 / year)' : 'Aktiválás Stripe-pal (€240 / év)',
                    btnColor: sunnyGold,
                    textColor: textDark,
                    onTap: () => _handleStripeCheckout('Éves Partner Tagság', '240'),
                  ),
                  const SizedBox(height: 16),

                  // 3. FÉLÉVES PARTNER CSOMAG (180 EUR / 6 HÓ)
                  _buildPackageCard(
                    title: isEn ? '6-Month Partner Pass 🏝️' : 'Féléves Partner Csomag 🏝️',
                    price: '€180 / félév',
                    subPrice: isEn ? '(€30 / month)' : '(havi €30)',
                    badgeText: isEn ? '6 Months' : 'Féléves',
                    isPopular: false,
                    features: [
                      isEn ? 'List properties and tours for 6 months' : 'Ingatlanok és szolgáltatások listázása 6 hónapra',
                      isEn ? 'Direct WhatsApp contact & 0% commission' : 'Közvetlen WhatsApp kapcsolat, 0% jutalék',
                      isEn ? 'Live iCal calendar synchronization' : 'Élő iCal naptár szinkronizáció',
                      isEn ? 'Standard visibility in all regions' : 'Megjelenés az összes ciprusi régióban',
                    ],
                    btnText: isEn ? 'Pay with Stripe (€180)' : 'Aktiválás Stripe-pal (€180)',
                    btnColor: turquoiseGlass,
                    textColor: textDark,
                    onTap: () => _handleStripeCheckout('Féléves Partner Csomag', '180'),
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

  Widget _buildPackageCard({
    required String title,
    required String price,
    String? subPrice,
    required String badgeText,
    required bool isPopular,
    required List<String> features,
    required String btnText,
    required Color btnColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF093753) : deepBlueIcon,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? sunnyGold : mintGreenBorder.withValues(alpha: 0.6),
          width: isPopular ? 2.2 : 1.2,
        ),
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
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPopular ? sunnyGold : const Color(0xFF072A40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isPopular ? Colors.transparent : mintGreenBorder.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: isPopular ? textDark : mintGreenBorder,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(color: mintGreenBorder, fontSize: 19, fontWeight: FontWeight.w900),
              ),
              if (subPrice != null) ...[
                const SizedBox(width: 8),
                Text(
                  subPrice,
                  style: const TextStyle(color: sunnyGold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          const Divider(color: Colors.white12, height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, color: mintGreenBorder, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    f,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.25),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onTap,
              child: Text(
                btnText,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}