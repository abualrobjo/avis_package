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

  static final RegExp _plusCodePattern = RegExp(
    r'^[23456789CFGHJMPQRVWX]{4,8}[\s\-+]+\s*[23456789CFGHJMPQRVWX]{2,3}$',
    caseSensitive: false,
  );
  static final RegExp _plusCodePrefixPattern = RegExp(
    r'^[23456789CFGHJMPQRVWX]{4,8}[\s\-+]+\s*[23456789CFGHJMPQRVWX]{2,3}\s*',
    caseSensitive: false,
  );
  static final RegExp _commaSplitter = RegExp(r'[,،]');

  /// Google Plus Codes (e.g. W2MV+8XR or w2mv - 8xr) are not user-friendly labels.
  static bool isPlusCode(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (_plusCodePattern.hasMatch(trimmed)) return true;
    final beforeComma = trimmed.split(_commaSplitter).first.trim();
    return _plusCodePattern.hasMatch(beforeComma);
  }

  /// Removes plus-code prefixes/segments from a combined address label.
  static String cleanAddressLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final withoutPrefix = trimmed
        .replaceFirst(_plusCodePrefixPattern, '')
        .replaceFirst(RegExp(r'^[,،]\s*'), '')
        .trim();

    final source = withoutPrefix.isNotEmpty ? withoutPrefix : trimmed;
    final parts = source
        .split(_commaSplitter)
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty && !isPlusCode(part))
        .toList();

    if (parts.isNotEmpty) return parts.join(', ');
    return withoutPrefix.isNotEmpty && !isPlusCode(withoutPrefix)
        ? withoutPrefix
        : trimmed;
  }

  static String? meaningfulAddressPart(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || isPlusCode(trimmed)) return null;
    final cleaned = cleanAddressLabel(trimmed);
    if (cleaned.isEmpty || isPlusCode(cleaned)) return null;
    return cleaned;
  }

  static List<String> _addressParts(List<String?> candidates) {
    return candidates.map(meaningfulAddressPart).whereType<String>().toList();
  }

  static String formatPlacemark(Placemark placemark, LatLng fallbackPosition) {
    final street = meaningfulAddressPart(
      (placemark.street?.isNotEmpty ?? false)
          ? placemark.street
          : placemark.thoroughfare,
    );
    final parts = _addressParts([
      street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ]);
    if (parts.isEmpty) {
      final name = meaningfulAddressPart(placemark.name);
      if (name != null) parts.add(name);
    }
    if (parts.isEmpty) {
      return '${fallbackPosition.latitude.toStringAsFixed(4)}, '
          '${fallbackPosition.longitude.toStringAsFixed(4)}';
    }
    return parts.join(', ');
  }

  /// Street name only for map pin confirmation.
  static String formatStreetPlacemark(
    Placemark placemark,
    LatLng fallbackPosition,
  ) {
    final street = meaningfulAddressPart(
      (placemark.street?.isNotEmpty ?? false)
          ? placemark.street
          : placemark.thoroughfare,
    );
    if (street != null) return street;

    final fallbacks = _addressParts([
      placemark.subLocality,
      placemark.locality,
      placemark.name,
    ]);
    if (fallbacks.isNotEmpty) return fallbacks.first;

    return '${fallbackPosition.latitude.toStringAsFixed(4)}, '
        '${fallbackPosition.longitude.toStringAsFixed(4)}';
  }

  /// Shorter label for UI: place name or street + area (no country/state).
  static String formatShortPlacemark(
    Placemark placemark,
    LatLng fallbackPosition,
  ) {
    final name = meaningfulAddressPart(placemark.name);
    final street = meaningfulAddressPart(
      (placemark.street?.isNotEmpty ?? false)
          ? placemark.street
          : placemark.thoroughfare,
    );

    if (name != null && name != street) {
      return name;
    }

    final parts = _addressParts([
      street,
      placemark.subLocality,
      placemark.locality,
    ]);
    if (parts.isNotEmpty) return parts.join(', ');
    return formatPlacemark(placemark, fallbackPosition);
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
            'components': kGooglePlacesCountryComponents,
            'region': kGooglePlacesRegionCode,
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
        final latLng = await _geocodeInEgypt(
          query: query,
          apiKey: apiKey,
          languageCode: languageCode,
        );
        if (latLng != null) {
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

  static Future<String?> formattedAddressFromPlaceId(String placeId) async {
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
          'fields': 'formatted_address',
          'key': apiKey,
        },
      );
      final formatted = res.data?['result']?['formatted_address'] as String?;
      if (formatted != null && formatted.trim().isNotEmpty) {
        return formatted.trim();
      }
    } catch (_) {}
    return null;
  }

  static Future<LatLng?> geocodeQuery(
    String query, {
    String languageCode = 'en',
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;
    return _geocodeInEgypt(
      query: trimmed,
      apiKey: resolveGoogleMapsApiKey(),
      languageCode: languageCode,
    );
  }

  static Future<LatLng?> _geocodeInEgypt({
    required String query,
    required String apiKey,
    required String languageCode,
  }) async {
    if (apiKey.isNotEmpty) {
      try {
        final dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        final res = await dio.get<Map<String, dynamic>>(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'address': query,
            'key': apiKey,
            'language': languageCode,
            'components': kGooglePlacesCountryComponents,
            'region': kGooglePlacesRegionCode,
          },
        );
        final results = res.data?['results'];
        if (results is List && results.isNotEmpty) {
          final loc = (results.first as Map<String, dynamic>?)?['geometry']
              ?['location'];
          if (loc is Map<String, dynamic>) {
            final lat = (loc['lat'] as num?)?.toDouble();
            final lng = (loc['lng'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              return LatLng(lat, lng);
            }
          }
        }
      } catch (_) {}
    }

    try {
      final locations = await locationFromAddress('$query, Egypt');
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
