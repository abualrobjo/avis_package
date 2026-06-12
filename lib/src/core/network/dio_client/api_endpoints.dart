
import 'package:avis_package/avis_package.dart';

/// API endpoint constants that mirror the existing ApiUrls class.
///
/// This class provides a centralized place for all API endpoints,
/// making it easy to maintain and update endpoint paths.
///
/// Usage:
/// ```dart
/// client.post(
///   endpoint: ApiEndpoints.login,
///   body: credentials,
///   parser: (json) => UserModel.fromJson(json['data']),
/// );
/// ```
class ApiEndpoints {
  ApiEndpoints._();

  // ===========================================================================
  // Base Configuration
  // ===========================================================================

  /// Base URL for the API.
  static const String baseUrl = 'https://avisbudget.fleetexpress.me/';
  static const String vehicleApi = 'VehicleAPI';
  static const String vehicleApi2 = 'vehicleapi';
  static const String erpApi = 'ERPAPI';
  static const String imagePath = '${baseUrl}Vehicle/Content/VehicleFiles/';

  /// OAuth token endpoint.
  static const String token = '$vehicleApi/token';

  // ===========================================================================
  // Customer / Trips
  // ===========================================================================

  /// GET CustomerInformation/CustomerTripsHistory?CustomerId=
  static const String customerTripsHistory =
      '$vehicleApi/CustomerInformation/CustomerTripsHistory';

  /// GET CustomerInformation/GetCustomerTripById?TripId=
  static const String getCustomerTripById =
      '$vehicleApi/CustomerInformation/GetCustomerTripById';

  /// GET CustomerInformation/GetCustomerInfo?CustomerId=
  static const String getCustomerInfo =
      '$vehicleApi/CustomerInformation/GetCustomerInfo';

  /// GET CustomerInformation/CheckLatestTripRate?CustomerId=
  static const String checkLatestTripRate =
      '$vehicleApi/CustomerInformation/CheckLatestTripRate';

  /// POST CustomerInformation/CustomerFavoriteDrivers
  static const String customerFavoriteDrivers =
      '$vehicleApi/CustomerInformation/CustomerFavoriteDrivers';

  /// GET ChauffeurService/GetTripsTypeWithConfig (trip types with visibility/options)
  static const String getTripsTypeWithConfig =
      '$vehicleApi/ChauffeurService/GetTripsTypeWithConfig';

  /// GET ChauffeurService/GetFlightNames?language= (flight/airline names for dropdown)
  static const String getFlightNames =
      '$vehicleApi/ChauffeurService/GetFlightNames';

  /// GET ChauffeurService/GetAirports (airports list for place picker when requiresFlightNumber)
  static const String getAirports = '$vehicleApi/ChauffeurService/GetAirports';

  /// POST ChauffeurService/GetVehicleClassesPriceByTripType (vehicle classes with price by trip details)
  static const String getVehicleClassesPriceByTripType =
      '$vehicleApi/ChauffeurService/GetVehicleClassesPriceByTripType';

  /// POST ChauffeurService/GetChauffeurServicePrices_byRequest (prices by request for review trip)
  static const String getChauffeurServicePricesByRequest =
      '$vehicleApi/ChauffeurService/GetChauffeurServicePrices_byRequest';

  /// POST ChauffeurService/BookChauffeurRequest (confirm booking; returns id for GetCustomerTripById)
  static const String bookChauffeurRequest =
      '$vehicleApi/ChauffeurService/BookChauffeurRequest';

  /// GET Zones/GetAllowedPolygonsAreas (polygon points for allowed map areas)
  static const String getAllowedPolygonsAreas =
      '$vehicleApi/Zones/GetAllowedPolygonsAreas';

  /// GET Zones/FindAllowedAreasPolygonByPickupCordTripId?Platitude=&Plongtitude=&TripTypeId=
  static const String findAllowedAreasPolygonByPickupCordTripId =
      '$vehicleApi/Zones/FindAllowedAreasPolygonByPickupCordTripId';

  /// GET Zones/CheckdropCordinatesPolygonwithPickupCordinatesandTripId?Platitude=&Plongtitude=&TripTypeId=&Dlatitude=&Dlongtitude=
  static const String
  checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId =
      '$vehicleApi/Zones/CheckdropCordinatesPolygonwithPickupCordinatesandTripId';

  // ===========================================================================
  // Saved Locations
  // ===========================================================================

  /// GET CustomerInformation/GetCustomerSavedPlaces?CustomerId=
  static const String getCustomerSavedPlaces =
      '$vehicleApi/CustomerInformation/GetCustomerSavedPlaces';

  /// POST Customer Saved Places "Locations"
  static const String addCustomerSavedPlace =
      '$vehicleApi/CustomerInformation/CustomerSavePlace';

  /// DELETE Customer Saved Places "Locations"
  static const String deleteSavedPlace =
      '$vehicleApi/CustomerInformation/DeleteSavedPlace';

  // ===========================================================================
  // Promo Code
  // ===========================================================================

  /// POST OffersPromoCode/CheckPromoCodeValidity (check promo code validity)
  static const String checkPromoCodeValidity =
      '$vehicleApi/OffersPromoCode/CheckPromoCodeValidity';

  // ===========================================================================
  // Customer Loyalty
  // ===========================================================================

  /// POST CustomerLoyaltyPromoCode/GenerateCustomerLoyaltyPromoCode (redeem points → promo code)
  static const String generateCustomerLoyaltyPromoCode =
      '$vehicleApi/CustomerLoyaltyPromoCode/GenerateCustomerLoyaltyPromoCode';

  // ===========================================================================
  // Cancel Ride
  // ===========================================================================

  /// POST ChauffeurService/ValidateCancellation (validate cancel)
  static const String cancelRideRequest =
      '$vehicleApi/ChauffeurService/ValidateCancellation';

  /// GET ChauffeurService/CancelChauffeurServiceResquest?id=&CreatedBy=0 (call after validate when responseDetails == 1)
  static const String cancelChauffeurServiceRequest =
      '$vehicleApi/ChauffeurService/CancelChauffeurServiceResquest';

  /// Check payment status
  static const String checkPaymentStatus =
      '$vehicleApi/ChauffeurService/CheckIFChauffeurServiceRequestPaid';
}
