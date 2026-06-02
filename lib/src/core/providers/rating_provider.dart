import 'package:flutter/foundation.dart';

class RatingProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Submit rating (e.g. rate driver). Stub: simulates success for now.
  Future<bool> submitRating({
    required int tripId,
    required int driverId,
    required int rateValue,
    String? comment,
    int? lowRateReason,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
