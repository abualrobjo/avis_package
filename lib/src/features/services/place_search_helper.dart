import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';

import 'package:avis_package/src/core/_core.dart';

class PlaceSuggestion {
  const PlaceSuggestion({
    required this.description,
    this.placeId,
    this.resolvedLocation,
  });

  final String description;
  final String? placeId;
  final LatLng? resolvedLocation;
}

class PlaceSearchHelper {
  PlaceSearchHelper._();

  static bool isWithinAllowedArea(LatLng point, List<List<LatLng>>? polygons) {
    if (polygons == null || polygons.isEmpty) return true;
    for (final polygon in polygons) {
      if (_pointInPolygon(point, polygon)) return true;
    }
    return false;
  }

  static bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    final x = point.longitude;
    final y = point.latitude;
    var inside = false;
    var j = polygon.length - 1;
    for (var i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  static String formatPlacemark(Placemark placemark, LatLng fallbackPosition) {
    final street = (placemark.street?.isNotEmpty ?? false)
        ? placemark.street!
        : (placemark.thoroughfare?.isNotEmpty ?? false)
            ? placemark.thoroughfare!
            : null;
    final parts = <String>[
      ...([street].whereType<String>()),
      if (placemark.subLocality?.isNotEmpty ?? false) placemark.subLocality!,
      if (placemark.locality?.isNotEmpty ?? false) placemark.locality!,
      if (placemark.administrativeArea?.isNotEmpty ?? false)
        placemark.administrativeArea!,
      if (placemark.country?.isNotEmpty ?? false) placemark.country!,
    ];
    if (parts.isEmpty && (placemark.name?.isNotEmpty ?? false)) {
      parts.add(placemark.name!);
    }
    if (parts.isEmpty) {
      return '${fallbackPosition.latitude.toStringAsFixed(4)}, '
          '${fallbackPosition.longitude.toStringAsFixed(4)}';
    }
    return parts.join(', ');
  }

  static Future<List<PlaceSuggestion>> fetchSuggestions({
    required String rawQuery,
    required String languageCode,
  }) async {
    final query = rawQuery.trim();
    if (query.isEmpty) return [];

    final apiKey = resolveGoogleMapsApiKey();
    var next = <PlaceSuggestion>[];

    try {
      if (apiKey.isNotEmpty) {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final res = await dio.get<Map<String, dynamic>>(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json',
          queryParameters: {
            'input': query,
            'key': apiKey,
            'language': languageCode,
          },
        );
        final data = res.data;
        final status = data?['status'] as String?;
        if (status == 'OK' && data?['predictions'] is List) {
          for (final p in (data!['predictions'] as List).take(8)) {
            if (p is Map<String, dynamic>) {
              final desc = p['description'] as String?;
              final pid = p['place_id'] as String?;
              if (desc != null && pid != null) {
                next.add(PlaceSuggestion(description: desc, placeId: pid));
              }
            }
          }
        }
      }

      if (next.isEmpty) {
        final locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          final loc = locations.first;
          final latLng = LatLng(loc.latitude, loc.longitude);
          var desc = query;
          try {
            final pm = await placemarkFromCoordinates(
              latLng.latitude,
              latLng.longitude,
            );
            if (pm.isNotEmpty) {
              desc = formatPlacemark(pm.first, latLng);
            }
          } catch (_) {}
          next = [
            PlaceSuggestion(description: desc, resolvedLocation: latLng),
          ];
        }
      }
    } catch (_) {
      next = [];
    }

    return next;
  }

  static Future<LatLng?> latLngFromPlaceId(String placeId) async {
    final apiKey = resolveGoogleMapsApiKey();
    if (apiKey.isEmpty) return null;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final res = await dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry',
          'key': apiKey,
        },
      );
      final loc = res.data?['result']?['geometry']?['location'];
      if (loc is Map<String, dynamic>) {
        final lat = (loc['lat'] as num?)?.toDouble();
        final lng = (loc['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<LatLng?> geocodeQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;
    try {
      final locations = await locationFromAddress(trimmed);
      if (locations.isEmpty) return null;
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (_) {
      return null;
    }
  }

  static Future<LatLng?> resolveSuggestion(PlaceSuggestion suggestion) async {
    if (suggestion.resolvedLocation != null) {
      return suggestion.resolvedLocation;
    }
    if (suggestion.placeId != null) {
      final fromPlaceId = await latLngFromPlaceId(suggestion.placeId!);
      if (fromPlaceId != null) return fromPlaceId;
    }
    return geocodeQuery(suggestion.description);
  }
}
