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

  Future<void> cancelRideRequest(int id) async {
    _cancellationState = CancellationState.loading;

    final response = await _cancellationRepository.cancelRideRequest(id);

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
