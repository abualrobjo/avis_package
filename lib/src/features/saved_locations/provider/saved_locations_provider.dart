import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:avis_package/src/core/_core.dart';

class SavedLocationsProvider extends ChangeNotifier {
  final CustomerSavedPlacesRepository _customerSavedPlacesRepository;

  List<CustomerSavedPlaceModel> _locations = [];
  List<CustomerSavedPlaceModel> get locations => _locations;

  CustomerSavedPlaceModel? _selectedLocation;
  CustomerSavedPlaceModel? get selectedLocation => _selectedLocation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  SavedLocationsProvider(this._customerSavedPlacesRepository);

  int? getCustomerId() {
    return sl<AuthLocalService>().getCustomerId();
  }

  Future<void> getCustomerSavedPlaces() async {
    final customerId = getCustomerId();
    if (customerId == null) return;

    // API body expects current location for latitude/longtitude.
    String lat = '';
    String lng = '';
    try {
      if (await Geolocator.isLocationServiceEnabled() &&
          (await Geolocator.checkPermission() == LocationPermission.whileInUse ||
              await Geolocator.checkPermission() == LocationPermission.always)) {
        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude.toString();
        lng = pos.longitude.toString();
      }
    } catch (_) {}

    final params = GetCustomerSavedPlacesParams(
      customerId: customerId,
      latitude: lat,
      longtitude: lng,
    );

    _isLoading = true;
    notifyListeners();

    final result = await _customerSavedPlacesRepository.getCustomerSavedPlaces(
      params,
    );
    result.when(
      success: (locations) {
        _locations = locations;
        _isLoading = false;
        notifyListeners();
      },
      failure: (failure) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addCustomerSavedPlace({
    required AddCustomerSavedPlaceParams params,
  }) async {
    _isLoading = true;
    notifyListeners();

    final customerId = getCustomerId();
    if (customerId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // API body: lat/long = location user chose (e.g. from map picker), not current device location.
    final result = await _customerSavedPlacesRepository.addCustomerSavedPlace(
      params.copyWith(
        customerId: customerId,
        placeCategoryId: AddCustomerSavedPlaceParams.placeCategory,
      ),
    );
    result.when(
      success: (message) {
        getCustomerSavedPlaces();
      },
      failure: (failure) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> deleteSavedPlace({required int placeId}) async {
    final result = await _customerSavedPlacesRepository.deleteSavedPlace(
      placeId,
    );
    result.when(
      success: (message) {
        getCustomerSavedPlaces();
      },
      failure: (failure) {},
    );
  }

  void setSelectedLocation(CustomerSavedPlaceModel location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void calculateDistances(double currentLat, double currentLng) {
    for (var loc in _locations) {
      if (loc.latitude != null && loc.longtitude != null) {
        final lat = double.tryParse(loc.latitude!);
        final lng = double.tryParse(loc.longtitude!);
        if (lat != null && lng != null) {
          final meters = Geolocator.distanceBetween(
            currentLat,
            currentLng,
            lat,
            lng,
          );
          loc.distanceInKm = meters / 1000.0;
        }
      }
    }
    notifyListeners();
  }
}
