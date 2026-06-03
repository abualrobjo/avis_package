import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        AppButton,
        AppContextExtension,
        AppTextStyles,
        TextWidget,
        AppRoutes,
        AvisNavigation,
        BackArrowWidget;
import 'package:avis_package/src/core/utils/app_geocoding.dart';
import '../provider/saved_locations_provider.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _centerPosition;
  String? _mapStyle;

  String _currentAddress = 'Fetching location...';
  double? _distanceInKm;
  LatLng? _deviceLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark && _mapStyle == null) {
      _loadMapStyle();
    } else if (!isDark && _mapStyle != null) {
      _mapStyle = null; // Reset for light mode
    }

    if (_centerPosition == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null &&
          args['latitude'] != null &&
          args['longitude'] != null) {
        // Editing an existing place or selected from suggestions
        setState(() {
          _centerPosition = LatLng(args['latitude'], args['longitude']);
        });
        _fetchDeviceLocationInBackground();
      } else {
        // New place - fetch current device location
        _determinePosition();
      }
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      final style = await rootBundle.loadString(
        'packages/avis_package/assets/map_styles/dark_mode.json',
      );
      if (mounted) {
        setState(() {
          _mapStyle = style;
        });
      }
    } catch (e) {
      debugPrint('Failed to load map style: $e');
    }
  }

  Future<void> _fetchDeviceLocationInBackground() async {
    try {
      if (await Geolocator.isLocationServiceEnabled() &&
              await Geolocator.checkPermission() ==
                  LocationPermission.whileInUse ||
          await Geolocator.checkPermission() == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        _deviceLocation = LatLng(pos.latitude, pos.longitude);
        _updateAddressAndDistance();
      }
    } catch (_) {}
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setDefaultPosition();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultPosition();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultPosition();
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _deviceLocation = LatLng(pos.latitude, pos.longitude);
        _centerPosition = _deviceLocation;
      });
      _updateAddressAndDistance();
    }
  }

  void _setDefaultPosition() {
    if (mounted) {
      setState(() {
        _centerPosition = const LatLng(31.2001, 29.9187); // Alexandria fallback
      });
      _updateAddressAndDistance();
    }
  }

  Future<void> _updateAddressAndDistance() async {
    if (_centerPosition == null || !mounted) return;

    final pos = _centerPosition!;
    final address = await AppGeocoding.getPlaceName(pos);

    double? distance;
    if (_deviceLocation != null) {
      final meters = Geolocator.distanceBetween(
        _deviceLocation!.latitude,
        _deviceLocation!.longitude,
        pos.latitude,
        pos.longitude,
      );
      distance = meters / 1000.0;
    }

    if (mounted && _centerPosition == pos) {
      setState(() {
        _currentAddress = address;
        _distanceInKm = distance;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (await Geolocator.isLocationServiceEnabled() &&
        (await Geolocator.checkPermission() == LocationPermission.whileInUse ||
            await Geolocator.checkPermission() == LocationPermission.always)) {
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _deviceLocation = latLng;
        });
        if (_mapController.isCompleted) {
          final controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newLatLng(latLng));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_centerPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          GoogleMap(
            style: _mapStyle,
            initialCameraPosition: CameraPosition(
              target: _centerPosition!,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            onCameraMove: (CameraPosition position) {
              _centerPosition = position.target;
            },
            onCameraIdle: () {
              _updateAddressAndDistance();
            },
          ),

          // Custom Back Button Bubble
          Positioned(top: 63.h, left: 20.w, child: const BackArrowWidget()),

          // Center Marker Pointer
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 40.h,
              ), // Offset by half the marker height so tip is exactly center
              child: Icon(
                Icons.location_on,
                size: 48.w,
                color: context.colors.primary,
              ),
            ),
          ),

          // Info Card & Done Button
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Location Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.my_location,
                          color: context.colors.primaryText,
                        ),
                        onPressed: _goToCurrentLocation,
                      ),
                    ),
                  ),

                  // Info Card
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: context.colors.primary,
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                'Selected Location',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: context.colors.secondaryText,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              TextWidget(
                                _currentAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.primaryText,
                                ),
                              ),
                              if (_distanceInKm != null &&
                                  _distanceInKm! > 0) ...[
                                SizedBox(height: 4.h),
                                TextWidget(
                                  '${_distanceInKm!.toStringAsFixed(1)} km away',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  AppButton.primary(
                    text: 'Done',
                    onPressed: () {
                      final args =
                          ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>?;
                      final type = args?['type'] as String? ?? 'custom';
                      AvisNavigation.push(
                        context,
                        AppRoutes.saveDetails,
                        arguments: {
                          'latitude': _centerPosition!.latitude,
                          'longitude': _centerPosition!.longitude,
                          'address': _currentAddress,
                          'type': type,
                          'provider': context.read<SavedLocationsProvider>(),
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
