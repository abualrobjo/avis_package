import 'package:avis_package/avis_package.dart';

class TermsAndConditionsServiceImpl implements TermsAndConditionsService {
  TermsAndConditionsServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<List<TermsAndConditionsModel>>>
      getTermsAndConditions() async {
    final result = await _client
        .get<ApiResponseModel<List<TermsAndConditionsModel>>>(
      endpoint: ApiEndpoints.termsAndConditionsGetAll,
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) {
          if (raw == null) return <TermsAndConditionsModel>[];
          if (raw is Map) {
            return [
              TermsAndConditionsModel.fromJson(
                Map<String, dynamic>.from(raw),
              ),
            ];
          }
          return (raw as List)
              .map(
                (e) => TermsAndConditionsModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        },
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
