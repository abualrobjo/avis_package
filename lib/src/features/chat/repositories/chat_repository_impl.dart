import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';

import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl();

  FirebaseFirestore get _firestore {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized');
    }
    return FirebaseFirestore.instance;
  }

  static const String _chatsCollection = 'chats';
  static const String _messagesSubcollection = 'messages';
  static const String _typingSubcollection = 'typing';
  static const Duration _typingExpiry = Duration(seconds: 5);

  CollectionReference<Map<String, dynamic>> _chatsCol() =>
      _firestore.collection(_chatsCollection);

  DocumentReference<Map<String, dynamic>> _chatMetaDoc(String tripId) =>
      _chatsCol().doc(tripId);

  CollectionReference<Map<String, dynamic>> _chatDoc(String tripId) =>
      _firestore
          .collection(_chatsCollection)
          .doc(tripId)
          .collection(_messagesSubcollection);

  CollectionReference<Map<String, dynamic>> _typingCol(String tripId) =>
      _firestore
          .collection(_chatsCollection)
          .doc(tripId)
          .collection(_typingSubcollection);

  @override
  Stream<List<ChatMessageModel>> watchMessages(String tripId) {
    return _chatDoc(
      tripId,
    ).orderBy('createdAt', descending: false).snapshots().map((snap) {
      final list = <ChatMessageModel>[];
      for (final d in snap.docs) {
        try {
          list.add(ChatMessageModel.fromFirestore(d.data(), d.id));
        } catch (_) {}
      }
      return list;
    });
  }

  @override
  Stream<List<ChatConversationModel>> watchConversations(String driverId) {
    return _chatsCol()
        .where('driverId', isEqualTo: driverId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) {
          final list = <ChatConversationModel>[];
          for (final d in snap.docs) {
            try {
              list.add(ChatConversationModel.fromFirestore(d.data(), d.id));
            } catch (_) {}
          }
          return list;
        });
  }

  @override
  Future<void> ensureChatMetadata({
    required String tripId,
    required String driverId,
    required String contactDisplayName,
    String? contactPhone,
    String? driverDisplayName,
  }) async {
    final ref = _chatMetaDoc(tripId);
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();
    if (!snap.exists) {
      await ref.set({
        'driverId': driverId,
        'contactDisplayName': contactDisplayName,
        'contactPhone': ?contactPhone,
        'driverDisplayName': ?driverDisplayName,
        'lastMessageAt': now,
      });
    } else {
      await ref.update({
        'contactDisplayName': contactDisplayName,
        'contactPhone': ?contactPhone,
        'driverDisplayName': ?driverDisplayName,
      });
    }
  }

  @override
  Future<void> sendMessage({
    required String tripId,
    required String text,
    required String senderId,
    required String senderDisplayName,
  }) async {
    final ref = _chatDoc(tripId).doc();
    final now = Timestamp.now();
    await ref.set({
      'text': text,
      'senderId': senderId,
      'senderDisplayName': senderDisplayName,
      'createdAt': now,
      'read': false,
    });
    final meta = <String, dynamic>{'lastMessage': text, 'lastMessageAt': now};
    if (senderId.startsWith('driver_')) meta['driverId'] = senderId;
    await _chatMetaDoc(tripId).set(meta, SetOptions(merge: true));
  }

  @override
  Future<void> setTyping(
    String tripId,
    String participantId,
    bool isTyping,
  ) async {
    final ref = _typingCol(tripId).doc(participantId);
    if (isTyping) {
      await ref.set({'at': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }

  @override
  Stream<String?> watchTyping(String tripId) {
    return _typingCol(tripId).snapshots().map((snap) {
      final now = DateTime.now();
      for (final doc in snap.docs) {
        final at = doc.data()['at'];
        final atTime = at is Timestamp
            ? at.toDate()
            : (at != null ? DateTime.tryParse(at.toString()) : null);
        if (atTime != null && now.difference(atTime) < _typingExpiry) {
          return doc.id;
        }
      }
      return null;
    });
  }
}
