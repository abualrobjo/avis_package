import 'package:avis_package/src/core/_core.dart';

abstract class VehicleClassesPriceService {
  Future<ApiResponseModel<List<VehicleClassPriceModel>>>
      getVehicleClassesPriceByTripType(
    VehicleClassesPriceRequest request,
  );
}
