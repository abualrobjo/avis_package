/// Request body for BookChauffeurRequest API (confirm booking).
/// Pickup_latitude / DropOff_latitude = address string; Pickup_longtitude / DropOff_longtitude = "lat,lng".
class BookChauffeurRequestBody {
  final int companyId;
  final int customerId;
  final int branchId;
  /// 2 = static
  final int requestSourceId;
  /// 7 = static
  final int requestStatusId;
  final int tripTypeId;
  /// Pickup address (e.g. "City Mall, Amman, Jordan")
  final String pickupLatitude;
  /// Pickup coordinates "lat,lng" (e.g. "31.9800739,35.8366624")
  final String pickupLongtitude;
  /// Drop-off address
  final String dropOffLatitude;
  /// Drop-off coordinates "lat,lng"
  final String dropOffLongtitude;
  final int? tripsHour;
  final int? tripsDay;
  final bool haveMeetGreet;
  final bool isWifiRequired;
  final int fromZoneId;
  final int toZoneId;
  /// Vehicle class id
  final int classId;
  final bool onCurb;
  /// ISO format e.g. "2026-03-05T14:30:00"
  final String tripDateTime;
  /// Return leg datetime when [isRoundTrip]; same format as [tripDateTime].
  final String? returnTripDateTime;
  /// Estimated duration in minutes between pickup and drop-off
  final int tripDurationMinutes;
  final String? promoCode;
  final String? loyalityRedeemCode;
  /// True when drop-off is at airport.
  final bool isDropoffAirport;
  /// Half-day trip (from Najeeb).
  final bool isHalfDay;
  /// Round trip (from Najeeb).
  final bool isRoundTrip;
  /// Per-day booking (from Najeeb); typically same as duration "by day" mode.
  final bool isPerDay;
  final String? frequentFlyerNumber;
  final String? eTicketNumber;
  /// Selected airline id from GetFlightNames dropdown.
  final int flightNameId;
  /// Flight number from the flight number field.
  final String? flightNumber;
  final bool isBookForOther;
  /// 1 = Mr, 2 = Ms
  final int? otherTitle;
  final String? otherFirstName;
  final String? otherLastName;
  final String? otherEmail;
  final String? otherPhone;

  const BookChauffeurRequestBody({
    required this.companyId,
    required this.customerId,
    required this.branchId,
    this.requestSourceId = 3,
    this.requestStatusId = 7,
    required this.tripTypeId,
    required this.pickupLatitude,
    required this.pickupLongtitude,
    required this.dropOffLatitude,
    required this.dropOffLongtitude,
    this.tripsHour,
    this.tripsDay,
    required this.haveMeetGreet,
    required this.isWifiRequired,
    required this.fromZoneId,
    required this.toZoneId,
    required this.classId,
    required this.onCurb,
    required this.tripDateTime,
    this.returnTripDateTime,
    required this.tripDurationMinutes,
    this.promoCode,
    this.loyalityRedeemCode,
    this.isDropoffAirport = false,
    this.isHalfDay = false,
    this.isRoundTrip = false,
    this.isPerDay = false,
    this.frequentFlyerNumber,
    this.eTicketNumber,
    this.flightNameId = 0,
    this.flightNumber,
    this.isBookForOther = false,
    this.otherTitle,
    this.otherFirstName,
    this.otherLastName,
    this.otherEmail,
    this.otherPhone,
  });

  Map<String, dynamic> toJson() => {
        'CompanyId': companyId,
        'Customer_Id': customerId,
        'BranchId': branchId,
        'RequestSource_Id': requestSourceId,
        'RequestStatus_Id': requestStatusId,
        'TripType_Id': tripTypeId,
        'Pickup_latitude': pickupLatitude,
        'Pickup_longtitude': pickupLongtitude,
        'DropOff_latitude': dropOffLatitude,
        'DropOff_longtitude': dropOffLongtitude,
        'TripHours': tripsHour,
        'TripsDay': tripsDay,
        'HaveMeetAndGreet': haveMeetGreet,
        'IsWifiRequired': isWifiRequired,
        'FromZoneId': fromZoneId,
        'ToZoneId': toZoneId,
        'ClassId': classId,
        'HaveOnCurb': onCurb,
        'TripDateTime': tripDateTime,
        if (returnTripDateTime != null) 'ReturnTripDateTime': returnTripDateTime,
        'TripDurationMinutes': tripDurationMinutes,
        'PromoCode': promoCode,
        'LoyalityRedeemCode': loyalityRedeemCode,
        'isDropoffAirport': isDropoffAirport,
        'IsHalfDay': isHalfDay,
        'IsRoundTrip': isRoundTrip,
        'IsPerDay': isPerDay,
        'FrequentFlyerNumber': frequentFlyerNumber,
        'ETicketNumber': eTicketNumber,
        'flightName_Id': flightNameId,
        'flightNumber': flightNumber,
        'IsBookForOther': isBookForOther,
        'OtherTitle': otherTitle,
        'OtherFirstName': otherFirstName,
        'OtherLastName': otherLastName,
        'OtherEmail': otherEmail,
        'OtherPhone': otherPhone,
      };
}
