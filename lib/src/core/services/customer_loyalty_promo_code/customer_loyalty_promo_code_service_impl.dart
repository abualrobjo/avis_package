import 'package:avis_package/src/core/_core.dart';

class CustomerLoyaltyPromoCodeServiceImpl
    implements CustomerLoyaltyPromoCodeService {
  CustomerLoyaltyPromoCodeServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<String>> generateCustomerLoyaltyPromoCode(
    GenerateCustomerLoyaltyPromoCodeRequest request,
  ) async {
    final result = await _client.post<ApiResponseModel<String>>(
      endpoint: ApiEndpoints.generateCustomerLoyaltyPromoCode,
      body: request.toJson(),
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => raw is String ? raw : (raw?.toString() ?? ''),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: '',
      ),
    );
  }
}
