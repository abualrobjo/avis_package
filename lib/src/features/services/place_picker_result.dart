import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'place_search_helper.dart';

/// Result returned when user selects a location on the map place picker.
class PlacePickerResult {
  const PlacePickerResult({
    required this.address,
    required this.latLng,
    this.shortAddress = '',
  });

  final String address;
  final String shortAddress;
  final LatLng latLng;

  String get placeName {
    final short = shortAddress.trim();
    final raw = short.isNotEmpty ? short : address;
    return PlaceSearchHelper.cleanAddressLabel(raw);
  }
}
