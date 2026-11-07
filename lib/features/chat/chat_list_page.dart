import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/auth_state.dart';
import '../../core/services/chat_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color deepBlueIcon = Color(0xFF072A40);

  String _fmt(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}.';
  }

  Widget _empty(String text) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isHu = locale == 'hu';
        final title = isHu ? 'Belső Üzenetek 💬' : 'Direct Messages 💬';
        final me = AuthState.currentUserId;

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
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Expanded(
                  child: me == null
                      ? _empty(isHu ? 'Az üzenetek megtekintéséhez jelentkezz be.' : 'Please log in to see your messages.')
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: ChatService.myChatsStream(),
                          builder: (context, snap) {
                            if (snap.hasError) return _empty('Hiba: ${snap.error}');
                            if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                            // Csak az üzenetet tartalmazó beszélgetések, legfrissebb elöl.
                            final docs = snap.data!.docs.where((d) => (d.data()['lastMessage'] ?? '').toString().isNotEmpty).toList()
                              ..sort((a, b) {
                                final ta = a.data()['updatedAt'];
                                final tb = b.data()['updatedAt'];
                                final da = ta is Timestamp ? ta.millisecondsSinceEpoch : 0;
                                final db = tb is Timestamp ? tb.millisecondsSinceEpoch : 0;
                                return db.compareTo(da);
                              });

                            if (docs.isEmpty) {
                              return _empty(isHu
                                  ? 'Még nincs beszélgetésed. Egy hirdetés oldaláról tudsz üzenni a hirdetőnek.'
                                  : 'No conversations yet. Message a host from a listing page.');
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final d = doc.data();
                                final iAmBuyer = d['buyerId'] == me;
                                final otherName = (iAmBuyer ? d['partnerName'] : d['buyerName'])?.toString() ?? '';
                                final name = otherName.isNotEmpty ? otherName : (isHu ? 'Felhasználó' : 'User');
                                final listingTitle = d['listingTitle']?.toString() ?? '';
                                final unread = d['lastSenderId'] != me;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF093753),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: mintGreenBorder.withValues(alpha: 0.35)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    leading: const CircleAvatar(
                                      backgroundColor: deepBlueIcon,
                                      child: Icon(Icons.person, color: mintGreenBorder),
                                    ),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          _fmt(d['updatedAt'] is Timestamp ? d['updatedAt'] as Timestamp : null),
                                          style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(listingTitle,
                                              style: const TextStyle(color: mintGreenBorder, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 2),
                                          Text(
                                            (d['lastMessage'] ?? '').toString(),
                                            style: TextStyle(
                                              color: unread ? const Color(0xFFFF9F1C) : Colors.white70,
                                              fontSize: 11.5,
                                              fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: mintGreenBorder, size: 14),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatDetailPage(
                                            chatId: doc.id,
                                            partnerName: name,
                                            partnerSubtitle: listingTitle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
