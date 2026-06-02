import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationModel {
  final String tripId;
  final String contactDisplayName;
  final String? contactPhone;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  const ChatConversationModel({
    required this.tripId,
    required this.contactDisplayName,
    this.contactPhone,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ChatConversationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    final lastAt = data['lastMessageAt'];
    DateTime? lastMessageAt;
    if (lastAt != null) {
      if (lastAt is Timestamp) {
        lastMessageAt = lastAt.toDate();
      } else {
        lastMessageAt = DateTime.tryParse(lastAt.toString());
      }
    }
    return ChatConversationModel(
      tripId: id,
      contactDisplayName: data['contactDisplayName']?.toString() ?? 'Driver',
      contactPhone: data['contactPhone']?.toString(),
      lastMessage: data['lastMessage']?.toString(),
      lastMessageAt: lastMessageAt,
    );
  }
}
