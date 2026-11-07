import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_state.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/cyvesta_scaffold.dart';
import 'edit_listing_page.dart';
import 'steps/add_listing_wizard_page.dart';

/// A bejelentkezett partner (vagy admin) saját hirdetései: állapot, szerkesztés, törlés.
class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color cardBg = Color(0xFF093753);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  String _priceText(Map<String, dynamic> d) {
    final p = d['price'];
    if (p is! num) return '';
    final n = p == p.roundToDouble() ? p.toInt().toString() : p.toString();
    if (d['listingType'] == 'rent') return '€$n / ${d['priceUnit'] == 'month' ? 'hó' : 'éj'}';
    return '€$n';
  }

  Widget _chip(String status) {
    final Color color;
    final String label;
    switch (status) {
      case 'approved':
      case 'active':
        color = Colors.greenAccent;
        label = 'Élő';
        break;
      case 'rejected':
        color = Colors.redAccent;
        label = 'Elutasítva';
        break;
      default:
        color = sunnyGold;
        label = 'Ellenőrzés alatt';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
    );
  }

  Future<void> _delete(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final title = (doc.data()['title'] ?? 'hirdetés').toString();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: deepBlueIcon,
        title: const Text('Hirdetés törlése', style: TextStyle(color: Colors.white)),
        content: Text('Biztosan törlöd: "$title"? Ez nem vonható vissza.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Mégse')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Törlés', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final urls = doc.data()['imageUrls'];
      await doc.reference.delete();
      if (urls is List) {
        for (final u in urls) {
          try {
            await FirebaseStorage.instance.refFromURL(u.toString()).delete();
          } catch (_) {}
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A hirdetés törölve.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A törlés nem sikerült: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _card(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final status = (d['status'] ?? 'pending').toString();
    final images = d['imageUrls'] is List ? List<String>.from((d['imageUrls'] as List).map((e) => e.toString())) : <String>[];
    final mod = d['moderation'] is Map ? Map<String, dynamic>.from(d['moderation'] as Map) : <String, dynamic>{};
    final reasons = mod['reasons'] is List ? (mod['reasons'] as List).map((e) => e.toString()).toList() : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: images.isNotEmpty
                      ? AppImage(images.first, width: 72, height: 72, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white38))
                      : const ColoredBox(color: deepBlueIcon, child: Icon(Icons.image_not_supported_outlined, color: Colors.white38)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((d['title'] ?? '').toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text((d['address'] ?? '').toString(), style: const TextStyle(color: Colors.white70, fontSize: 11.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      [_priceText(d), '${images.length} fotó'].where((e) => e.isNotEmpty).join(' · '),
                      style: const TextStyle(color: Colors.white54, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _chip(status),
            ],
          ),
          if (status != 'approved' && status != 'active' && reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (status == 'rejected' ? Colors.redAccent : sunnyGold).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status == 'rejected' ? 'Elutasítva, mert:' : 'Az ellenőrzés megjegyzései:',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  for (final r in reasons) Text('• $r', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: sunnyGold)),
                icon: const Icon(Icons.edit_rounded, size: 16, color: sunnyGold),
                label: const Text('Szerkesztés', style: TextStyle(color: sunnyGold, fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditListingPage(doc: doc))),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white70),
                label: const Text('Törlés', style: TextStyle(color: Colors.white70, fontSize: 12)),
                onPressed: () => _delete(context, doc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthState.currentUserId;

    return CyvestaScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: deepBlueIcon,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Hirdetéseim', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ),
                  IconButton(
                    tooltip: 'Új hirdetés',
                    icon: const Icon(Icons.add_circle_rounded, color: sunnyGold, size: 30),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingWizardPage())),
                  ),
                ],
              ),
            ),
            Expanded(
              child: uid == null
                  ? const Center(child: Text('A hirdetéseid megtekintéséhez jelentkezz be.', style: TextStyle(color: Colors.white70)))
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('listings').where('partnerId', isEqualTo: uid).snapshots(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Hiba: ${snap.error}', style: const TextStyle(color: Colors.white70))));
                        }
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                        final docs = snap.data!.docs.toList()
                          ..sort((a, b) {
                            final ta = a.data()['createdAt'];
                            final tb = b.data()['createdAt'];
                            final ma = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
                            final mb = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
                            return mb.compareTo(ma);
                          });

                        if (docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('Még nincs hirdetésed. A + gombbal adhatsz fel újat.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: docs.length,
                          itemBuilder: (context, i) => _card(context, docs[i]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
