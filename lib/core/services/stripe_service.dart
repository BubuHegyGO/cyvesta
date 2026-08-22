import 'package:flutter/material.dart';

class StripeService {
  // A te Birlakcyprus Sandbox Publishable Key kulcsod
  static const String publishableKey = 'pk_test_51T10g6ICmvfHJih328XgHknwZOFrs7TC0uAQdFLZKPgCG6ReJomKsis48kgTJ6oAA1592XRSR8pArbgM2cqjteT00PUChRZW0';

  // Stripe inicializálás
  static Future<void> initStripe() async {
    // Nincs szükség külső csomagra a teszteléshez és a partner regisztrációhoz
    debugPrint('Stripe Sandbox inicializálva: $publishableKey');
  }

  // Fizetési folyamat indítása a partnerek számára
  static Future<bool> makePayment({
    required BuildContext context,
    required String amount, // pl. '240' vagy '180'
    required String currency, // 'EUR'
    required String planName, // 'Éves Partner Tagság'
  }) async {
    try {
      final paymentSuccessful = await _showTestPaymentDialog(context, amount, currency, planName);
      return paymentSuccessful;
    } catch (e) {
      debugPrint('Stripe fizetési hiba: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba a fizetés során: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
      return false;
    }
  }

  // Biztonságos teszt fizetési ablak a fejlesztéshez és teszteléshez
  static Future<bool> _showTestPaymentDialog(BuildContext context, String amount, String currency, String planName) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF072A40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF99FF99), width: 1.4),
        ),
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: Color(0xFFFF9F1C), size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Stripe Secure Checkout',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Csomag: $planName', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Fizetendő összeg: €$amount $currency', style: const TextStyle(color: Color(0xFFFF9F1C), fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF093753),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF99FF99).withValues(alpha: 0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teszt Kártya Adatok:', style: TextStyle(color: Color(0xFF99FF99), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Kártyaszám: 4242 4242 4242 4242', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('Lejárat: Bármilyen jövőbeli dátum (pl. 12/28)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('CVC: Bármilyen 3 jegyű szám (pl. 123)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mégse', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9F1C),
              foregroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx, true);
            },
            child: Text('Fizetés €$amount jóváhagyása', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    ) ?? false;
  }
}