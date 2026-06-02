import 'package:cloud_firestore/cloud_firestore.dart';

/// A single chat message in a trip-based chat (chat id = trip id).
class ChatMessageModel {
  final String id;
  final String text;
  /// Sender identifier: "driver_$userId" for driver, "customer" for customer.
  final String senderId;
  final String senderDisplayName;
  final DateTime createdAt;
  final bool read;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderDisplayName,
    required this.createdAt,
    this.read = false,
  });

  factory ChatMessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    final ts = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (ts != null) {
      if (ts is DateTime) {
        createdAt = ts;
      } else if (ts is Timestamp) {
        createdAt = ts.toDate();
      } else {
        createdAt = DateTime.tryParse(ts.toString()) ?? createdAt;
      }
    }
    return ChatMessageModel(
      id: id,
      text: data['text']?.toString() ?? '',
      senderId: data['senderId']?.toString() ?? '',
      senderDisplayName: data['senderDisplayName']?.toString() ?? '',
      createdAt: createdAt,
      read: data['read'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderDisplayName': senderDisplayName,
      'createdAt': createdAt,
      'read': read,
    };
  }

  bool get isFromDriver => senderId.startsWith('driver_');
}
