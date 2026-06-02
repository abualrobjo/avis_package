/// Result of CheckdropCordinatesPolygonwithPickupCordinatesandTripId API.
class CheckDropCoordinatesResultModel {
  const CheckDropCoordinatesResultModel({
    required this.isSuccess,
    required this.isAllowed,
    this.primaryMessage,
    this.secondaryMessage,
    this.pickupZoneId,
    this.dropZoneId,
    this.pickupCityId,
    this.dropCityId,
  });

  final bool isSuccess;
  final bool isAllowed;
  final String? primaryMessage;
  final String? secondaryMessage;
  final int? pickupZoneId;
  final int? dropZoneId;
  final int? pickupCityId;
  final int? dropCityId;

  factory CheckDropCoordinatesResultModel.fromJson(Map<String, dynamic> json) {
    return CheckDropCoordinatesResultModel(
      isSuccess: json['isSuccess'] as bool? ?? false,
      isAllowed: json['isAllowed'] as bool? ?? false,
      primaryMessage: json['primaryMessage'] as String?,
      secondaryMessage: json['secondaryMessage'] as String?,
      pickupZoneId: (json['pickupZoneId'] as num?)?.toInt(),
      dropZoneId: (json['dropZoneId'] as num?)?.toInt(),
      pickupCityId: (json['pickupCityId'] as num?)?.toInt(),
      dropCityId: (json['dropCityId'] as num?)?.toInt(),
    );
  }
}
