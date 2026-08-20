import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/data_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  static const Color darkBg = Color(0xFF061822);
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);
  static const Color alertRed = Color(0xFFE63946);

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRejectDialog(String id, String title) {
    final reasonCtrl = TextEditingController(text: 'Kérjük, töltsön fel élesebb fényképeket és pontosítsa az árat!');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: darkBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: alertRed, width: 1.5)),
        title: Text('Hirdetés Elutasítása: $title', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add meg az elutasítás okát, amit a hirdető megkap:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 12.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: deepBlueIcon,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mégse', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: alertRed, foregroundColor: Colors.white),
            onPressed: () {
              DataService.rejectAccommodation(id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: deepBlueIcon, content: Text('❌ $title hirdetés elutasítva!', style: const TextStyle(color: Colors.white))),
              );
            },
            child: const Text('Elutasítás'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
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
          'Admin Moderációs Központ 🛡️',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: sunnyGold,
          labelColor: sunnyGold,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
          tabs: const [
            Tab(icon: Icon(Icons.pending_actions_rounded, size: 18), text: 'Jóváhagyásra vár'),
            Tab(icon: Icon(Icons.verified_rounded, size: 18), text: 'Éles Hirdetések'),
            Tab(icon: Icon(Icons.block_rounded, size: 18), text: 'Elutasított'),
          ],
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: DataService.accommodations,
        builder: (context, list, child) {
          final pending = list.where((item) => item['status'] == 'pending').toList();
          final approved = list.where((item) => item['status'] == 'approved' || item['status'] == null).toList();
          final rejected = list.where((item) => item['status'] == 'rejected').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(pending, 'pending'),
              _buildList(approved, 'approved'),
              _buildList(rejected, 'rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'pending' ? Icons.check_circle_outline_rounded : Icons.inbox_rounded,
              color: mintGreenBorder,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              type == 'pending' ? 'Nincs jóváhagyásra váró hirdetés!' : 'Nincs megjeleníthető elem',
              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item['id'] as String;
        final title = item['title'] ?? 'Névtelen hirdetés';
        final location = item['location'] ?? 'Ciprus';
        final price = item['price'] ?? '';
        final whatsapp = item['whatsapp'] ?? 'Nincs megadva';
        final website = item['website'];
        final desc = item['description'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xE6072A40),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: type == 'pending' ? sunnyGold : (type == 'approved' ? mintGreenBorder : alertRed),
              width: 1.4,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: type == 'pending' ? sunnyGold : (type == 'approved' ? mintGreenBorder : alertRed),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type == 'pending' ? '⏳ ELLENŐRZENDŐ' : (type == 'approved' ? '✅ ÉLES' : '❌ ELUTASÍTVA'),
                      style: const TextStyle(color: textDark, fontSize: 9.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('📍 $location  |  💰 $price', style: const TextStyle(color: sunnyGold, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('📱 Kapcsolat: $whatsapp', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
              if (website != null && website.toString().isNotEmpty) ...[
                const SizedBox(height: 2),
                InkWell(
                  onTap: () => _launchUrl(website),
                  child: Text('🌐 Web: $website', style: const TextStyle(color: turquoiseGlass, fontSize: 11.5, decoration: TextDecoration.underline)),
                ),
              ],
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Colors.white60, fontSize: 11.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Divider(color: Colors.white12, height: 16),

              // GOMBOK
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (type == 'pending') ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: alertRed, side: const BorderSide(color: alertRed)),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Elutasítás', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showRejectDialog(id, title),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: mintGreenBorder, foregroundColor: textDark),
                      icon: const Icon(Icons.check, size: 16, color: textDark),
                      label: const Text('Jóváhagyás & Élesítés ✅', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      onPressed: () {
                        DataService.approveAccommodation(id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: deepBlueIcon, content: Text('🎉 $title sikeresen jóváhagyva és élesítve!', style: const TextStyle(color: mintGreenBorder, fontWeight: FontWeight.bold))),
                        );
                      },
                    ),
                  ] else if (type == 'approved') ...[
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 16),
                      label: const Text('Törlés', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      onPressed: () => DataService.deleteListing(id),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: alertRed, side: const BorderSide(color: alertRed)),
                      icon: const Icon(Icons.block, size: 16),
                      label: const Text('Felfüggesztés', style: TextStyle(fontSize: 12)),
                      onPressed: () => DataService.rejectAccommodation(id),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: mintGreenBorder, foregroundColor: textDark),
                      icon: const Icon(Icons.restore_rounded, size: 16),
                      label: const Text('Visszaállítás & Jóváhagyás', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => DataService.approveAccommodation(id),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}