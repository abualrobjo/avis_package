import 'package:easy_localization/easy_localization.dart';

bool? _parseNullableBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

class CustomerTripByIdModel {
  final int tripId;

  final String? customerPrimaryName;
  final String? customerSecondaryname;

  final String? chauffeurPrimaryName;
  final String? chauffeurSecondaryName;
  final String? chauffeurPhoneNumber;
  final String? chauffeurPhoto;

  final String? plateNumber;

  final bool? cancellationBookLaterEnabled;
  final int? cancellationBookLaterFreeDurationHours;

  /// Locations
  final String? pickupLatitude;
  final String? pickupLatLng;

  final String? dropOffLatitude;
  final String? dropOffLatLng;

  /// Dates
  final DateTime? tripDateTime;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;

  /// Status
  final int? statusId;
  final String? statusPrimaryName;
  final String? statusSecondaryName;

  /// Driver
  final int? chauffeurId;
  final double? driverAVGRate;

  /// Vehicle
  final int? manufacturingYear;

  final String? manufacturerPrimaryName;
  final String? manufacturerSecondaryName;

  final String? colorPrimaryName;
  final String? colorSecondaryName;
  final String? colorCode;

  final String? vehicleImagePath;
  final String? vehicleImageName;
  final String? vehicleClassImage;

  final String? vehicleClassPrimaryName;
  final String? vehicleClassSecondaryName;
  final String? classMiniDesc;
  final String? tripTypePrimaryName;
  final String? tripTypeSecondaryName;
  final int? tripTypeId;

  final int? passengersNo;
  final int? suitcasesNo;
  final int? tripHours;

  const CustomerTripByIdModel({
    required this.tripId,
    this.customerPrimaryName,
    this.customerSecondaryname,
    this.chauffeurPrimaryName,
    this.chauffeurSecondaryName,
    this.chauffeurPhoneNumber,
    this.chauffeurPhoto,
    this.plateNumber,
    this.cancellationBookLaterEnabled,
    this.cancellationBookLaterFreeDurationHours,
    this.pickupLatitude,
    this.pickupLatLng,
    this.dropOffLatitude,
    this.dropOffLatLng,
    this.tripDateTime,
    this.tripStartDate,
    this.tripEndDate,
    this.statusId,
    this.statusPrimaryName,
    this.statusSecondaryName,
    this.chauffeurId,
    this.driverAVGRate,
    this.manufacturingYear,
    this.manufacturerPrimaryName,
    this.manufacturerSecondaryName,
    this.colorPrimaryName,
    this.colorSecondaryName,
    this.colorCode,
    this.vehicleImagePath,
    this.vehicleImageName,
    this.vehicleClassImage,
    this.vehicleClassPrimaryName,
    this.vehicleClassSecondaryName,
    this.classMiniDesc,
    this.passengersNo,
    this.suitcasesNo,
    this.tripTypePrimaryName,
    this.tripTypeSecondaryName,
    this.tripTypeId,
    this.tripHours,
  });

  factory CustomerTripByIdModel.fromJson(Map<String, dynamic> json) {
    return CustomerTripByIdModel(
      tripId: (json['tripId'] as num?)?.toInt() ?? 0,

      customerPrimaryName: json['customerPrimaryName'],
      customerSecondaryname: json['customerSecondaryname'],

      chauffeurPrimaryName: json['chauffeurPrimaryName'],
      chauffeurSecondaryName: json['chauffeurSecondaryName'],
      chauffeurPhoneNumber: json['chauffeurPhoneNumber'],
      chauffeurPhoto: json['chauffeurPhoto'],
      tripTypePrimaryName: json['tripTypePrimaryName'],
      tripTypeSecondaryName: json['tripTypeSecondaryName'],
      tripTypeId: (json['tripTypeId'] as num?)?.toInt() ??
          (json['tripType_Id'] as num?)?.toInt() ??
          (json['TripTypeId'] as num?)?.toInt(),

      plateNumber: json['plateNumber'],

      cancellationBookLaterEnabled: _parseNullableBool(
        json['cancellationBookLaterEnabled'] ??
            json['CancellationBookLaterEnabled'],
      ),
      cancellationBookLaterFreeDurationHours:
          (json['cancellationBookLaterFreeDurationHours'] as num?)?.toInt() ??
          (json['CancellationBookLaterFreeDurationHours'] as num?)?.toInt(),

      /// Locations
      pickupLatitude: json['pickup_latitude'],
      pickupLatLng: json['pickup_longtitude'],

      dropOffLatitude: json['dropOff_latitude'],
      dropOffLatLng: json['dropOff_longtitude'],

      /// Dates
      tripDateTime: DateTime.tryParse(json['tripDateTime'] ?? ''),
      tripStartDate: DateTime.tryParse(json['tripStartDate'] ?? ''),
      tripEndDate: DateTime.tryParse(json['tripEndDate'] ?? ''),

      /// Status
      statusId: (json['statusId'] as num?)?.toInt(),
      statusPrimaryName: json['statusPrimaryName'],
      statusSecondaryName: json['statusSecondaryName'],

      /// Driver
      chauffeurId: (json['chauffeurId'] as num?)?.toInt(),
      driverAVGRate: (json['driverAVGRate'] as num?)?.toDouble(),

      /// Vehicle
      manufacturingYear: (json['manufacturingYear'] as num?)?.toInt(),

      manufacturerPrimaryName: json['manufacturerPrimaryName'],
      manufacturerSecondaryName: json['manufacturerSecondaryName'],

      colorPrimaryName: json['colorPrimaryName'],
      colorSecondaryName: json['colorSecondaryName'],
      colorCode: json['colorCode'],

      vehicleImagePath: json['vehicleImagePath'],
      vehicleImageName: json['vehicleImageName'],
      vehicleClassImage: json['vehicleClassImage'],

      vehicleClassPrimaryName: json['vehicleClassPrimaryName'],
      vehicleClassSecondaryName: json['vehicleClassSecondaryName'],
      classMiniDesc: json['classMiniDesc'] as String?,

      passengersNo: (json['passengersNo'] as num?)?.toInt(),
      suitcasesNo: (json['suitcasesNo'] as num?)?.toInt(),
      tripHours: (json['TripHours'] as num?)?.toInt() ??
          (json['tripHours'] as num?)?.toInt(),
    );
  }

  /// Convert "lat,lng" string → coordinates
  static (double lat, double lng)? parseLatLng(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());

    if (lat == null || lng == null) return null;

    return (lat, lng);
  }

  /// Date formatting
  static String formatTripDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('d MMM yyyy, HH:mm').format(dateTime);
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  bool get hasDropOffPlace {
    if (!showsDropOffSection) return false;
    final d = dropOffLatitude?.trim();
    return d != null && d.isNotEmpty;
  }

  /// Hourly / no drop-off trip types (trip type id 2).
  bool get showsDropOffSection => tripTypeId != 2;

  bool get showsTripHours => tripTypeId == 2;

  int get tripHoursValue => tripHours ?? 0;

  String get tripHoursLabel {
    final hours = tripHoursValue;
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  /// Class image from [vehicleClassImage].
  String get vehicleClassImageUrl {
    final classImage = vehicleClassImage?.trim();
    if (classImage == null || classImage.isEmpty) return '';
    return classImage.replaceAll('\\', '/');
  }

  /// Assigned vehicle photo when available.
  String get assignedVehicleImageUrl {
    final imageName = vehicleImageName?.trim();
    if (imageName == null || imageName.isEmpty) return '';

    final folder = vehicleImagePath?.trim().replaceAll('\\', '/');
    if (folder != null && folder.isNotEmpty) {
      if (folder.contains('.') &&
          !RegExp(r'^[0-9a-f-]{36}$', caseSensitive: false).hasMatch(folder)) {
        return folder;
      }
      return '$folder/$imageName';
    }
    return imageName;
  }

  /// Preferred vehicle image for UI.
  String get displayVehicleImage {
    final assigned = assignedVehicleImageUrl;
    if (assigned.isNotEmpty) return assigned;
    return vehicleClassImageUrl;
  }

  /// Secondary image when the primary fails to load.
  String get fallbackVehicleImage {
    final assigned = assignedVehicleImageUrl;
    final classImage = vehicleClassImageUrl;
    if (assigned.isNotEmpty &&
        classImage.isNotEmpty &&
        assigned != classImage) {
      return classImage;
    }
    return '';
  }

  bool get hasAssignedVehicle {
    final plate = plateNumber?.trim();
    if (plate != null && plate.isNotEmpty) return true;
    final make = manufacturerPrimaryName?.trim();
    return make != null && make.isNotEmpty;
  }

  /// Route widget second row: label when drop-off exists, otherwise [Pickup].
  String get routeDropOffSectionLabel =>
      hasDropOffPlace ? 'Your Destination' : 'Pickup';

  /// Route widget second row address.
  String get routeDropOffSectionLocation =>
      hasDropOffPlace ? (dropOffLatitude ?? '').trim() : (pickupLatitude ?? '');

  /// Status ids when driver contact (call/chat) is available.
  static const activeTripStatusIds = {2, 8, 9, 10};

  bool get isActiveTripSession =>
      statusId != null && activeTripStatusIds.contains(statusId);

  bool get isCancellationAllowed {
    if (cancellationBookLaterEnabled != true) return false;

    if (tripDateTime != null &&
        cancellationBookLaterFreeDurationHours != null &&
        cancellationBookLaterFreeDurationHours! > 0) {
      final cutoff = tripDateTime!.subtract(
        Duration(hours: cancellationBookLaterFreeDurationHours!),
      );

      if (DateTime.now().isAfter(cutoff)) {
        return false;
      }
    }

    return true;
  }
}
