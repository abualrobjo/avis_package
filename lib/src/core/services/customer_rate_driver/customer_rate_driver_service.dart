import 'package:avis_package/src/core/_core.dart';

abstract class CustomerRateDriverService {
  Future<ApiResponseModel<bool>> rateDriver(CustomerRateDriverParams params);
}
