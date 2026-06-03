import 'package:avis_package/src/core/_core.dart';

class CustomerFavoriteDriversServiceImpl implements CustomerFavoriteDriversService {
  CustomerFavoriteDriversServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<bool>> addFavoriteDriver(
    CustomerFavoriteDriversParams params,
  ) async {
    final result = await _client.post<ApiResponseModel<bool>>(
      endpoint: ApiEndpoints.customerFavoriteDrivers,
      body: params.toJson(),
      parser: (json) => ApiResponseModel.fromJson(
        json as Map<String, dynamic>,
        (Object? raw) {
          if (raw == null) return true;
          if (raw is bool) return raw;
          return true;
        },
      ),
    );

    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel<bool>(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: false,
      ),
    );
  }
}
