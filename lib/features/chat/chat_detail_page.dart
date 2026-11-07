import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/services/auth_state.dart';
import '../../core/services/chat_service.dart';
import '../../core/widgets/cyvesta_scaffold.dart';

/// Valódi (Firestore-alapú) beszélgetés két fél között.
/// - Meglévő chat: [chatId] megadva.
/// - Új chat egy hirdetésből: [seed] megadva, a chat az első üzenetnél jön létre.
class ChatDetailPage extends StatefulWidget {
  final String? chatId;
  final ChatSeed? seed;
  final String partnerName;
  final String partnerSubtitle;
  final String? initialText;

  const ChatDetailPage({
    super.key,
    this.chatId,
    this.seed,
    required this.partnerName,
    required this.partnerSubtitle,
    this.initialText,
  }) : assert(chatId != null || seed != null);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  static const Color mintGreenBorder = Color(0xFF99FF99);
  static const Color deepBlueIcon = Color(0xFF072A40);
  static const Color textDark = Color(0xFF0F172A);
  static const Color sunnyGold = Color(0xFFFF9F1C);

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final String _chatId;
  bool _chatExists = false;
  bool _checking = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    final uid = AuthState.currentUserId ?? '';
    _chatId = widget.chatId ?? ChatService.chatIdFor(widget.seed!.listingId, uid);
    if (widget.initialText != null) _msgController.text = widget.initialText!;
    _init();
  }

  Future<void> _init() async {
    try {
      _chatExists = await ChatService.chatExists(_chatId);
    } catch (_) {
      _chatExists = false;
    }
    if (mounted) setState(() => _checking = false);
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      if (!_chatExists && widget.seed != null) {
        await ChatService.ensureChat(widget.seed!);
        _chatExists = true;
      }
      await ChatService.sendMessage(_chatId, text);
      _msgController.clear();
      _scrollToEnd();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Az üzenet nem ment el: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _time(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Widget _bubble(Map<String, dynamic> m, bool isMe) {
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
          border: Border.all(color: isMe ? Colors.white70 : mintGreenBorder.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              m['text']?.toString() ?? '',
              style: TextStyle(color: isMe ? textDark : Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _time(m['createdAt'] is Timestamp ? m['createdAt'] as Timestamp : null),
              style: TextStyle(color: isMe ? textDark.withValues(alpha: 0.6) : Colors.white54, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messages(bool isHu) {
    if (_checking) return const Center(child: CircularProgressIndicator());
    if (!_chatExists) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isHu ? 'Írd meg az első üzenetet a hirdetőnek!' : 'Send the first message to the host!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      );
    }
    final me = AuthState.currentUserId;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ChatService.messagesStream(_chatId),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Text('Hiba az üzenetek betöltésekor: ${snap.error}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          );
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(14),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final m = docs[i].data();
            return _bubble(m, m['senderId'] == me);
          },
        );
      },
    );
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
                      const CircleAvatar(
                        backgroundColor: Color(0xFF093753),
                        child: Icon(Icons.person, color: mintGreenBorder),
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
                Expanded(child: _messages(isHu)),
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
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 2000,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: isHu ? 'Írj üzenetet...' : 'Type a message...',
                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF093753),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: sunnyGold,
                        child: _sending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: textDark))
                            : IconButton(
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
