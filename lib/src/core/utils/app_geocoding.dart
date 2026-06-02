import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class AppGeocoding {
  AppGeocoding._();

  static Future<String> getPlaceName(gmaps.LatLng location) async {
    try {
      final places = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (places.isNotEmpty) {
        final p = places.first;
        final name = p.name ?? '';
        final street = p.street ?? '';
        final locality = p.locality ?? '';

        List<String> parts = [];
        if (name.isNotEmpty) parts.add(name);
        if (street.isNotEmpty && street != name) parts.add(street);
        if (locality.isNotEmpty) parts.add(locality);

        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return 'Unknown Location';
  }

  static Future<Map<String, String>> getBilingualPlaceName(
    gmaps.LatLng location,
  ) async {
    final name = await getPlaceName(location);
    return {'en': name, 'ar': name};
  }

  static Future<gmaps.LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return gmaps.LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
    } catch (e) {
      debugPrint('Forward geocoding error: $e');
    }
    return null;
  }
}
