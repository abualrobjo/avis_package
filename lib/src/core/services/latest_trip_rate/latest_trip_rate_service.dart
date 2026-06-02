import 'package:avis_package/src/core/_core.dart';

abstract class LatestTripRateService {
  Future<ApiResponseModel<LatestTripRateModel>> checkLatestTripRate(
    int customerId,
  );
}
