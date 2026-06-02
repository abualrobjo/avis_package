class AddCustomerSavedPlaceParams {
  /// Static place category for saved locations (API expects 1).
  static const int placeCategory = 1;

  final int customerId;
  final int placeCategoryId;
  final String latitude;
  final String longtitude;
  final String placePrimaryName;
  final String placeSecondaryName;

  AddCustomerSavedPlaceParams({
    this.customerId = 0,
    this.placeCategoryId = placeCategory,
    this.latitude = '',
    this.longtitude = '',
    this.placePrimaryName = '',
    this.placeSecondaryName = '',
  });

  Map<String, dynamic> toJson() => {
    'CustomerId': customerId,
    'PlaceCategoryId': placeCategoryId,
    'latitude': latitude,
    'longtitude': longtitude,
    'PlacePrimaryName': placePrimaryName,
    'PlaceSecondaryName': placeSecondaryName,
  };

  AddCustomerSavedPlaceParams copyWith({
    int? customerId,
    int? placeCategoryId,
    String? latitude,
    String? longtitude,
    String? placePrimaryName,
    String? placeSecondaryName,
  }) => AddCustomerSavedPlaceParams(
    customerId: customerId ?? this.customerId,
    placeCategoryId: placeCategoryId ?? this.placeCategoryId,
    latitude: latitude ?? this.latitude,
    longtitude: longtitude ?? this.longtitude,
    placePrimaryName: placePrimaryName ?? this.placePrimaryName,
    placeSecondaryName: placeSecondaryName ?? this.placeSecondaryName,
  );
}
