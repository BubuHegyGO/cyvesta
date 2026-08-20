import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import '../profile/host_packages_page.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final List<Map<String, dynamic>> _faqItemsHu = const [
    {
      'icon': Icons.rocket_launch_rounded,
      'q': 'Mi a CYVESTA, és miben különbözik egy hagyományos weboldaltól?',
      'a': 'A CYVESTA egy dedikált, egész Ciprust lefedő prémium mobilplatform. Míg egy átlagos weboldal lassú, bonyolult és tele van zavaró hirdetésekkel, a CYVESTA natív sebességgel működik, közvetlen WhatsApp kapcsolatot biztosít a tulajdonosokkal, élő iCal naptárszinkronizációt nyújt, és GPS-alapú térképen mutatja a legjobb villákat, strandokat, éttermeket és reptéri transzfereket.',
    },
    {
      'icon': Icons.bolt_rounded,
      'q': 'Hogyan működnek a Last Minute & Villámakció Push Értesítések? ⚡',
      'a': 'Ha egy szálláson váratlan lemondás történik, vagy üresen maradt néhány nap, a tulajdonos közvetlenül a mobilappból (admin gépelés nélkül, 30 másodperc alatt) elindíthat egy villámakciót. \n\n• Tulajdonos szemszöge: Megadja a felszabadult dátumot és a kedvezményes árat (pl. -35%), majd rányom a küldés gombra.\n• Vendég szemszöge: Azok a felhasználók, akik feliratkoztak a Last Minute értesítésekre vagy elmentették a szállást a kedvenceik közé, azonnal Push értesítést kapnak a telefonjukra (pl. "Paphos Beachfront Villa felszabadult aug. 20-24. között! Csak most €75/éj").\n• Eredmény: Villámgyors foglalás és közvetlen WhatsApp kapcsolat!',
    },
    {
      'icon': Icons.savings_rounded,
      'q': 'Miért éri meg jobban a CYVESTA, mint a Booking vagy az Airbnb?',
      'a': 'A nagy szállásközvetítő portálok 15-25% jutalékot vonnak le mind a vendégtől, mind a szállásadótól. A CYVESTA-nál 0% a jutalék! A vendég közvetlenül a tulajdonossal tárgyal WhatsApp-on, a partner pedig a teljes bevételt (100%) megtartja, rejtett költségek nélkül.',
    },
    {
      'icon': Icons.person_pin_circle_rounded,
      'q': 'Mennyibe kerül a vendégeknek az applikáció használata?',
      'a': 'A vendégek és utazók számára a CYVESTA használata 100%-ban INGYENES (0 EUR). Nincs regisztrációs díj, sem foglalási felár. Ingyenesen böngészheted az eladó és kiadó ingatlanokat, mentheted kedvenceidet és közvetlenül írhatsz a házigazdáknak.',
    },
    {
      'icon': Icons.diamond_rounded,
      'q': 'Hogyan hirdethetnek a szállásadók, éttermek és túraszervezők?',
      'a': 'A partnerek rendkívül kedvező, fix tagsági díjjal csatlakozhatnak:\n• Éves Partner Tagság: €240 / év (mindössze €20 / hó!)\n• Féléves Partner Tagság: €180 / félév (havi €30)\nA tagság azonnal aktiválható a biztonságos Stripe bankkártyás felületen keresztül, és azonnali megjelenést biztosít a kezdőlapon, a térképen és a kategóriákban.',
    },
    {
      'icon': Icons.sync_rounded,
      'q': 'Hogyan működik az élő iCal naptárszinkronizáció?',
      'a': 'A szállásadó egyszerűen beilleszti az Airbnb vagy Booking naptárának .ics linkjét a hirdetésébe. A CYVESTA automatikusan szinkronizálja a foglaltságot, így a vendégek csak a valóban szabad időpontokat látják és jelölhetik ki. Ezzel a kettős foglalás (overbooking) teljes mértékben kizárt!',
    },
    {
      'icon': Icons.gavel_rounded,
      'q': 'Hol érhető el a hivatalos ÁSZF és GDPR adatvédelmi szabályzat?',
      'a': 'A CYVESTA teljes körű Általános Szerződési Feltételei és ciprusi jogszabályoknak megfelelő GDPR adatvédelmi tájékoztatója az alábbi hivatalos dokumentumban olvasható részletesen: https://docs.google.com/document/d/1qE_7YtmwU7baCj8XB7GAzaPhxzS2yGs8yep1synu7zA/edit?usp=drive_web[cite: 1]',
    },
  ];

  final List<Map<String, dynamic>> _faqItemsEn = const [
    {
      'icon': Icons.rocket_launch_rounded,
      'q': 'What is CYVESTA and how is it different from a normal website?',
      'a': 'CYVESTA is an all-in-one luxury mobile ecosystem for Cyprus. Unlike standard websites that are slow and cluttered, CYVESTA offers lightning-fast native performance, direct WhatsApp host communication, live iCal calendar synchronization, and interactive GPS map discovery.',
    },
    {
      'icon': Icons.bolt_rounded,
      'q': 'How do Last Minute & Flash Deal Push Notifications work? ⚡',
      'a': 'When a cancellation occurs or dates open up, hosts can trigger a flash deal directly from their mobile app within 30 seconds.\n\n• Host perspective: Enter open dates and discounted price (e.g. -35%), then hit send.\n• Guest perspective: Users subscribed to Last Minute deals or who bookmarked the property receive an instant push notification on their phone.\n• Result: Lightning-fast bookings via direct WhatsApp chat!',
    },
    {
      'icon': Icons.savings_rounded,
      'q': 'Why is CYVESTA better than Airbnb or Booking.com?',
      'a': 'Major booking platforms take 15-25% commission from both guests and hosts. CYVESTA charges 0% commission! Guests connect directly with hosts via WhatsApp, and property owners keep 100% of their revenue.',
    },
    {
      'icon': Icons.person_pin_circle_rounded,
      'q': 'Is the app free for guests and travelers?',
      'a': 'Yes, CYVESTA is 100% FREE for guests. There are no registration fees or hidden booking surcharges.',
    },
    {
      'icon': Icons.diamond_rounded,
      'q': 'How can hosts and businesses list their properties?',
      'a': 'Hosts can join with transparent flat membership plans:\n• Annual Partner Membership: €240 / year (only €20 / month!)\n• 6-Month Partner Membership: €180 / 6 months\nInstant activation via secure Stripe payment.',
    },
    {
      'icon': Icons.sync_rounded,
      'q': 'How does live iCal calendar synchronization work?',
      'a': 'Hosts paste their Airbnb or Booking.com .ics link to automatically sync availability and prevent double bookings.',
    },
    {
      'icon': Icons.gavel_rounded,
      'q': 'Where can I find the official Terms & Conditions and GDPR policy?',
      'a': 'The complete CYVESTA Terms of Service and Cyprus-compliant GDPR privacy policy[cite: 1] can be reviewed via the official document: https://docs.google.com/document/d/1qE_7YtmwU7baCj8XB7GAzaPhxzS2yGs8yep1synu7zA/edit?usp=drive_web[cite: 1]',
    },
  ];

  Future<void> _launchDocUrl() async {
    final url = Uri.parse('https://docs.google.com/document/d/1qE_7YtmwU7baCj8XB7GAzaPhxzS2yGs8yep1synu7zA/edit?usp=drive_web');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isEn = locale != 'hu';
        final items = isEn ? _faqItemsEn : _faqItemsHu;

        final pageTitle = isEn ? 'How CYVESTA Works 💡' : 'Gyakori Kérdések & Működés 💡';
        final headerTitle = isEn ? 'The Next Generation Cyprus Platform' : 'A Jövő Ciprusi Élményplatformja';
        final headerDesc = isEn
            ? 'Direct connections, 0% commissions, verified local hosts, and instant Last Minute Push notifications.'
            : 'Közvetlen kapcsolat, 0% jutalék, ellenőrzött szállások és villámgyors Last Minute Push értesítések.';

        return CyvestaScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          pageTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                              child: const Icon(Icons.auto_awesome_rounded, color: sunnyGold, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                headerTitle,
                                style: const TextStyle(color: textDark, fontSize: 14.5, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          headerDesc,
                          style: TextStyle(color: textDark.withValues(alpha: 0.85), fontSize: 12, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...items.map((faq) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF093753),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: deepBlueIcon, shape: BoxShape.circle),
                          child: Icon(faq['icon'] as IconData, color: sunnyGold, size: 20),
                        ),
                        iconColor: sunnyGold,
                        collapsedIconColor: mintGreenBorder,
                        title: Text(
                          faq['q'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, height: 1.25),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faq['a'] as String,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.45),
                                ),
                                if (faq == items.last) ...[
                                  const SizedBox(height: 10),
                                  InkWell(
                                    onTap: _launchDocUrl,
                                    child: const Text(
                                      '📂 Hivatalos ÁSZF & GDPR Google Dokumentum megnyitása[cite: 1]',
                                      style: TextStyle(
                                        color: mintGreenBorder,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: deepBlueIcon,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: sunnyGold, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isEn ? 'Ready to List Your Property?' : 'Csatlakozz te is Partnerként!',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEn
                              ? 'Get direct WhatsApp bookings and Last Minute reach for only €20/month (€240/year).'
                              : 'Közvetlen WhatsApp foglalások és Last Minute Push elérés mindössze €20/hó díjért.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sunnyGold,
                              foregroundColor: textDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HostPackagesPage()),
                              );
                            },
                            child: Text(
                              isEn ? 'View Partner Plans 💎' : 'Partner Csomagok Megtekintése 💎',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
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
}