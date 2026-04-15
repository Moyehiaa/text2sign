import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime? timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      isRead: data['isRead'] ?? false,
    );
  }
}
