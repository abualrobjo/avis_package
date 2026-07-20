import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        LocalizationProvider,
        AvailableVehicleModel,
        CustomerTripByIdModel,
        CustomerTripDetailModel,
        LookupModel;

extension LocalizationUtils on BuildContext {
  bool get isArabic => read<LocalizationProvider>().isArabic;

  /// Returns [primary] if current locale is English (or not Arabic),
  /// and [secondary] if current locale is Arabic.
  /// If [secondary] is null, falls back to [primary].
  T localized<T>(T primary, T? secondary) {
    if (isArabic && secondary != null) {
      return secondary;
    }
    return primary;
  }
}

extension VehicleExtension on AvailableVehicleModel {
  String manufacturerLocalized(BuildContext context) {
    return context.localized(
      manufacturerPrimaryName ?? '',
      manufacturerSecondaryName,
    );
  }
}

extension CustomerTripByIdModelExtension on CustomerTripByIdModel {
  String customerNameLocalized(BuildContext context) {
    return context.localized(
      customerPrimaryName ?? '',
      customerSecondaryname ?? '',
    );
  }

  String chauffeurNameLocalized(BuildContext context) {
    return context.localized(
      chauffeurPrimaryName ?? '',
      chauffeurSecondaryName ?? '',
    );
  }

  String statusLocalized(BuildContext context) {
    return context.localized(
      statusPrimaryName ?? '',
      statusSecondaryName ?? '',
    );
  }

  String colorLocalized(BuildContext context) {
    return context.localized(colorPrimaryName ?? '', colorSecondaryName ?? '');
  }

  String manufacturerLocalized(BuildContext context) {
    return context.localized(
      manufacturerPrimaryName ?? '',
      manufacturerSecondaryName ?? '',
    );
  }

  String vehicleClassLocalized(BuildContext context) {
    return context.localized(
      vehicleClassPrimaryName ?? '',
      vehicleClassSecondaryName ?? '',
    );
  }

  String tripTypeLocalized(BuildContext context) {
    return context.localized(
      tripTypePrimaryName ?? '',
      tripTypeSecondaryName ?? '',
    );
  }

  String assignedVehicleLine(BuildContext context) {
    final make = manufacturerLocalized(context).trim();
    final color = colorLocalized(context).trim();
    if (make.isEmpty && color.isEmpty) return '';
    if (make.isEmpty) return color;
    if (color.isEmpty) return make;
    return '$make - $color';
  }
}

extension CustomerTripDetailModelExtension on CustomerTripDetailModel {
  String chauffeurNameLocalized(BuildContext context) {
    return context.localized(
      chauffeurPrimaryName ?? '',
      chauffeurSecondaryName ?? '',
    );
  }

  String statusLocalized(BuildContext context) {
    return context.localized(
      statusPrimaryName ?? '',
      statusSecondaryName ?? '',
    );
  }

  String tripTypeLocalized(BuildContext context) {
    return context.localized(
      tripTypePrimaryName ?? '',
      tripTypeSecondaryName ?? '',
    );
  }
}

extension LookupItemExtension on LookupModel {
  String localizedName(BuildContext context) {
    return context.localized(primaryName, secondaryName);
  }
}
