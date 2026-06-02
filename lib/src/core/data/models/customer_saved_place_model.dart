class CustomerSavedPlaceModel {
  final int id;
  final int customerId;
  final int? placeCategoryId;
  final String? placePrimaryName;
  final String? placeSecondaryName;
  final String? categoryPrimaryName;
  final String? categorySecondaryName;
  final String? latitude;
  final String? longtitude;

  /// Transient property to hold the calculated distance from the user's current device location.
  /// This is not saved to API natively but used in UI.
  double? distanceInKm;

  CustomerSavedPlaceModel({
    required this.id,
    required this.customerId,
    this.placeCategoryId,
    this.placePrimaryName,
    this.placeSecondaryName,
    this.categoryPrimaryName,
    this.categorySecondaryName,
    this.latitude,
    this.longtitude,
  });

  factory CustomerSavedPlaceModel.fromJson(Map<String, dynamic> json) {
    return CustomerSavedPlaceModel(
      id: (json['id'] as num).toInt(),
      customerId: (json['customerId'] as num).toInt(),
      placeCategoryId: (json['placeCategoryId'] as num?)?.toInt(),
      placePrimaryName: json['placePrimaryName'] as String?,
      placeSecondaryName: json['placeSecondaryName'] as String?,
      categoryPrimaryName: json['categoryPrimaryName'] as String?,
      categorySecondaryName: json['categorySecondaryName'] as String?,
      latitude: json['latitude'] as String?,
      longtitude: json['longtitude'] as String?,
    );
  }
}
