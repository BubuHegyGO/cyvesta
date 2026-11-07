import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

/// Admin vezérlőpult: a Firestore-ban lévő hirdetések és céges partner-jelentkezések moderálása.
/// A műveleteket a Firestore Security Rules csak az `admins/{uid}` gyűjteményben szereplő felhasználónak engedi.
class AdminModerationPage extends StatefulWidget {
  const AdminModerationPage({super.key});

  @override
  State<AdminModerationPage> createState() => _AdminModerationPageState();
}

class _AdminModerationPageState extends State<AdminModerationPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color cardBg = Color(0xFF093753);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Műveletek
  // ---------------------------------------------------------------------------

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: error ? Colors.redAccent : Colors.green),
    );
  }

  Future<void> _setListingStatus(String id, String status) async {
    try {
      await _db.collection('listings').doc(id).update({'status': status});
      _toast(status == 'approved' ? 'Hirdetés jóváhagyva ✅' : 'Hirdetés elutasítva');
    } catch (e) {
      _toast('Hiba a módosításnál: $e', error: true);
    }
  }

  Future<void> _deleteListing(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF072A40),
        title: const Text('Hirdetés törlése', style: TextStyle(color: Colors.white)),
        content: Text('Biztosan törlöd ezt: "$title"? Ez nem vonható vissza.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Mégse')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Törlés', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _db.collection('listings').doc(id).delete();
      _toast('Hirdetés törölve');
    } catch (e) {
      _toast('Hiba a törlésnél: $e', error: true);
    }
  }

  Future<void> _setPartnerStatus(String uid, String status) async {
    try {
      await _db.collection('partners').doc(uid).update({'status': status});
      _toast(status == 'approved' ? 'Partner jóváhagyva ✅' : 'Partner elutasítva');
    } catch (e) {
      _toast('Hiba a módosításnál: $e', error: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Segédek
  // ---------------------------------------------------------------------------

  String _listingGroup(Map<String, dynamic> data) {
    final s = data['status'];
    if (s == 'approved' || s == 'active') return 'approved';
    if (s == 'rejected') return 'rejected';
    return 'pending';
  }

  int _millis(Map<String, dynamic> data) {
    final c = data['createdAt'];
    return c is Timestamp ? c.millisecondsSinceEpoch : 0;
  }

  String _price(dynamic p) {
    if (p is num) return p == p.roundToDouble() ? '${p.toInt()} €' : '$p €';
    return '';
  }

  Widget _statusChip(String group) {
    final Color color;
    final String label;
    switch (group) {
      case 'approved':
        color = Colors.greenAccent;
        label = 'Jóváhagyott';
        break;
      case 'rejected':
        color = Colors.redAccent;
        label = 'Elutasított';
        break;
      default:
        color = sunnyGold;
        label = 'Függőben';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  /// Az automatikus ellenőrzés (Cloud Function) eredménye.
  Widget _autoCheckBox({required String? result, required List<String> lines}) {
    if (result == null && lines.isEmpty) return const SizedBox.shrink();
    final Color color;
    final String title;
    switch (result) {
      case 'approved':
      case 'verified':
        color = Colors.greenAccent;
        title = 'Automatikus ellenőrzés: rendben';
        break;
      case 'rejected':
      case 'invalid':
        color = Colors.redAccent;
        title = 'Automatikus ellenőrzés: elutasítva';
        break;
      default:
        color = sunnyGold;
        title = 'Automatikus ellenőrzés: kézi átnézés kell';
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          for (final l in lines) Text('• $l', style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(0, 32),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _cardShell({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mintGreenBorder.withValues(alpha: 0.4), width: 1.2),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Hirdetések
  // ---------------------------------------------------------------------------

  Widget _listingCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final group = _listingGroup(data);
    final title = (data['title'] ?? 'Névtelen hirdetés').toString();
    final address = (data['address'] ?? 'Ismeretlen hely').toString();
    final category = (data['category'] ?? '').toString();
    final description = (data['description'] ?? '').toString();
    final price = _price(data['price']);
    final images = data['imageUrls'] is List ? List<dynamic>.from(data['imageUrls'] as List) : <dynamic>[];
    final partnerId = (data['partnerId'] ?? '').toString();

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: images.isNotEmpty
                      ? Image.network(
                          images.first.toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white38),
                        )
                      : const ColoredBox(
                          color: Color(0xFF072A40),
                          child: Icon(Icons.image_not_supported_outlined, color: Colors.white38),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text('Helyszín: $address', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                    if (category.isNotEmpty || price.isNotEmpty)
                      Text(
                        [category, price].where((e) => e.isNotEmpty).join(' · '),
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    Text('Fotók: ${images.length} db', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(group),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.white60, fontSize: 11.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (partnerId.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Feladó UID: $partnerId', style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
          if (data['moderation'] is Map)
            _autoCheckBox(
              result: (data['moderation'] as Map)['result']?.toString(),
              lines: ((data['moderation'] as Map)['reasons'] is List)
                  ? List<String>.from(((data['moderation'] as Map)['reasons'] as List).map((e) => e.toString()))
                  : <String>[],
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (group != 'approved')
                _actionButton('Jóváhagyás', Colors.greenAccent, () => _setListingStatus(doc.id, 'approved')),
              if (group != 'rejected')
                _actionButton('Elutasítás', Colors.redAccent, () => _setListingStatus(doc.id, 'rejected')),
              _actionButton('Törlés', Colors.white54, () => _deleteListing(doc.id, title)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listingList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String emptyText) {
    if (docs.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: Colors.white60, fontSize: 14)));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: docs.length,
      itemBuilder: (context, index) => _listingCard(docs[index]),
    );
  }

  // ---------------------------------------------------------------------------
  // Partner jelentkezések
  // ---------------------------------------------------------------------------

  Widget _partnerCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final status = (data['status'] ?? 'pending').toString();
    final group = status == 'approved' ? 'approved' : (status == 'rejected' ? 'rejected' : 'pending');

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data['companyName'] ?? 'Névtelen cég').toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${data['regType'] ?? ''}: ${data['regNumber'] ?? ''}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text('UID: ${doc.id}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(group),
            ],
          ),
          if (data['verification'] is Map)
            _autoCheckBox(
              result: (data['verification'] as Map)['result']?.toString(),
              lines: [
                if (((data['verification'] as Map)['reason'] ?? '').toString().isNotEmpty) (data['verification'] as Map)['reason'].toString(),
                if (((data['verification'] as Map)['viesName'] ?? '').toString().isNotEmpty) 'VIES név: ${(data['verification'] as Map)['viesName']}',
              ],
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (group != 'approved')
                _actionButton('Jóváhagyás', Colors.greenAccent, () => _setPartnerStatus(doc.id, 'approved')),
              if (group != 'rejected')
                _actionButton('Elutasítás', Colors.redAccent, () => _setPartnerStatus(doc.id, 'rejected')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _partnersTab(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) {
      return const Center(
        child: Text('Nincs partner jelentkezés.', style: TextStyle(color: Colors.white60, fontSize: 14)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: docs.length,
      itemBuilder: (context, index) => _partnerCard(docs[index]),
    );
  }

  // ---------------------------------------------------------------------------
  // Felület
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CyvestaScaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _db.collection('listings').snapshots(),
          builder: (context, listingSnap) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('partners').snapshots(),
              builder: (context, partnerSnap) {
                if (listingSnap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Nem sikerült betölteni a hirdetéseket: ${listingSnap.error}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(listingSnap.data?.docs ?? []);
                docs.sort((a, b) => _millis(b.data()).compareTo(_millis(a.data())));

                final pending = docs.where((d) => _listingGroup(d.data()) == 'pending').toList();
                final approved = docs.where((d) => _listingGroup(d.data()) == 'approved').toList();
                final rejected = docs.where((d) => _listingGroup(d.data()) == 'rejected').toList();

                final partners = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(partnerSnap.data?.docs ?? []);
                partners.sort((a, b) {
                  final ap = (a.data()['status'] ?? 'pending') == 'pending' ? 0 : 1;
                  final bp = (b.data()['status'] ?? 'pending') == 'pending' ? 0 : 1;
                  return ap != bp ? ap.compareTo(bp) : _millis(b.data()).compareTo(_millis(a.data()));
                });
                final pendingPartners = partners.where((d) => (d.data()['status'] ?? 'pending') == 'pending').length;

                return DefaultTabController(
                  length: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Admin Vezérlőpult 🛡️',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white70),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TabBar(
                          isScrollable: true,
                          labelColor: sunnyGold,
                          unselectedLabelColor: Colors.white60,
                          indicatorColor: sunnyGold,
                          tabs: [
                            Tab(text: 'Függő (${pending.length})'),
                            Tab(text: 'Jóváhagyott (${approved.length})'),
                            Tab(text: 'Elutasított (${rejected.length})'),
                            Tab(text: 'Partnerek ($pendingPartners új)'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _listingList(pending, 'Nincs jóváhagyásra váró hirdetés.'),
                              _listingList(approved, 'Nincs jóváhagyott hirdetés.'),
                              _listingList(rejected, 'Nincs elutasított hirdetés.'),
                              _partnersTab(partners),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
