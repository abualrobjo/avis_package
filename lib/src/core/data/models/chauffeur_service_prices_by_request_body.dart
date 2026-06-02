/// Request body for GetChauffeurServicePrices_byRequest API.
class ChauffeurServicePricesByRequestBody {
  final int companyId;
  final int customerId;
  final int tripTypeId;
  final int? tripsHour;
  final int? tripsDay;
  final bool haveMeetGreet;
  final bool isWifiRequired;
  final bool useCompanyPricing;
  final int fromZoneId;
  final int toZoneId;
  final int vehicleClassId;
  final bool onCurb;
  final bool isDropoffAirport;
  final String tripDateTime;
  /// Return leg date when round trip; format dd/MM/yyyy e.g. 21/05/2026.
  final String? returnDate;
  final int tripDurationMinutes;
  final int branchId;
  final String? promoCode;
  final int applicableApplication;
  final String? loyalityRedeemCode;

  const ChauffeurServicePricesByRequestBody({
    required this.companyId,
    required this.customerId,
    required this.tripTypeId,
    this.tripsHour,
    this.tripsDay,
    required this.haveMeetGreet,
    required this.isWifiRequired,
    this.useCompanyPricing = false,
    required this.fromZoneId,
    required this.toZoneId,
    required this.vehicleClassId,
    required this.onCurb,
    required this.isDropoffAirport,
    required this.tripDateTime,
    this.returnDate,
    required this.tripDurationMinutes,
    required this.branchId,
    this.promoCode,
    this.applicableApplication = 2,
    this.loyalityRedeemCode,
  });

  Map<String, dynamic> toJson() => {
        'CompanyId': companyId,
        'CustomerId': customerId,
        'TripTypeId': tripTypeId,
        'TripsHour': tripsHour,
        'TripsDay': tripsDay,
        'HaveMeetGreet': haveMeetGreet,
        'IsWifiRequired': isWifiRequired,
        'UseCompanyPricing': useCompanyPricing,
        'FromZoneId': fromZoneId,
        'ToZoneId': toZoneId,
        'VehicleClassId': vehicleClassId,
        'OnCurb': onCurb,
        'IsDropoffAirport': isDropoffAirport,
        'TripDateTime': tripDateTime,
        if (returnDate != null) 'returnDate': returnDate,
        'TripDurationMinutes': tripDurationMinutes,
        'BranchId': branchId,
        'PromoCode': promoCode,
        'ApplicableApplication': applicableApplication,
        'LoyalityRedeemCode': loyalityRedeemCode,
      };
}
