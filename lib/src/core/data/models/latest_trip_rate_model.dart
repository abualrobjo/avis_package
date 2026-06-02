/// CheckLatestTripRate API responseDetails.
class LatestTripRateModel {
  final int tripId;
  final int chauffeurId;
  final String? chauffeurPrimaryName;
  final String? chauffeurSecondaryName;
  final String? tripTypePrimaryName;
  final String? tripTypeSecondaryName;
  final int customerId;
  final bool isRatedByCustomer;

  const LatestTripRateModel({
    required this.tripId,
    required this.chauffeurId,
    this.chauffeurPrimaryName,
    this.chauffeurSecondaryName,
    this.tripTypePrimaryName,
    this.tripTypeSecondaryName,
    required this.customerId,
    this.isRatedByCustomer = false,
  });

  factory LatestTripRateModel.fromJson(Map<String, dynamic> json) {
    return LatestTripRateModel(
      tripId: (json['tripId'] as num?)?.toInt() ?? 0,
      chauffeurId: (json['chauffeurId'] as num?)?.toInt() ?? 0,
      chauffeurPrimaryName: json['chauffeurPrimaryName'] as String?,
      chauffeurSecondaryName: json['chauffeurSecondaryName'] as String?,
      tripTypePrimaryName: json['tripTypePrimaryName'] as String?,
      tripTypeSecondaryName: json['tripTypeSecondaryName'] as String?,
      customerId: (json['customerId'] as num?)?.toInt() ?? 0,
      isRatedByCustomer: json['isRatedByCustomer'] as bool? ?? false,
    );
  }

  static const LatestTripRateModel empty = LatestTripRateModel(
    tripId: 0,
    chauffeurId: 0,
    customerId: 0,
  );
}
