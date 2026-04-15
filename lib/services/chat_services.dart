import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:text2sign/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  String generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  Future<String> createOrGetChat({required String otherUserId}) async {
    final chatId = generateChatId(currentUserId, otherUserId);

    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => MessageModel.fromDoc(doc)).toList(),
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'senderId': currentUserId,
      'receiverId': receiverId,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }
}
