import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart'
    show AppRoutes, AvisNavigation, CustomerSavedPlaceModel;
import 'package:avis_package/src/features/_features.dart'
    show SavedLocationsProvider, LocationOptionTile;

class SavedLocationsOptions extends StatelessWidget {
  const SavedLocationsOptions({super.key});

  String _formatSubtitle(String? address, double? distance) {
    if (address == null || address.isEmpty) return '';
    if (distance != null && distance > 0) {
      return '$address • ${distance.toStringAsFixed(1)} km';
    }
    return address;
  }

  void _onLocationSelect(
    BuildContext context,
    SavedLocationsProvider provider,
    CustomerSavedPlaceModel location,
  ) {
    provider.setSelectedLocation(location);
    Navigator.pop(context, location);
  }

  void _onNavigateToAddPlace(
    BuildContext context,
    SavedLocationsProvider provider,
    String type,
  ) {
    AvisNavigation.push(
      context,
      AppRoutes.addNewPlace,
      arguments: {'type': type, 'provider': provider},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedLocationsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final locations = provider.locations;

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          children: [
            ...locations.map((loc) {
              // Try to match icon based on name or category if we want to guess
              String icon = 'location-favourite';
              final name = loc.placePrimaryName?.toLowerCase() ?? '';
              if (name.contains('home')) {
                icon = 'home2';
              } else if (name.contains('work')) {
                icon = 'work';
              } else if (name.contains('airport')) {
                icon = 'airpot';
              }

              return LocationOptionTile(
                icon: icon,
                title: loc.placePrimaryName?.isNotEmpty == true
                    ? loc.placePrimaryName!
                    : 'Saved Location',
                subtitle: _formatSubtitle(
                  loc.placeSecondaryName,
                  loc.distanceInKm,
                ),
                onTap: () => _onLocationSelect(context, provider, loc),
                onDeleteTap: () => provider.deleteSavedPlace(placeId: loc.id),
              );
            }),
            LocationOptionTile(
              icon: 'add',
              title: 'Add New Place',
              onTap: () => _onNavigateToAddPlace(context, provider, 'custom'),
            ),
          ],
        );
      },
    );
  }
}
