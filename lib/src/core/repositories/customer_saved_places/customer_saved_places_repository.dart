import 'package:avis_package/src/core/_core.dart';

abstract class CustomerSavedPlacesRepository {
  Future<Result<List<CustomerSavedPlaceModel>, NetworkException>>
  getCustomerSavedPlaces(GetCustomerSavedPlacesParams params);

  Future<Result<String?, NetworkException>> addCustomerSavedPlace(
    AddCustomerSavedPlaceParams params,
  );

  Future<Result<String?, NetworkException>> deleteSavedPlace(int placeId);
}