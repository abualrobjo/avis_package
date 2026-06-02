/// Request body for GetCustomerSavedPlaces API.
class GetCustomerSavedPlacesParams {
  /// Static place category (API expects 1).
  static const int placeCategory = 1;

  final int customerId;
  final int placeCategoryValue;
  final String latitude;
  final String longtitude;

  GetCustomerSavedPlacesParams({
    required this.customerId,
    int? placeCategoryValue,
    this.latitude = '',
    this.longtitude = '',
  }) : placeCategoryValue =
            placeCategoryValue ?? GetCustomerSavedPlacesParams.placeCategory;

  Map<String, dynamic> toJson() => {
        'CustomerId': customerId,
        'PlaceCategory': placeCategoryValue,
        'latitude': latitude,
        'longtitude': longtitude,
      };
}
