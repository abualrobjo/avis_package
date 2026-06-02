import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/services/place_search_helper.dart';
import 'package:avis_package/src/features/services/widgets/place_search_field_widget.dart';

typedef PlaceSelectionHandler = Future<void> Function({
  required String name,
  required LatLng latLng,
  required bool fromAirportList,
});

/// Bottom sheet: search (same as map picker) + saved places + airports + map option.
class PlaceSelectionSheet extends StatefulWidget {
  const PlaceSelectionSheet({
    super.key,
    required this.title,
    required this.savedPlaces,
    required this.airports,
    required this.showAirports,
    required this.onPlaceSelected,
    required this.onChooseFromMap,
    this.allowedPolygons,
    this.validateLocation,
    this.localizeAirportName,
  });

  final String title;
  final List<CustomerSavedPlaceModel> savedPlaces;
  final List<AirportModel> airports;
  final bool showAirports;
  final PlaceSelectionHandler onPlaceSelected;
  final VoidCallback onChooseFromMap;
  final List<List<LatLng>>? allowedPolygons;
  final Future<bool> Function(LatLng latLng)? validateLocation;
  final String Function(AirportModel airport)? localizeAirportName;

  @override
  State<PlaceSelectionSheet> createState() => _PlaceSelectionSheetState();
}

class _PlaceSelectionSheetState extends State<PlaceSelectionSheet> {
  String? _errorMessage;

  Future<void> _handleSearchSuggestion(PlaceSuggestion suggestion) async {
    setState(() => _errorMessage = null);

    final latLng = await PlaceSearchHelper.resolveSuggestion(suggestion);
    if (!mounted) return;
    if (latLng == null) {
      setState(() => _errorMessage = 'Could not find this location');
      return;
    }

    if (!PlaceSearchHelper.isWithinAllowedArea(
      latLng,
      widget.allowedPolygons,
    )) {
      setState(
        () => _errorMessage = 'This address is outside the service area',
      );
      return;
    }

    if (widget.validateLocation != null) {
      final allowed = await widget.validateLocation!(latLng);
      if (!mounted) return;
      if (!allowed) return;
    }

    await widget.onPlaceSelected(
      name: suggestion.description,
      latLng: latLng,
      fromAirportList: false,
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleSavedPlace({
    required String name,
    required LatLng? coord,
    required bool fromAirportList,
  }) async {
    if (coord == null) {
      setState(() => _errorMessage = 'Location coordinates are unavailable');
      return;
    }

    setState(() => _errorMessage = null);

    if (!PlaceSearchHelper.isWithinAllowedArea(
      coord,
      widget.allowedPolygons,
    )) {
      setState(
        () => _errorMessage = 'This address is outside the service area',
      );
      return;
    }

    if (widget.validateLocation != null) {
      final allowed = await widget.validateLocation!(coord);
      if (!mounted) return;
      if (!allowed) return;
    }

    await widget.onPlaceSelected(
      name: name,
      latLng: coord,
      fromAirportList: fromAirportList,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: TextWidget(
                widget.title,
                style: AppTextStyles.bodyLargeBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: PlaceSearchFieldWidget(
                hintText: 'Search for a place or address',
                onSuggestionSelected: _handleSearchSuggestion,
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.errorBackground,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18.r,
                        color: context.colors.error,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextWidget(
                          _errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Divider(height: 1, color: context.colors.border),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 16.h),
                children: [
                  ListTile(
                    leading: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: context.colors.infoBackground,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.map_outlined,
                        color: context.colors.primary,
                        size: 22.r,
                      ),
                    ),
                    title: TextWidget(
                      'Choose from map',
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    subtitle: TextWidget(
                      'Search or tap on the map',
                      style: AppTextStyles.bodyXSmall.copyWith(
                        color: context.colors.secondaryText,
                      ),
                    ),
                    onTap: widget.onChooseFromMap,
                  ),
                  if (widget.savedPlaces.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                      child: TextWidget(
                        'Saved places',
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.secondaryText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...widget.savedPlaces.map((place) {
                      final name = place.placePrimaryName?.isNotEmpty == true
                          ? place.placePrimaryName!
                          : (place.placeSecondaryName ?? '');
                      final lat = double.tryParse(place.latitude ?? '');
                      final lng = double.tryParse(place.longtitude ?? '');
                      final coord = (lat != null && lng != null)
                          ? LatLng(lat, lng)
                          : null;
                      return ListTile(
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: context.colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.place_outlined,
                            color: context.colors.secondaryText,
                            size: 22.r,
                          ),
                        ),
                        title: TextWidget(
                          name,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _handleSavedPlace(
                          name: name,
                          coord: coord,
                          fromAirportList: false,
                        ),
                      );
                    }),
                  ],
                  if (widget.showAirports && widget.airports.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                      child: TextWidget(
                        'Airports',
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.secondaryText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...widget.airports.map((airport) {
                      final name = widget.localizeAirportName?.call(airport) ??
                          airport.airportPimaryName ??
                          '';
                      final lat = double.tryParse(airport.latitude ?? '');
                      final lng = double.tryParse(airport.longitude ?? '');
                      final coord = (lat != null && lng != null)
                          ? LatLng(lat, lng)
                          : null;
                      return ListTile(
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: context.colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.flight_outlined,
                            color: context.colors.secondaryText,
                            size: 22.r,
                          ),
                        ),
                        title: TextWidget(
                          name,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _handleSavedPlace(
                          name: name,
                          coord: coord,
                          fromAirportList: true,
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
