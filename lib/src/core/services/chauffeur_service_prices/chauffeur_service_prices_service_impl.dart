import 'package:avis_package/src/core/_core.dart';

class ChauffeurServicePricesServiceImpl implements ChauffeurServicePricesService {
  ChauffeurServicePricesServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<ChauffeurServicePricesResponseDetails>>
      getChauffeurServicePricesByRequest(
    ChauffeurServicePricesByRequestBody body,
  ) async {
    final result = await _client
        .post<ApiResponseModel<ChauffeurServicePricesResponseDetails>>(
      endpoint: ApiEndpoints.getChauffeurServicePricesByRequest,
      body: body.toJson(),
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => raw == null
            ? const ChauffeurServicePricesResponseDetails(totalWithTax: 0)
            : ChauffeurServicePricesResponseDetails.fromJson(
                Map<String, dynamic>.from(raw as Map)),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: const ChauffeurServicePricesResponseDetails(totalWithTax: 0),
      ),
    );
  }
}
