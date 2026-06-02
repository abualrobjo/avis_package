import 'package:avis_package/src/core/_core.dart';

class CustomerSavedPlacesRepositoryImpl
    implements CustomerSavedPlacesRepository {
  const CustomerSavedPlacesRepositoryImpl(this._customerSavedPlacesService);

  final CustomerSavedPlacesService _customerSavedPlacesService;

  @override
  Future<Result<List<CustomerSavedPlaceModel>, NetworkException>>
  getCustomerSavedPlaces(GetCustomerSavedPlacesParams params) async {
    return await _customerSavedPlacesService.getCustomerSavedPlaces(params);
  }

  @override
  Future<Result<String?, NetworkException>> addCustomerSavedPlace(
    AddCustomerSavedPlaceParams params,
  ) async {
    return await _customerSavedPlacesService.addCustomerSavedPlace(params);
  }

  @override
  Future<Result<String?, NetworkException>> deleteSavedPlace(
    int placeId,
  ) async {
    return await _customerSavedPlacesService.deleteSavedPlace(placeId);
  }
}
