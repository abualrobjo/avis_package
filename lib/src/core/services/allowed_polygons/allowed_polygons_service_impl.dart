import 'package:avis_package/src/core/_core.dart';

class AllowedPolygonsServiceImpl implements AllowedPolygonsService {
  AllowedPolygonsServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<List<AllowedPolygonPointModel>>>
      getAllowedPolygonsAreas() async {
    final result = await _client
        .get<ApiResponseModel<List<AllowedPolygonPointModel>>>(
      endpoint: ApiEndpoints.getAllowedPolygonsAreas,
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => (raw as List)
            .map((e) => AllowedPolygonPointModel.fromJson(
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

  @override
  Future<ApiResponseModel<List<AllowedPolygonPointModel>>>
      findAllowedAreasPolygonByPickupCordTripId({
    required double platitude,
    required double plongtitude,
    required int tripTypeId,
  }) async {
    final result = await _client
        .get<ApiResponseModel<List<AllowedPolygonPointModel>>>(
      endpoint: ApiEndpoints.findAllowedAreasPolygonByPickupCordTripId,
      queryParameters: {
        'Platitude': platitude,
        'Plongtitude': plongtitude,
        'TripTypeId': tripTypeId,
      },
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => (raw as List)
            .map((e) => AllowedPolygonPointModel.fromJson(
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

  @override
  Future<ApiResponseModel<CheckDropCoordinatesResultModel>>
      checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId({
    required double platitude,
    required double plongtitude,
    required int tripTypeId,
    required double dlatitude,
    required double dlongtitude,
  }) async {
    final result = await _client
        .get<ApiResponseModel<CheckDropCoordinatesResultModel>>(
      endpoint: ApiEndpoints.checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId,
      queryParameters: {
        'Platitude': platitude,
        'Plongtitude': plongtitude,
        'TripTypeId': tripTypeId,
        'Dlatitude': dlatitude,
        'Dlongtitude': dlongtitude,
      },
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => CheckDropCoordinatesResultModel.fromJson(
          Map<String, dynamic>.from(raw as Map),
        ),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: CheckDropCoordinatesResultModel(
          isSuccess: false,
          isAllowed: false,
        ),
      ),
    );
  }
}
