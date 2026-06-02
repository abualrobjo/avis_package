import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageModel>> watchMessages(String tripId);

  Stream<List<ChatConversationModel>> watchConversations(String driverId);

  Future<void> ensureChatMetadata({
    required String tripId,
    required String driverId,
    required String contactDisplayName,
    String? contactPhone,
    String? driverDisplayName,
  });

  Future<void> sendMessage({
    required String tripId,
    required String text,
    required String senderId,
    required String senderDisplayName,
  });

  Future<void> setTyping(String tripId, String participantId, bool isTyping);

  Stream<String?> watchTyping(String tripId);
}
