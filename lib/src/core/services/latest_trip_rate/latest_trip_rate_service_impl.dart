import 'package:avis_package/src/core/_core.dart';

class LatestTripRateServiceImpl implements LatestTripRateService {
  LatestTripRateServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<LatestTripRateModel>> checkLatestTripRate(
    int customerId,
  ) async {
    final result =
        await _client.get<ApiResponseModel<LatestTripRateModel>>(
      endpoint: ApiEndpoints.checkLatestTripRate,
      queryParameters: {'CustomerId': customerId},
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => raw == null
            ? LatestTripRateModel.empty
            : LatestTripRateModel.fromJson(
                Map<String, dynamic>.from(raw as Map)),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: LatestTripRateModel.empty,
      ),
    );
  }
}
