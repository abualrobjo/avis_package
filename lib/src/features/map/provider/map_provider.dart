import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:avis_package/src/core/_core.dart';

enum MapState { initial, loading, loaded, error }

class MapProvider extends ChangeNotifier {
  MapProvider(this._customerTripsRepository);

  final CustomerTripsRepository _customerTripsRepository;

  // ─────────────────────────────────────────────────────────────
  // Trip data
  // ─────────────────────────────────────────────────────────────
  CustomerTripByIdModel? _tripInfo;
  CustomerTripByIdModel? get tripInfo => _tripInfo;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LatLng get startLocation {
    final parse = CustomerTripByIdModel.parseLatLng(_tripInfo?.pickupLatLng);
    return parse != null
        ? LatLng(parse.$1, parse.$2)
        : const LatLng(24.7136, 46.6753);
  }

  LatLng get destinationLocation {
    final parse = CustomerTripByIdModel.parseLatLng(_tripInfo?.dropOffLatLng);
    return parse != null
        ? LatLng(parse.$1, parse.$2)
        : const LatLng(24.7136, 46.6753);
  }

  // ─────────────────────────────────────────────────────────────
  // Map state
  // ─────────────────────────────────────────────────────────────
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;

  // ─────────────────────────────────────────────────────────────
  // Car state
  // ─────────────────────────────────────────────────────────────
  LatLng? _carLocation;
  LatLng get carLocation => _carLocation ?? startLocation;

  double _carHeading = 0.0; // true bearing (0–360)
  double _mapBearing = 0.0;

  // 🔴 FIX: The actual car_marker.png asset is drawn pointing Top-Left (-45°).
  // To make it point true North (0°), we MUST add positive 45°.
  static const double _assetRotationFix = 45.0;

  // ─────────────────────────────────────────────────────────────
  // Marker icons
  // ─────────────────────────────────────────────────────────────
  BitmapDescriptor? _startIcon;
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _carIcon;

  // ─────────────────────────────────────────────────────────────
  // Map state
  // ─────────────────────────────────────────────────────────────

  MapState _mapState = MapState.initial;
  MapState get mapState => _mapState;

  // ─────────────────────────────────────────────────────────────
  // ETA (current location → drop-off)
  // ─────────────────────────────────────────────────────────────
  bool _loadingEta = false;
  int? _etaDurationSeconds;
  int? _etaDistanceMeters;
  LatLng? _lastEtaOrigin;
  DateTime? _lastEtaFetchedAt;

  bool get loadingEta => _loadingEta;
  bool get hasValidDropOffCoordinates =>
      CustomerTripByIdModel.parseLatLng(_tripInfo?.dropOffLatLng) != null;

  String? get etaDurationLabel {
    final seconds = _etaDurationSeconds;
    if (seconds == null) return null;
    return _formatDuration(seconds);
  }

  String? get etaArrivalTimeLabel {
    final seconds = _etaDurationSeconds;
    if (seconds == null) return null;
    return DateFormat('h:mm a').format(
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }

  String? get etaSubtextLabel {
    final parts = <String>[];
    final distance = _etaDistanceMeters;
    if (distance != null) {
      parts.add(_formatDistance(distance));
    }
    final arrival = etaArrivalTimeLabel;
    if (arrival != null) {
      parts.add('Arrives $arrival');
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static String _formatDuration(int seconds) {
    final totalMinutes = (seconds / 60).ceil().clamp(1, 9999);
    if (totalMinutes < 60) return '$totalMinutes min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) return '$hours hr';
    return '$hours hr $minutes min';
  }

  static String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  // ══════════════════════════════════════════════════════════════
  // PUBLIC API
  // ══════════════════════════════════════════════════════════════

  Future<void> fetchTrip(int tripId, {bool startTracking = true}) async {
    _mapState = MapState.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _customerTripsRepository.getCustomerTripById(tripId);

    await response.when(
      success: (data) async {
        _tripInfo = data;
        _carLocation = startLocation;

        await _loadMarkerIcons();

        _buildMarkers();
        _mapState = MapState.loaded;
        notifyListeners();

        if (startTracking) {
          await _startTracking();
        }

        await fetchEtaToDropOff(force: true);
      },
      failure: (error) async {
        _errorMessage = error.message;
        _mapState = MapState.error;
        notifyListeners();
      },
    );
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // ══════════════════════════════════════════════════════════════
  // MARKER ICONS
  // ══════════════════════════════════════════════════════════════

  Future<void> _loadMarkerIcons() async {
    _startIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(36, 36)),
      'assets/images/start_position.png',
      package: AppConst.packageName,
    );

    _destinationIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(70, 70)),
      'assets/images/customer_position.png',
      package: AppConst.packageName,
    );

    _carIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/images/car_marker.png',
      package: AppConst.packageName,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MARKERS
  // ══════════════════════════════════════════════════════════════

  void _buildMarkers() {
    markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: startLocation,
        icon: _startIcon!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destinationLocation,
        icon: _destinationIcon!,
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('car'),
        position: carLocation,
        flat: true,
        // FIX: Remove (- _mapBearing)
        // With flat: true, rotation is anchored to Geographic North.
        // To point in the direction of travel, the marker simply needs to equal
        // the _carHeading (plus the asset compensation). The map camera rotating
        // does not change Geographic North, so subtracting mapBearing breaks it.
        rotation: (_carHeading + _assetRotationFix) % 360,
        icon: _carIcon!,
        anchor: const Offset(0.5, 0.5),
      ),
    };
  }

  // ══════════════════════════════════════════════════════════════
  // POLYLINE
  // ══════════════════════════════════════════════════════════════

  Future<void> fetchPolyline() async {
    final apiKey = resolveGoogleMapsApiKey();
    if (apiKey.isEmpty) return;

    final polylinePoints = PolylinePoints(apiKey: apiKey);

    final response = await polylinePoints.getRouteBetweenCoordinatesV2(
      request: RoutesApiRequest(
        origin: PointLatLng(startLocation.latitude, startLocation.longitude),
        destination: PointLatLng(
          destinationLocation.latitude,
          destinationLocation.longitude,
        ),
        travelMode: TravelMode.driving,
      ),
    );

    final result = polylinePoints.convertToLegacyResult(response);

    polylineCoordinates = result.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.black,
        width: 5,
        points: polylineCoordinates,
      ),
    };
    notifyListeners();
  }

  /// Estimated driving time from the user's current location to drop-off.
  Future<void> fetchEtaToDropOff({bool force = false}) async {
    if (!hasValidDropOffCoordinates) {
      _etaDurationSeconds = null;
      _etaDistanceMeters = null;
      notifyListeners();
      return;
    }

    final apiKey = resolveGoogleMapsApiKey();
    if (apiKey.isEmpty) return;

    LatLng? origin = _carLocation;
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        origin = LatLng(position.latitude, position.longitude);
      }
    } catch (_) {}

    origin ??= _carLocation;
    if (origin == null) return;

    if (!force && _lastEtaOrigin != null && _lastEtaFetchedAt != null) {
      final moved = Geolocator.distanceBetween(
        _lastEtaOrigin!.latitude,
        _lastEtaOrigin!.longitude,
        origin.latitude,
        origin.longitude,
      );
      final elapsed = DateTime.now().difference(_lastEtaFetchedAt!);
      if (moved < 100 && elapsed.inSeconds < 45) return;
    }

    _loadingEta = true;
    notifyListeners();

    try {
      final polylinePoints = PolylinePoints(apiKey: apiKey);
      final response = await polylinePoints.getRouteBetweenCoordinatesV2(
        request: RoutesApiRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(
            destinationLocation.latitude,
            destinationLocation.longitude,
          ),
          travelMode: TravelMode.driving,
        ),
      );

      final route = response.primaryRoute;
      _etaDurationSeconds = route?.duration ?? route?.staticDuration;
      _etaDistanceMeters = route?.distanceMeters;
      _lastEtaOrigin = origin;
      _lastEtaFetchedAt = DateTime.now();
    } catch (_) {
      _etaDurationSeconds = null;
      _etaDistanceMeters = null;
    } finally {
      _loadingEta = false;
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GPS TRACKING
  // ══════════════════════════════════════════════════════════════

  Future<void> _startTracking() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      ),
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    final newLocation = LatLng(position.latitude, position.longitude);
    final prevLocation = _carLocation;

    if (prevLocation != null) {
      final distance = Geolocator.distanceBetween(
        prevLocation.latitude,
        prevLocation.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      if (distance > 2) {
        final bearing = Geolocator.bearingBetween(
          prevLocation.latitude,
          prevLocation.longitude,
          newLocation.latitude,
          newLocation.longitude,
        );

        _carHeading = (bearing + 360) % 360;
        _mapBearing = _carHeading;
      }
    }

    _carLocation = newLocation;

    _buildMarkers();
    unawaited(fetchEtaToDropOff());

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newLocation,
          zoom: 16.5,
          bearing: _mapBearing,
          tilt: 0,
        ),
      ),
    );

    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // MAP STYLE
  // ══════════════════════════════════════════════════════════════
  String? _mapStyle;
  String? get mapStyle => _mapStyle;

  Future<void> updateMapStyle({required bool isDark}) async {
    if (isDark) {
      try {
        final style = await rootBundle.loadString(
          'packages/${AppConst.packageName}/assets/map_styles/dark_mode.json',
        );

        _mapStyle = style;
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to load map style: $e');
        _mapStyle = null;
      }
    } else {
      _mapStyle = null;
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
