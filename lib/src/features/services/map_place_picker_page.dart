import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:avis_package/src/core/_core.dart';

import 'place_picker_result.dart';
import 'place_search_helper.dart';

class _PlaceSuggestion {
  const _PlaceSuggestion({
    required this.description,
    this.placeId,
    this.resolvedLocation,
  });

  final String description;
  final String? placeId;
  final LatLng? resolvedLocation;
}

/// Full-screen map. User moves the map under a fixed center pin to choose a location.
/// If [allowedPolygons] is set, user can only select a location inside one of these polygons.
class MapPlacePickerPage extends StatefulWidget {
  const MapPlacePickerPage({
    super.key,
    required this.title,
    this.initialPosition,
    this.allowedPolygons,
  });

  final String title;
  final LatLng? initialPosition;
  /// When non-null, selection is restricted to points inside these polygons.
  final List<List<LatLng>>? allowedPolygons;

  static const LatLng _defaultPosition = LatLng(40.6413, -73.7781); // JFK area

  @override
  State<MapPlacePickerPage> createState() => _MapPlacePickerPageState();
}

class _MapPlacePickerPageState extends State<MapPlacePickerPage> {
  GoogleMapController? _controller;
  LatLng? _selectedPosition;
  LatLng? _currentLocation;
  BitmapDescriptor? _currentLocationMarkerIcon;
  bool _isLoading = false;
  String? _error;
  bool _locationGranted = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _suggestionsDebounce;
  final List<_PlaceSuggestion> _searchSuggestions = [];
  bool _isLoadingSuggestions = false;

  LatLng get _initialCamera =>
      _currentLocation ??
      widget.initialPosition ??
      MapPlacePickerPage._defaultPosition;

  Set<Polygon> get _allowedPolygonsSet {
    final list = widget.allowedPolygons;
    if (list == null || list.isEmpty) return {};
    return {
      for (int i = 0; i < list.length; i++)
        Polygon(
          polygonId: PolygonId('zone_$i'),
          points: list[i],
          strokeWidth: 2,
          strokeColor:Colors.transparent,
          fillColor: Colors.transparent,
        ),
    };
  }

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? MapPlacePickerPage._defaultPosition;
    _searchFocusNode.addListener(_onSearchFocusChange);
    unawaited(_loadCurrentLocationMarkerIcon());
    unawaited(_requestLocationPermission());
  }

  Future<void> _loadCurrentLocationMarkerIcon() async {
    try {
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/customer_position.png',
        package: AppConst.packageName,
      );
      if (mounted) setState(() => _currentLocationMarkerIcon = icon);
    } catch (_) {}
  }

  Set<Marker> get _mapMarkers {
    final markers = <Marker>{};
    if (_currentLocation != null && _currentLocationMarkerIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: _currentLocationMarkerIcon!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 1,
        ),
      );
    }
    return markers;
  }

  void _onCameraMove(CameraPosition position) {
    _selectedPosition = position.target;
  }

  void _onCameraIdle() {
    final position = _selectedPosition;
    if (position == null) return;

    if (widget.allowedPolygons != null &&
        widget.allowedPolygons!.isNotEmpty &&
        !_isWithinAllowedArea(position)) {
      setState(() {
        _error = 'Please select a location within the service area';
      });
      return;
    }

    if (_error != null) {
      setState(() => _error = null);
    }
  }

  Future<void> _loadCurrentLocation({bool focusCamera = true}) async {
    if (!_locationGranted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (focusCamera) await _focusOnCurrentLocation();
    } catch (_) {}
  }

  Future<void> _focusOnCurrentLocation() async {
    final location = _currentLocation;
    final controller = _controller;
    if (location == null || controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 16),
      ),
    );
  }

  Future<void> _onCurrentLocationPressed() async {
    if (!_locationGranted) {
      await _requestLocationPermission();
    }
    if (!_locationGranted) return;
    await _loadCurrentLocation();
  }

  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_searchFocusNode.hasFocus) {
          setState(() {
            _searchSuggestions.clear();
            _isLoadingSuggestions = false;
          });
        }
      });
    }
  }

  void _onSearchTextChanged(String value) {
    _suggestionsDebounce?.cancel();
    _suggestionsDebounce = Timer(const Duration(milliseconds: 350), () {
      _fetchSearchSuggestions(value);
    });
  }

  Future<void> _requestLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) setState(() => _locationGranted = false);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final granted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (mounted) {
      setState(() => _locationGranted = granted);
    }
    if (granted) {
      await _loadCurrentLocation();
    }
  }

  bool _isWithinAllowedArea(LatLng point) {
    final polygons = widget.allowedPolygons;
    if (polygons == null || polygons.isEmpty) return true;
    for (final polygon in polygons) {
      if (_pointInPolygon(point, polygon)) return true;
    }
    return false;
  }

  /// Ray-casting: point is inside polygon if ray from point crosses edges odd times.
  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    final x = point.longitude;
    final y = point.latitude;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude, yi = polygon[i].latitude;
      final xj = polygon[j].longitude, yj = polygon[j].latitude;
      if (((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  Future<void> _fetchSearchSuggestions(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _searchSuggestions.clear();
          _isLoadingSuggestions = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isLoadingSuggestions = true);

    final locale = Localizations.localeOf(context);
    var next = <_PlaceSuggestion>[];

    try {
      final suggestions = await PlaceSearchHelper.fetchSuggestions(
        rawQuery: query,
        languageCode: locale.languageCode,
      );
      next = suggestions
          .map(
            (s) => _PlaceSuggestion(
              description: s.description,
              placeId: s.placeId,
              resolvedLocation: s.resolvedLocation,
            ),
          )
          .toList();
    } catch (_) {
      next = [];
    }

    if (!mounted || _searchController.text.trim() != query) return;
    setState(() {
      _searchSuggestions
        ..clear()
        ..addAll(next);
      _isLoadingSuggestions = false;
    });
  }

  Future<void> _moveMapToLatLng(LatLng latLng) async {
    if (widget.allowedPolygons != null &&
        widget.allowedPolygons!.isNotEmpty &&
        !_isWithinAllowedArea(latLng)) {
      setState(() {
        _error = 'This address is outside the service area';
      });
      return;
    }

    setState(() => _error = null);

    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 16),
    );
  }

  Future<void> _onSuggestionTap(_PlaceSuggestion suggestion) async {
    _searchFocusNode.unfocus();
    setState(() {
      _searchSuggestions.clear();
      _isLoadingSuggestions = false;
      _searchController.text = suggestion.description;
      _searchController.selection = TextSelection.collapsed(
        offset: suggestion.description.length,
      );
    });

    LatLng? latLng = suggestion.resolvedLocation;

    if (latLng == null && suggestion.placeId != null) {
      setState(() {
        _error = null;
        _isSearching = true;
      });
      latLng = await PlaceSearchHelper.latLngFromPlaceId(suggestion.placeId!);
      if (!mounted) return;
      setState(() => _isSearching = false);
    }

    if (latLng == null) {
      await _onSearchSubmitted(suggestion.description);
      return;
    }

    await _moveMapToLatLng(latLng);
  }

  Future<void> _onSearchSubmitted(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _error = null;
      _isSearching = true;
    });

    try {
      final locale = Localizations.localeOf(context);
      final latLng = await PlaceSearchHelper.geocodeQuery(
        trimmed,
        languageCode: locale.languageCode,
      );
      if (!mounted) return;
      if (latLng == null) {
        setState(() {
          _isSearching = false;
          _error = 'No results found';
        });
        return;
      }

      setState(() => _isSearching = false);
      await _moveMapToLatLng(latLng);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _error = 'Search failed';
      });
    }
  }

  Future<void> _confirmSelectedLocation() async {
    if (_selectedPosition == null) return;

    if (widget.allowedPolygons != null &&
        widget.allowedPolygons!.isNotEmpty &&
        !_isWithinAllowedArea(_selectedPosition!)) {
      setState(() {
        _error = 'Please select a location within the service area';
      });
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedPosition!.latitude,
        _selectedPosition!.longitude,
      );

      if (!mounted) return;
      if (placemarks.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Could not get address';
        });
        return;
      }

      final place = placemarks.first;
      final address = PlaceSearchHelper.formatPlacemark(place, _selectedPosition!);
      final shortAddress =
          PlaceSearchHelper.formatShortPlacemark(place, _selectedPosition!);

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.of(context).pop(
          PlacePickerResult(
            address: address,
            shortAddress: shortAddress,
            latLng: _selectedPosition!,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to get address';
      });
    }
  }

  @override
  void dispose() {
    _suggestionsDebounce?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(widget.title, style: AppTextStyles.bodyLargeBold),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.primaryText,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCamera,
              zoom: 16,
            ),
            onMapCreated: (c) async {
              _controller = c;
              if (_currentLocation != null) {
                await _focusOnCurrentLocation();
              } else if (_locationGranted) {
                await _loadCurrentLocation();
              }
              if (mounted) {
                setState(() => _selectedPosition = _initialCamera);
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: _locationGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            polygons: _allowedPolygonsSet,
            markers: _mapMarkers,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_on,
                size: 48,
                color: context.colors.primary,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 96,
            child: SafeArea(
              child: Material(
                elevation: 2,
                shape: const CircleBorder(),
                color: context.colors.surface,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _onCurrentLocationPressed,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.my_location,
                      size: 22,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  color: context.colors.surface,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchTextChanged,
                    onSubmitted: _onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search for a place or address',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.secondaryText,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.colors.secondaryText,
                        size: 24,
                      ),
                      suffixIcon: _isSearching
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colors.primary,
                                ),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.colors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ),
                if (_searchFocusNode.hasFocus &&
                    (_isLoadingSuggestions || _searchSuggestions.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      color: context.colors.surface,
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: _isLoadingSuggestions && _searchSuggestions.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _searchSuggestions.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: context.colors.border,
                                ),
                                itemBuilder: (context, index) {
                                  final s = _searchSuggestions[index];
                                  return ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    leading: Icon(
                                      Icons.place_outlined,
                                      color: context.colors.secondaryText,
                                      size: 22,
                                    ),
                                    title: TextWidget(
                                      s.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: context.colors.primaryText,
                                      ),
                                    ),
                                    onTap: () => _onSuggestionTap(s),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: AppButton.primary(
                onPressed: _isLoading ? null : _confirmSelectedLocation,
                text: 'Use this location',
                height: 48,
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        TextWidget(
                          'Getting address...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.colors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Material(
                color: context.colors.errorBackground,
                borderRadius: BorderRadius.circular(AppCornerRadius.medium),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextWidget(
                    _error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
