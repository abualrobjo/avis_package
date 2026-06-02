/// Request body for GetVehicleClassesPriceByTripType API.
class VehicleClassesPriceRequest {
  final int tripId;
  final int customerId;
  final int hoursCount;
  final int tripHours;
  final int? companyCustomerId;
  final int companyId;
  final int branchId;
  final String tripDateTime;
  /// Return leg datetime (same format as [tripDateTime]); round / 2-way trips only.
  final String? returnTripDateTime;
  final int fromCityId;
  final int toCityId;
  final int tripDays;
  /// Half-day trip (from Najeeb).
  final bool isHalfDay;
  /// Round trip (from Najeeb).
  final bool isRoundTrip;
  /// Per-day booking (from Najeeb).
  final bool isPerDay;
  /// True when drop-off is at an airport.
  final bool isDropoffAirport;

  const VehicleClassesPriceRequest({
    required this.tripId,
    required this.customerId,
    required this.hoursCount,
    required this.tripHours,
    this.companyCustomerId,
    this.companyId = 1,
    required this.branchId,
    required this.tripDateTime,
    this.returnTripDateTime,
    required this.fromCityId,
    required this.toCityId,
    required this.tripDays,
    this.isHalfDay = false,
    this.isRoundTrip = false,
    this.isPerDay = false,
    this.isDropoffAirport = false,
  });

  Map<String, dynamic> toJson() => {
        'TripId': tripId,
        'CustomerId': customerId,
        'HoursCount': hoursCount,
        'TripHours': tripHours,
        'CompanyCustomerId': companyCustomerId,
        'CompanyId': companyId,
        'BranchId': branchId,
        'TripDateTime': tripDateTime,
        if (returnTripDateTime != null) 'ReturnDateTime': returnTripDateTime,
        'FromCityId': fromCityId,
        'ToCityId': toCityId,
        'TripDays': tripDays,
        'IsHalfDay': isHalfDay,
        'IsRoundTrip': isRoundTrip,
        'IsPerDay': isPerDay,
        'IsDropoffAirport': isDropoffAirport,
      };
}
