import 'package:flutter/foundation.dart';

import 'package:avis_package/src/core/_core.dart';

class RatingProvider extends ChangeNotifier {
  RatingProvider(this._favoriteDriversService);

  final CustomerFavoriteDriversService _favoriteDriversService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Submit rating (e.g. rate driver). Stub: simulates success for now.
  /// When [markAsFavorite] is true, also calls CustomerFavoriteDrivers API.
  Future<bool> submitRating({
    required int tripId,
    required int driverId,
    required int customerId,
    required int rateValue,
    String? comment,
    int? lowRateReason,
    bool markAsFavorite = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (markAsFavorite) {
      final favoriteResult = await _favoriteDriversService.addFavoriteDriver(
        CustomerFavoriteDriversParams(
          chauffeurId: driverId,
          customerId: customerId,
        ),
      );
      if (!favoriteResult.isSuccess) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }
}
