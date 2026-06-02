import 'package:avis_package/src/core/_core.dart';

class PromoCodeServiceImpl implements PromoCodeService {
  PromoCodeServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<CheckPromoCodeValidityDetails>>
      checkPromoCodeValidity(
    CheckPromoCodeValidityRequest request,
  ) async {
    final result = await _client
        .post<ApiResponseModel<CheckPromoCodeValidityDetails>>(
      endpoint: ApiEndpoints.checkPromoCodeValidity,
      body: request.toJson(),
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => raw == null
            ? const CheckPromoCodeValidityDetails()
            : CheckPromoCodeValidityDetails.fromJson(
                Map<String, dynamic>.from(raw as Map)),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: const CheckPromoCodeValidityDetails(),
      ),
    );
  }
}
