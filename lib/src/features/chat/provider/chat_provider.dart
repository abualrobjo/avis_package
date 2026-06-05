import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

/// Customer app: "me" = customer, "contact" = driver. Chat id = trip id.
class ChatProvider extends ChangeNotifier {
  ChatProvider(this._chatRepository);

  final ChatRepository _chatRepository;

  StreamSubscription<List<ChatMessageModel>>? _messagesSub;
  StreamSubscription<String?>? _typingSub;

  String? _tripId;
  String? _driverDisplayName;
  String? _contactDisplayName;

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

  static const String _customerSenderId = 'customer';

  bool get isContactTyping =>
      _typingParticipantId != null && _typingParticipantId != _customerSenderId;

  void startChat({
    required String tripId,
    required String driverDisplayName,
    required String contactDisplayName,
    String? contactPhone,
    String? driverId,
    String? customerDisplayName,
  }) {
    final effectiveTripId = tripId.trim();
    if (effectiveTripId.isEmpty) return;
    _tripId = effectiveTripId;
    _driverDisplayName = driverDisplayName;
    _contactDisplayName = contactDisplayName;
    _messages = [];
    _typingParticipantId = null;
    _messagesSub?.cancel();
    _typingSub?.cancel();

    try {
      _chatRepository.ensureChatMetadata(
        tripId: effectiveTripId,
        driverId: driverId ?? '',
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
