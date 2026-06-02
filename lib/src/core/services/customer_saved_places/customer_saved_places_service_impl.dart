import 'package:avis_package/src/core/_core.dart';

class CustomerSavedPlacesServiceImpl implements CustomerSavedPlacesService {
  const CustomerSavedPlacesServiceImpl();

  @override
  Future<Result<List<CustomerSavedPlaceModel>, NetworkException>>
  getCustomerSavedPlaces(GetCustomerSavedPlacesParams params) async {
    return await dioClient.get<List<CustomerSavedPlaceModel>>(
      endpoint: ApiEndpoints.getCustomerSavedPlaces,
      body: params.toJson(),
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          if (raw == null) return <CustomerSavedPlaceModel>[];
          final list = raw as List<dynamic>;
          return list
              .map(
                (e) =>
                    CustomerSavedPlaceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        });

        return response.data;
      },
    );
  }

  @override
  Future<Result<String?, NetworkException>> addCustomerSavedPlace(
    AddCustomerSavedPlaceParams params,
  ) async {
    return await dioClient.post<String?>(
      endpoint: ApiEndpoints.addCustomerSavedPlace,
      body: params.toJson(),
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          return raw as String?;
        });

        return response.data;
      },
    );
  }

  @override
  Future<Result<String?, NetworkException>> deleteSavedPlace(
    int placeId,
  ) async {
    return await dioClient.patch<String?>(
      endpoint: ApiEndpoints.deleteSavedPlace,
      queryParameters: {'PlaceId': placeId},
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          return raw as String?;
        });

        return response.data;
      },
    );
  }
}
