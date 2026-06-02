import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart' show PaymentCard, PaymentCardsLocalService;

class AddNewCardProvider extends ChangeNotifier {
  final PaymentCardsLocalService _localService;

  List<PaymentCard> _savedCards = [];
  List<PaymentCard> _temporaryCards = [];

  AddNewCardProvider(this._localService) {
    _loadSavedCards();
  }

  List<PaymentCard> get cards => [..._savedCards, ..._temporaryCards];

  void _loadSavedCards() {
    _savedCards = _localService.getSavedCards();
    notifyListeners();
  }

  Future<void> _syncToHive() async {
    await _localService.saveCards(_savedCards);
  }

  void addCard(PaymentCard card, {bool saveForLater = false}) {
    if (saveForLater) {
      _savedCards = [..._savedCards, card];
      _syncToHive();
    } else {
      _temporaryCards = [..._temporaryCards, card];
    }
    notifyListeners();
  }

  void deleteCard(String id) {
    bool foundInSaved = false;

    // update saved
    final initialSavedLength = _savedCards.length;
    _savedCards = _savedCards.where((card) => card.id != id).toList();
    if (_savedCards.length != initialSavedLength) {
      foundInSaved = true;
    }

    // update temp
    _temporaryCards = _temporaryCards.where((card) => card.id != id).toList();

    if (foundInSaved) {
      _syncToHive();
    }

    notifyListeners();
  }

  void setAsDefault(String id) {
    bool hasChangesInSaved = false;

    _savedCards = _savedCards.map((card) {
      final isNowDefault = card.id == id;
      if (card.isDefault != isNowDefault) hasChangesInSaved = true;
      return card.copyWith(isDefault: isNowDefault);
    }).toList();

    _temporaryCards = _temporaryCards.map((card) {
      return card.copyWith(isDefault: card.id == id);
    }).toList();

    if (hasChangesInSaved) {
      _syncToHive();
    }

    notifyListeners();
  }
}
