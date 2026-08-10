import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:avis_package/src/core/services/app_auth/auth_local_service.dart';
import 'package:avis_package/src/core/services/firebase_chat_auth_service.dart';
import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

/// Customer app: "me" = customer, "contact" = driver. Chat id = trip id.
class ChatProvider extends ChangeNotifier {
  ChatProvider(
    this._chatRepository,
    this._authLocalService,
    this._firebaseChatAuth,
  );

  final ChatRepository _chatRepository;
  final AuthLocalService _authLocalService;
  final FirebaseChatAuthService _firebaseChatAuth;

  StreamSubscription<List<ChatMessageModel>>? _messagesSub;
  StreamSubscription<String?>? _typingSub;

  String? _tripId;
  String? _driverDisplayName;
  String? _contactDisplayName;
  String _customerSenderId = 'customer';

  String? get driverDisplayName => _driverDisplayName;

  List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => _messages;

  String? _typingParticipantId;
  String? get typingParticipantId => _typingParticipantId;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool get isContactTyping {
    final id = _typingParticipantId;
    if (id == null || id.isEmpty) return false;
    if (id == _customerSenderId || id == 'customer') return false;
    if (id.startsWith('customer_')) return false;
    return true;
  }

  Future<void> startChat({
    required String tripId,
    required String driverDisplayName,
    required String contactDisplayName,
    String? contactPhone,
    String? driverId,
    String? customerDisplayName,
  }) async {
    final effectiveTripId = tripId.trim();
    if (effectiveTripId.isEmpty) return;
    _tripId = effectiveTripId;
    _driverDisplayName = driverDisplayName;
    _contactDisplayName = contactDisplayName;
    _messages = [];
    _typingParticipantId = null;
    _errorMessage = null;
    await _messagesSub?.cancel();
    await _typingSub?.cancel();
    _messagesSub = null;
    _typingSub = null;

    final customerId = _authLocalService.getCustomerId();
    if (customerId == null) {
      _errorMessage = 'Login required for chat';
      notifyListeners();
      return;
    }

    _customerSenderId = FirebaseChatAuthService.customerUid(customerId);

    try {
      await _firebaseChatAuth.ensureCustomerSignedIn(customerId);

      await _chatRepository.ensureChatMetadata(
        tripId: effectiveTripId,
        driverId: driverId ?? '',
        customerId: _customerSenderId,
        contactDisplayName: customerDisplayName ?? contactDisplayName,
        contactPhone: contactPhone,
        driverDisplayName: driverDisplayName,
      );

      _messagesSub = _chatRepository
          .watchMessages(effectiveTripId)
          .listen(
            (list) {
              _errorMessage = null;
              final pending = _messages
                  .where((m) => m.id.startsWith('pending_'))
                  .toList();
              _messages = [...list];
              for (final p in pending) {
                final hasMatch = list.any(
                  (m) =>
                      m.text == p.text &&
                      m.senderId == p.senderId &&
                      (m.createdAt.difference(p.createdAt).inSeconds.abs() <
                          15),
                );
                if (!hasMatch) _messages.add(p);
              }
              _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              notifyListeners();
            },
            onError: (Object e, StackTrace st) {
              _errorMessage = 'Failed to load messages: $e';
              notifyListeners();
            },
          );

      _typingSub = _chatRepository.watchTyping(effectiveTripId).listen((id) {
        _typingParticipantId = id;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Chat unavailable: $e';
      notifyListeners();
    }
  }

  void disposeChat() {
    if (_tripId != null) {
      try {
        _chatRepository.setTyping(_tripId!, _customerSenderId, false);
      } catch (_) {}
    }
    _messagesSub?.cancel();
    _typingSub?.cancel();
    _tripId = null;
  }

  Future<bool> sendMessage(String text) async {
    final tripId = _tripId;
    if (tripId == null || tripId.isEmpty || text.trim().isEmpty) return false;
    _errorMessage = null;
    final trimmed = text.trim();
    final optimistic = ChatMessageModel(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      senderId: _customerSenderId,
      senderDisplayName: 'Customer',
      createdAt: DateTime.now(),
      read: false,
    );
    _messages = [..._messages, optimistic];
    notifyListeners();
    try {
      await _chatRepository.sendMessage(
        tripId: tripId,
        text: trimmed,
        senderId: _customerSenderId,
        senderDisplayName: 'Customer',
      );
      await setTyping(false);
      return true;
    } catch (e, _) {
      _errorMessage = 'Send failed: $e';
      _messages = _messages.where((m) => m.id != optimistic.id).toList();
      notifyListeners();
      return false;
    }
  }

  Future<void> setTyping(bool isTyping) async {
    final tripId = _tripId;
    if (tripId == null) return;
    await _chatRepository.setTyping(tripId, _customerSenderId, isTyping);
  }

  String get contactDisplayName => _contactDisplayName ?? 'Driver';
}
