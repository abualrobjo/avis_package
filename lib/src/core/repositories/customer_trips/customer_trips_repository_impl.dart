import 'package:avis_package/src/core/_core.dart';

class CustomerTripsRepositoryImpl implements CustomerTripsRepository {
  final CustomerTripsService _customerTripsService;
  const CustomerTripsRepositoryImpl(this._customerTripsService);

  @override
  Future<Result<List<CustomerTripDetailModel>, NetworkException>>
  getCustomerTripsHistory(int customerId) async =>
      await _customerTripsService.getCustomerTripsHistory(customerId);

  @override
  Future<Result<CustomerTripByIdModel, NetworkException>> getCustomerTripById(
    int tripId,
  ) async => await _customerTripsService.getCustomerTripById(tripId);
}
