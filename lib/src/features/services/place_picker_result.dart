import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Result returned when user selects a location on the map place picker.
class PlacePickerResult {
  const PlacePickerResult({
    required this.address,
    required this.latLng,
  });

  final String address;
  final LatLng latLng;
}
