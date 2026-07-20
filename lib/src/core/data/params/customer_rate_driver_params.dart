/// Request body for CustomerInformation/CustomerRateDriver.
class CustomerRateDriverParams {
  final int tripId;
  final int customerId;
  final int driverId;
  final int rateValue;
  final String? comment;
  final int? lowRateReason;

  const CustomerRateDriverParams({
    required this.tripId,
    required this.customerId,
    required this.driverId,
    required this.rateValue,
    this.comment,
    this.lowRateReason,
  });

  Map<String, dynamic> toJson() => {
        'TripId': tripId,
        'CustomerId': customerId,
        'DriverId': driverId,
        'RateValue': rateValue,
        'Comment': comment,
        if (lowRateReason != null) 'LowRateReason': lowRateReason,
      };
}
