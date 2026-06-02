/// Single vehicle from GetAvailableVehicles API.
/// Use across the project (e.g. change vehicle, trip assignment).
class AvailableVehicleModel {
  const AvailableVehicleModel({
    required this.id,
    required this.plateNumber,
    required this.manufacturingYear,
    this.manufacturerPrimaryName,
    this.manufacturerSecondaryName,
    this.vehicleModelPrimaryName,
    this.vehicleModelSecondaryName,
    this.vehicleClassPrimaryName,
    this.vehicleClassSecondaryName,
    this.isLastUsed = 0,
  });

  final int id;
  final String plateNumber;
  final int manufacturingYear;
  final String? manufacturerPrimaryName;
  final String? manufacturerSecondaryName;
  final String? vehicleModelPrimaryName;
  final String? vehicleModelSecondaryName;
  final String? vehicleClassPrimaryName;
  final String? vehicleClassSecondaryName;
  final int isLastUsed;

  factory AvailableVehicleModel.fromJson(Map<String, dynamic> json) {
    return AvailableVehicleModel(
      id: json['id'] as int? ?? 0,
      plateNumber: json['plateNumber'] as String? ?? '',
      manufacturingYear: json['manufacturingYear'] as int? ?? 0,
      manufacturerPrimaryName: json['manufacturerPrimaryName'] as String?,
      manufacturerSecondaryName: json['manufacturerSecondaryName'] as String?,
      vehicleModelPrimaryName: json['vehicleModelPrimaryName'] as String?,
      vehicleModelSecondaryName: json['vehicleModelSecondaryName'] as String?,
      vehicleClassPrimaryName: json['vehicleClassPrimaryName'] as String?,
      vehicleClassSecondaryName: json['vehicleClassSecondaryName'] as String?,
      isLastUsed: json['isLastUsed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'manufacturingYear': manufacturingYear,
      'manufacturerPrimaryName': manufacturerPrimaryName,
      'manufacturerSecondaryName': manufacturerSecondaryName,
      'vehicleModelPrimaryName': vehicleModelPrimaryName,
      'vehicleModelSecondaryName': vehicleModelSecondaryName,
      'vehicleClassPrimaryName': vehicleClassPrimaryName,
      'vehicleClassSecondaryName': vehicleClassSecondaryName,
      'isLastUsed': isLastUsed,
    };
  }

  /// Display label (e.g. "Hyundai i20 • 5426 - L A X")
  String get displayLabel {
    final make = manufacturerPrimaryName ?? '';
    final model = vehicleModelPrimaryName ?? '';
    final part = [make, model].where((s) => s.isNotEmpty).join(' ');
    return part.isEmpty ? plateNumber : '$part • $plateNumber';
  }
}
