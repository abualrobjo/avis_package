import 'package:avis_package/src/core/_core.dart';

class CustomerInfoServiceImpl implements CustomerInfoService {
  CustomerInfoServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<CustomerInfoModel>> getCustomerInfo(
    int customerId,
  ) async {
    final result = await _client.get<ApiResponseModel<CustomerInfoModel>>(
      endpoint: ApiEndpoints.getCustomerInfo,
      queryParameters: {'CustomerId': customerId},
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => raw == null
            ? CustomerInfoModel.empty
            : CustomerInfoModel.fromJson(
                Map<String, dynamic>.from(raw as Map)),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: CustomerInfoModel.empty,
      ),
    );
  }
}
