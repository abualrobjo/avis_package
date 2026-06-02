import 'package:avis_package/src/core/_core.dart';

abstract class CustomerTripsRepository {
  Future<Result<List<CustomerTripDetailModel>, NetworkException>>
  getCustomerTripsHistory(int customerId);

  Future<Result<CustomerTripByIdModel, NetworkException>> getCustomerTripById(
    int tripId,
  );
}
