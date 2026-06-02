import 'dart:convert';
import 'package:avis_package/src/core/_core.dart';

class PaymentCardsLocalService {
  final HiveService _hiveService;

  PaymentCardsLocalService(this._hiveService);

  static const String _boxName = 'payment_cards_box';
  static const String _cardsKey = 'saved_cards';

  Future<void> saveCards(List<PaymentCard> cards) async {
    final List<Map<String, dynamic>> cardsJson = cards
        .map((c) => c.toJson())
        .toList();
    final String encoded = jsonEncode(cardsJson);
    await _hiveService.put(_boxName, _cardsKey, encoded);
  }

  List<PaymentCard> getSavedCards() {
    final String? encoded = _hiveService.get<String>(_boxName, _cardsKey);
    if (encoded == null || encoded.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded
          .map((json) => PaymentCard.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
