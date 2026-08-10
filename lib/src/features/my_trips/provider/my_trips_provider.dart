import 'package:flutter/material.dart';
import 'package:avis_package/src/core/_core.dart';

class MyTripsProvider extends ChangeNotifier {
  MyTripsProvider(this._customerTripsRepository, this._authLocalService);

  final CustomerTripsRepository _customerTripsRepository;
  final AuthLocalService _authLocalService;

  List<CustomerTripDetailModel> _trips = [];
  bool _loading = false;
  String? _errorMessage;

  bool _loadingTripById = false;
  CustomerTripByIdModel? _tripById;
  String? _tripByIdErrorMessage;

  List<CustomerTripDetailModel> get trips => _trips;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  bool get loadingTripById => _loadingTripById;
  CustomerTripByIdModel? get tripById => _tripById;
  String? get tripByIdErrorMessage => _tripByIdErrorMessage;

  Future<void> getCustomerTripsHistory() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final customerId = _authLocalService.getCustomerId();
    if (customerId == null) {
      _loading = false;
      _errorMessage = AppConst.loginRequiredMessage;
      notifyListeners();
      return;
    }
    final response = await _customerTripsRepository.getCustomerTripsHistory(
      customerId,
    );

    response.when(
      success: (success) {
        _trips = success;
        _errorMessage = null;
        _loading = false;
        notifyListeners();
      },
      failure: (failure) {
        _errorMessage = failure.message;
        _trips = [];
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getCustomerTripById(int tripId) async {
    _loadingTripById = true;
    _tripByIdErrorMessage = null;
    notifyListeners();

    final response = await _customerTripsRepository.getCustomerTripById(tripId);

    response.when(
      success: (success) {
        _tripById = success;
        _loadingTripById = false;
        notifyListeners();
      },
      failure: (failure) {
        _tripByIdErrorMessage = failure.message;
        _loadingTripById = false;
        notifyListeners();
      },
    );
  }
}
