import 'package:google_maps_flutter/google_maps_flutter.dart';

/// One polygon vertex from GetAllowedPolygonsAreas API. Points with same [zoneId] form one polygon.
class AllowedPolygonPointModel {
  final int id;
  final double lat;
  final double lng;
  final String? primaryName;
  final String? secondaryName;
  final int? cityId;
  final int zoneId;

  const AllowedPolygonPointModel({
    required this.id,
    required this.lat,
    required this.lng,
    this.primaryName,
    this.secondaryName,
    this.cityId,
    required this.zoneId,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory AllowedPolygonPointModel.fromJson(Map<String, dynamic> json) {
    return AllowedPolygonPointModel(
      id: (json['id'] as num).toInt(),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      primaryName: json['primaryName'] as String?,
      secondaryName: json['secondaryName'] as String?,
      cityId: (json['cityId'] as num?)?.toInt(),
      zoneId: (json['zoneId'] as num).toInt(),
    );
  }

  /// Groups points by [zoneId] and returns polygons as list of [LatLng] per zone (order preserved).
  static List<List<LatLng>> toPolygons(List<AllowedPolygonPointModel> points) {
    final byZone = <int, List<AllowedPolygonPointModel>>{};
    for (final p in points) {
      byZone.putIfAbsent(p.zoneId, () => []).add(p);
    }
    return byZone.values
        .map((list) => list..sort((a, b) => a.id.compareTo(b.id)))
        .map((list) => list.map((p) => p.latLng).toList())
        .toList();
  }
}
