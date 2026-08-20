import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final List<Map<String, dynamic>> _dummyConversations = const [
    {
      'name': 'Villa Coral Bay Luxury 🏖️',
      'subtitle': 'Paphos & Coral Bay',
      'lastMessage': 'Hello! The villa is available for those dates.',
      'time': '10:15',
      'unread': 1,
      'avatar': 'assets/images/szarvas.png',
    },
    {
      'name': 'Blue Lagoon VIP Cruise ⛵',
      'subtitle': 'Latchi Harbor',
      'lastMessage': 'Looking forward to welcoming you on board!',
      'time': 'Tegnap',
      'unread': 0,
      'avatar': 'assets/images/yacht.png',
    },
    {
      'name': 'Castle View Steakhouse 🥩',
      'subtitle': 'Kyrenia Old Town',
      'lastMessage': 'Your table reservation is confirmed for 20:00.',
      'time': 'Kedd',
      'unread': 0,
      'avatar': 'assets/images/etterem.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final title = locale == 'hu' ? 'Belső Üzenetek 💬' : 'Direct Messages 💬';

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
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _dummyConversations.length,
                    itemBuilder: (context, index) {
                      final item = _dummyConversations[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF093753),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: mintGreenBorder.withValues(alpha: 0.35)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              item['avatar'] as String,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 48,
                                height: 48,
                                color: deepBlueIcon,
                                child: const Icon(Icons.person, color: mintGreenBorder),
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'] as String,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                item['time'] as String,
                                style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item['lastMessage'] as String,
                              style: TextStyle(
                                color: (item['unread'] as int > 0) ? sunnyGold : Colors.white70,
                                fontSize: 11.5,
                                fontWeight: (item['unread'] as int > 0) ? FontWeight.bold : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: (item['unread'] as int > 0)
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: sunnyGold, shape: BoxShape.circle),
                                  child: Text(
                                    '${item['unread']}',
                                    style: const TextStyle(color: textDark, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_ios_rounded, color: mintGreenBorder, size: 14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  partnerName: item['name'] as String,
                                  partnerSubtitle: item['subtitle'] as String,
                                  avatarPath: item['avatar'] as String,
                                ),
                              ),
                            );
                          },
                        ),
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