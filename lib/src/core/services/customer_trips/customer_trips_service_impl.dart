import 'package:avis_package/src/core/_core.dart';

class CustomerTripsServiceImpl implements CustomerTripsService {
  CustomerTripsServiceImpl();

  @override
  Future<Result<List<CustomerTripDetailModel>, NetworkException>>
  getCustomerTripsHistory(int customerId) async {
    return await dioClient.get<List<CustomerTripDetailModel>>(
      endpoint: ApiEndpoints.customerTripsHistory,
      queryParameters: {'CustomerId': customerId},
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          if (raw == null) return <CustomerTripDetailModel>[];
          final list = raw as List<dynamic>;
          return list
              .map(
                (e) =>
                    CustomerTripDetailModel.fromJson(e as Map<String, dynamic>),
              )
              .toList();
        });

        return response.data;
      },
    );
  }

  @override
  Future<Result<CustomerTripByIdModel, NetworkException>> getCustomerTripById(
    int tripId,
  ) async {
    return await dioClient.get<CustomerTripByIdModel>(
      endpoint: ApiEndpoints.getCustomerTripById,
      queryParameters: {'TripId': tripId},
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          if (raw == null) {
            throw Exception('Customer trip details not found in response');
          }
          return CustomerTripByIdModel.fromJson(raw as Map<String, dynamic>);
        });
        return response.data;
      },
    );
  }
}
