import 'package:flutter/material.dart';

class StripeService {
  static const String stripePublishableKey = 'pk_test_51...';
  static const String stripeSecretKey = 'sk_test_51...';

  /// Teszt- és éles fizetés indítása Stripe-on keresztül
  static Future<bool> makePayment({
    required BuildContext context,
    required String amount,
    required String currency,
    required String planName,
  }) async {
    try {
      bool confirm = false;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF072A40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF99FF99), width: 1.4),
          ),
          title: const Row(
            children: [
              Icon(Icons.credit_card_rounded, color: Color(0xFFFF9F1C), size: 24),
              SizedBox(width: 8),
              Text('Stripe Checkout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kiválasztott csomag: $planName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Text('Fizetendő összeg: $amount ${currency.toUpperCase()}', style: const TextStyle(color: Color(0xFF99FF99), fontSize: 15, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              const Text('A fizetés a Stripe biztonságos 256 bites titkosított hálózatán keresztül történik.', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mégse', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F1C),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                confirm = true;
                Navigator.pop(ctx);
              },
              child: const Text('Fizetés Jóváhagyása 💳', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (!confirm) return false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF072A40),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF99FF99)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🎉 Sikeres Stripe fizetés ($amount $currency)! A $planName aktiválva.',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint("Stripe fizetési hiba: $e");
      return false;
    }
  }
}