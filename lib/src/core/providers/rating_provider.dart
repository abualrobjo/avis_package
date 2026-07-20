import 'package:flutter/foundation.dart';

import 'package:avis_package/src/core/_core.dart';

/// Lookup category id for rate-dialog reasons.
const int rateReasonLookupCategoryId = 78;

class RatingProvider extends ChangeNotifier {
  RatingProvider(
    this._favoriteDriversService,
    this._rateDriverService,
    this._lookupRepository,
  );

  final CustomerFavoriteDriversService _favoriteDriversService;
  final CustomerRateDriverService _rateDriverService;
  final LookupRepository _lookupRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isLoadingLookup = false;
  String? lookupError;
  List<LookupModel> lookupData = [];

  Future<List<LookupModel>> getLookupByCategoryId({
    required String language,
    required int categoryId,
  }) async {
    isLoadingLookup = true;
    lookupError = null;
    notifyListeners();

    final result = await _lookupRepository.getLookupByCategoryId(
      language: language,
      categoryId: categoryId,
    );
    return result.when(
      success: (data) {
        isLoadingLookup = false;
        lookupData = data;
        notifyListeners();
        return data;
      },
      failure: (error) {
        isLoadingLookup = false;
        lookupError = error.message;
        lookupData = [];
        notifyListeners();
        return [];
      },
    );
  }

  /// Submits rating via CustomerRateDriver.
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

    final rateResult = await _rateDriverService.rateDriver(
      CustomerRateDriverParams(
        tripId: tripId,
        customerId: customerId,
        driverId: driverId,
        rateValue: rateValue,
        comment: comment,
        lowRateReason: lowRateReason,
      ),
    );

    if (!rateResult.isSuccess) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (markAsFavorite) {
      final favoriteResult = await _favoriteDriversService.addFavoriteDriver(
        CustomerFavoriteDriversParams(
          chauffeurId: driverId,
          customerId: customerId,
          tripId: tripId,
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
