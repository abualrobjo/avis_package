import 'package:avis_package/src/core/_core.dart';

class VehicleClassesPriceServiceImpl implements VehicleClassesPriceService {
  VehicleClassesPriceServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<List<VehicleClassPriceModel>>>
      getVehicleClassesPriceByTripType(
    VehicleClassesPriceRequest request,
  ) async {
    final result = await _client
        .post<ApiResponseModel<List<VehicleClassPriceModel>>>(
      endpoint: ApiEndpoints.getVehicleClassesPriceByTripType,
      body: request.toJson(),
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => (raw as List)
            .map((e) => VehicleClassPriceModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: [],
      ),
    );
  }
}
