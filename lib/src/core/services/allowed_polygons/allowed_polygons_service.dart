import 'package:avis_package/src/core/_core.dart';

abstract class AllowedPolygonsService {
  Future<ApiResponseModel<List<AllowedPolygonPointModel>>> getAllowedPolygonsAreas();

  /// Allowed drop-off polygon areas for a given pickup and trip type.
  Future<ApiResponseModel<List<AllowedPolygonPointModel>>>
      findAllowedAreasPolygonByPickupCordTripId({
    required double platitude,
    required double plongtitude,
    required int tripTypeId,
  });

  /// Validates that the drop-off coordinates are allowed for the given pickup and trip type.
  Future<ApiResponseModel<CheckDropCoordinatesResultModel>>
      checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId({
    required double platitude,
    required double plongtitude,
    required int tripTypeId,
    required double dlatitude,
    required double dlongtitude,
  });
}
