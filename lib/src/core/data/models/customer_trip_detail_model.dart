import 'package:avis_package/src/core/utils/extensions/app_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// One item from CustomerTripsHistory API responseDetails list.
class CustomerTripDetailModel {
  final int tripId;

  final String? pickupLatitude;
  final String? pickupLongtitude;
  final String? dropOffLatitude;
  final String? dropOffLongtitude;

  final String? plateNumber;

  /// Trip date/time from API
  final DateTime? tripDateTime;

  final int chauffeurId;
  final String? chauffeurPrimaryName;
  final String? chauffeurSecondaryName;

  final int? statusId;
  final String? statusPrimaryName;
  final String? statusSecondaryName;
  final String? tripTypePrimaryName;
  final String? tripTypeSecondaryName;

  const CustomerTripDetailModel({
    required this.tripId,
    this.pickupLatitude,
    this.pickupLongtitude,
    this.dropOffLatitude,
    this.dropOffLongtitude,
    this.plateNumber,
    this.tripDateTime,
    required this.chauffeurId,
    this.chauffeurPrimaryName,
    this.chauffeurSecondaryName,
    this.statusId,
    this.statusPrimaryName,
    this.statusSecondaryName,
    this.tripTypePrimaryName,
    this.tripTypeSecondaryName,
  });

  factory CustomerTripDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerTripDetailModel(
      tripId: (json['tripId'] as num?)?.toInt() ?? 0,

      pickupLatitude: json['pickup_latitude'] as String?,
      pickupLongtitude: json['pickup_longtitude'] as String?,
      dropOffLatitude: json['dropOff_latitude'] as String?,
      dropOffLongtitude: json['dropOff_longtitude'] as String?,

      plateNumber: json['plateNumber'] as String?,

      tripDateTime: json['tripDateTime'] != null
          ? DateTime.tryParse(json['tripDateTime'])
          : null,

      chauffeurId: (json['chauffeurId'] as num?)?.toInt() ?? 0,
      chauffeurPrimaryName: json['chauffeurPrimaryName'] as String?,
      chauffeurSecondaryName: json['chauffeurSecondaryName'] as String?,

      statusId: (json['statusId'] as num?)?.toInt(),
      statusPrimaryName: json['statusPrimaryName'] as String?,
      statusSecondaryName: json['statusSecondaryName'] as String?,
      tripTypePrimaryName: json['tripTypePrimaryName'] as String?,
      tripTypeSecondaryName: json['tripTypeSecondaryName'] as String?,
    );
  }

  /// Formats tripDateTime for UI
  static String formatTripDateTime(DateTime? tripDateTime) {
    if (tripDateTime == null) return '';
    return DateFormat('d MMM yyyy, hh:mm a').format(tripDateTime);
  }

  /// Parse "lat,lon" string → (latitude, longitude)
  static ({double lat, double lon})? parseLatLngString(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());

    if (lat == null || lon == null) return null;

    return (lat: lat, lon: lon);
  }

  /// Trip list / card title: drop-off place when present, otherwise pickup.
  String get tripListPlaceTitle {
    final drop = dropOffLatitude?.trim();
    if (drop != null && drop.isNotEmpty) return drop;
    return pickupLatitude ?? '';
  }
}


enum MyTripTab { upcoming, active, finished, cancelled }

extension CustomerTripTabFilter on CustomerTripDetailModel {
  static const _activeStatusIds = {8, 9, 10};

  MyTripTab get myTripTab {
    if (statusId != null && _activeStatusIds.contains(statusId)) {
      return MyTripTab.active;
    }
    final status = statusPrimaryName?.trim().toLowerCase();
    if (status == 'finished') return MyTripTab.finished;
    if (status == 'cancelled') return MyTripTab.cancelled;
    return MyTripTab.upcoming;
  }
}

extension CustomerTripStatusUI on CustomerTripDetailModel {

  Color statusBackgroundColor(BuildContext context) {
    switch (statusId) {
      case 7: // Pending Payment
        return context.colors.warningBackground;

      case 5: // Cancelled
        return context.colors.errorBackground;

      case 4: // Finished
        return context.colors.successBackground;

      case 2: // Dispatched
        return context.colors.infoBackground;

      default: // Active or others
        return context.colors.infoBackground;
    }
  }

  Color statusTextColor(BuildContext context) {
    switch (statusId) {
      case 7:
        return context.colors.secondaryText;

      case 5:
        return context.colors.secondaryText;

      case 4:
        return context.colors.secondaryText;

      case 2:
        return context.colors.secondaryText;

      default:
        return context.colors.secondaryText;
    }
  }
}