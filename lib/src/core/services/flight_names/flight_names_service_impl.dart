import 'package:avis_package/src/core/_core.dart';

class FlightNamesServiceImpl implements FlightNamesService {
  FlightNamesServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<List<FlightNameModel>>> getFlightNames(
    String language,
  ) async {
    final result = await _client.get<ApiResponseModel<List<FlightNameModel>>>(
      endpoint: ApiEndpoints.getFlightNames,
      queryParameters: {'language': language},
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => (raw as List)
            .map((e) => FlightNameModel.fromJson(
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
