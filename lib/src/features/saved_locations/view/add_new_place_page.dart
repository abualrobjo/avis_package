import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/services/place_search_helper.dart';
import 'package:avis_package/src/features/services/widgets/place_search_field_widget.dart';
import '../provider/saved_locations_provider.dart';
import 'widgets/_widgets.dart';

class AddNewPlacePage extends StatefulWidget {
  const AddNewPlacePage({super.key});

  @override
  State<AddNewPlacePage> createState() => _AddNewPlacePageState();
}

class _AddNewPlacePageState extends State<AddNewPlacePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDistances());
  }

  Future<void> _fetchDistances() async {
    try {
      if (await Geolocator.isLocationServiceEnabled() &&
          (await Geolocator.checkPermission() ==
                  LocationPermission.whileInUse ||
              await Geolocator.checkPermission() ==
                  LocationPermission.always)) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          context.read<SavedLocationsProvider>().calculateDistances(
                pos.latitude,
                pos.longitude,
              );
          setState(() {});
        }
      }
    } catch (_) {}
  }

  String get _placeType {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['type'] as String? ?? 'custom';
  }

  void _openLocationPicker({double? latitude, double? longitude}) {
    final arguments = <String, dynamic>{
      'type': _placeType,
      'provider': context.read<SavedLocationsProvider>(),
    };
    if (latitude != null) arguments['latitude'] = latitude;
    if (longitude != null) arguments['longitude'] = longitude;

    AvisNavigation.push(
      context,
      AppRoutes.locationPicker,
      arguments: arguments,
    );
  }

  Future<void> _onGooglePlaceSelected(PlaceSuggestion suggestion) async {
    final latLng = await PlaceSearchHelper.resolveSuggestion(suggestion);
    if (!mounted) return;

    if (latLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find this location. Try the map instead.'),
        ),
      );
      return;
    }

    _openLocationPicker(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  void _onSavedPlaceTap(CustomerSavedPlaceModel place) {
    context.read<SavedLocationsProvider>().setSelectedLocation(place);
    _openLocationPicker(
      latitude: double.tryParse(place.latitude ?? ''),
      longitude: double.tryParse(place.longtitude ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedPlaces = context.watch<SavedLocationsProvider>().locations;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: const BackArrowWidget(),
        title: TextWidget(
          'Add New Place',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: PlaceSearchFieldWidget(
              hintText: 'Search for a place or address',
              onSuggestionSelected: _onGooglePlaceSelected,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Divider(height: 1, color: context.colors.border),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
              children: [
                if (savedPlaces.isNotEmpty) ...[
                  TextWidget(
                    'Saved places',
                    style: AppTextStyles.bodyXSmallBold.copyWith(
                      color: context.colors.secondaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...savedPlaces.map((place) {
                    return SuggestionTile(
                      title: (place.placePrimaryName?.isNotEmpty == true)
                          ? place.placePrimaryName!
                          : 'Saved Place',
                      subtitle: place.placeSecondaryName ?? '',
                      distance: place.distanceInKm != null
                          ? '${place.distanceInKm!.toStringAsFixed(1)} km'
                          : null,
                      onTap: () => _onSavedPlaceTap(place),
                    );
                  }),
                  SizedBox(height: 16.h),
                ],
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: () => _openLocationPicker(),
                child: Container(
                  height: 48.h,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.colors.divider.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26.w,
                        height: 26.w,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: context.colors.border,
                          shape: BoxShape.circle,
                        ),
                        child: const SvgIconWidget(name: 'location-08'),
                      ),
                      SizedBox(width: 12.w),
                      TextWidget(
                        'Set location on map',
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
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
