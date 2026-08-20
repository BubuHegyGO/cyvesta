import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

class ChatDetailPage extends StatefulWidget {
  final String partnerName;
  final String partnerSubtitle;
  final String avatarPath;

  const ChatDetailPage({
    super.key,
    required this.partnerName,
    required this.partnerSubtitle,
    this.avatarPath = 'assets/images/szarvas.png',
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color turquoiseGlass = Color(0xCC14D1C4);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    final isHu = AppLanguage.currentLocale.value == 'hu';
    _messages = [
      {
        'isMe': false,
        'text': isHu
            ? 'Üdvözöljük Cipruson! Miben segíthetek a szállással / szolgáltatással kapcsolatban?'
            : 'Hello! Welcome to Cyprus. How can I help you regarding this property / service?',
        'time': '10:15',
      },
    ];
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final isHu = AppLanguage.currentLocale.value == 'hu';

    setState(() {
      _messages.add({
        'isMe': true,
        'text': text,
        'time': "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      });
    });
    _msgController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Automatikus válasz az aktuális nyelven
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isMe': false,
            'text': isHu
                ? 'Köszönjük az üzenetet! A partner hamarosan válaszol itt és WhatsApp-on is. 🏝️'
                : 'Thank you for your message! The partner will reply shortly here and on WhatsApp. 🏝️',
            'time': "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          });
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, child) {
        final isHu = locale == 'hu';

        return CyvestaScaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Fejléc
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: deepBlueIcon,
                    border: Border(bottom: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF093753),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: mintGreenBorder, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.avatarPath,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 40,
                            height: 40,
                            color: const Color(0xFF093753),
                            child: const Icon(Icons.person, color: mintGreenBorder),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.partnerName,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.partnerSubtitle,
                              style: const TextStyle(color: mintGreenBorder, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Üzenetek listája
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final isMe = m['isMe'] as bool;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? sunnyGold : const Color(0xFF093753),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            border: Border.all(
                              color: isMe ? Colors.white70 : mintGreenBorder.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['text'] as String,
                                style: TextStyle(
                                  color: isMe ? textDark : Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m['time'] as String,
                                style: TextStyle(
                                  color: isMe ? textDark.withValues(alpha: 0.6) : Colors.white54,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Üzenetküldő beviteli mező
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: deepBlueIcon,
                    border: Border(top: BorderSide(color: mintGreenBorder.withValues(alpha: 0.4))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: isHu ? 'Írj üzenetet...' : 'Type a message...',
                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF093753),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: sunnyGold,
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: textDark, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
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