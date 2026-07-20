import 'package:avis_package/src/core/_core.dart';
import 'package:flutter/material.dart';

enum CancellationState { initial, loading, success, error }

class CancellationProvider extends ChangeNotifier {
  final CancellationRepository _cancellationRepository;

  CancellationProvider(this._cancellationRepository);

  CancellationState _cancellationState = CancellationState.initial;
  CancellationState get cancellationState => _cancellationState;

  int? _cancellationStatus;
  int? get cancellationStatus => _cancellationStatus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CancelationCategoryModel> _cancelationCategories = [];
  List<CancelationCategoryModel> get cancelationCategories =>
      _cancelationCategories;

  bool _loadingCategories = false;
  bool get loadingCategories => _loadingCategories;

  String? _categoriesErrorMessage;
  String? get categoriesErrorMessage => _categoriesErrorMessage;

  Future<void> fetchCancelationCategories({
    int categoryId = 77,
    bool all = false,
  }) async {
    _loadingCategories = true;
    _categoriesErrorMessage = null;
    notifyListeners();

    final response = await _cancellationRepository.getCancelationCategories(
      categoryId: categoryId,
      all: all,
    );

    response.when(
      success: (categories) {
        _cancelationCategories = categories;
        _loadingCategories = false;
        notifyListeners();
      },
      failure: (failure) {
        _categoriesErrorMessage = failure.message;
        _cancelationCategories = [];
        _loadingCategories = false;
        notifyListeners();
      },
    );
  }

  Future<void> cancelRideRequest(
    int id, {
    required int cancelationReasonId,
  }) async {
    _cancellationState = CancellationState.loading;
    notifyListeners();

    final response = await _cancellationRepository.cancelRideRequest(
      id,
      cancelationReasonId: cancelationReasonId,
    );

    await response.when(
      success: (succes) {
        _cancellationStatus = succes;
        _cancellationState = CancellationState.success;
        notifyListeners();
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _cancellationState = CancellationState.error;
        notifyListeners();
      },
    );
  }
}
