import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state.dart';

/// Egy hirdetéshez tartozó új beszélgetés adatai (a chat az első üzenetnél jön létre).
class ChatSeed {
  final String listingId;
  final String listingTitle;
  final String partnerId;
  final String partnerName;

  const ChatSeed({
    required this.listingId,
    required this.listingTitle,
    required this.partnerId,
    required this.partnerName,
  });
}

class ChatService {
  static final _db = FirebaseFirestore.instance;

  static String chatIdFor(String listingId, String buyerId) => '${listingId}_$buyerId';

  static Future<bool> chatExists(String chatId) async {
    final snap = await _db.collection('chats').doc(chatId).get();
    return snap.exists;
  }

  /// Létrehozza a beszélgetést, ha még nincs (csak a vásárló / érdeklődő hozhatja létre).
  static Future<void> ensureChat(ChatSeed seed) async {
    final uid = AuthState.currentUserId;
    if (uid == null) throw StateError('Nincs bejelentkezve');
    final chatId = chatIdFor(seed.listingId, uid);
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();
    if (snap.exists) return;
    await ref.set({
      'listingId': seed.listingId,
      'listingTitle': seed.listingTitle,
      'partnerId': seed.partnerId,
      'partnerName': seed.partnerName,
      'buyerId': uid,
      'buyerName': AuthState.userName.value,
      'participants': [seed.partnerId, uid],
      'lastMessage': '',
      'lastSenderId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sendMessage(String chatId, String text) async {
    final uid = AuthState.currentUserId;
    if (uid == null) throw StateError('Nincs bejelentkezve');
    final clean = text.trim();
    if (clean.isEmpty) return;
    final chatRef = _db.collection('chats').doc(chatId);
    await chatRef.collection('messages').add({
      'senderId': uid,
      'text': clean.length > 2000 ? clean.substring(0, 2000) : clean,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await chatRef.update({
      'lastMessage': clean.length > 200 ? clean.substring(0, 200) : clean,
      'lastSenderId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .limitToLast(200)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> myChatsStream() {
    final uid = AuthState.currentUserId ?? '';
    return _db.collection('chats').where('participants', arrayContains: uid).snapshots();
  }
}
