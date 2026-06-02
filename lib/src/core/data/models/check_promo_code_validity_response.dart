/// responseDetails from CheckPromoCodeValidity API.
class CheckPromoCodeValidityDetails {
  final bool isValid;
  final int airlineId;
  final bool isRelatedToFlight;
  final bool isFreeRide;

  const CheckPromoCodeValidityDetails({
    this.isValid = false,
    this.airlineId = 0,
    this.isRelatedToFlight = false,
    this.isFreeRide = false,
  });

  factory CheckPromoCodeValidityDetails.fromJson(Map<String, dynamic> json) {
    return CheckPromoCodeValidityDetails(
      isValid: _parseBool(json['isValid']),
      airlineId: (json['airlineId'] as num?)?.toInt() ?? 0,
      isRelatedToFlight: _parseBool(json['isrelatedToFlight']),
      isFreeRide: _parseBool(json['isFreeRide']),
    );
  }

  /// Valid when API [isValid] is true.
  bool get isPromoValid => isValid;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return false;
}
