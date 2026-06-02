/// One item from displayPrices array in GetChauffeurServicePrices_byRequest response.
class DisplayPriceItem {
  final String currencyCode;
  final double cancellationFees;
  final double noShowFees;
  final double meetingsAndGreetingsPrice;
  final double onCurbPrice;
  final double wifiFees;
  final double minPrice;
  final double returnTripPrice;
  final double returnTripPriceDiscount;
  final double orginalMinPrice;
  final double maxPrice;
  final double extraHourPrice;
  final double totalWithTax;
  final double totalWithoutTax;
  final double taxAmount;
  final double discountAmount;
  final double rushSurchargeAmount;

  const DisplayPriceItem({
    required this.currencyCode,
    this.cancellationFees = 0,
    this.noShowFees = 0,
    this.meetingsAndGreetingsPrice = 0,
    this.onCurbPrice = 0,
    this.wifiFees = 0,
    this.minPrice = 0,
    this.returnTripPrice = 0,
    this.returnTripPriceDiscount = 0,
    this.orginalMinPrice = 0,
    this.maxPrice = 0,
    this.extraHourPrice = 0,
    this.totalWithTax = 0,
    this.totalWithoutTax = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.rushSurchargeAmount = 0,
  });

  factory DisplayPriceItem.fromJson(Map<String, dynamic> json) {
    final code = json['currencyCode'] as String?;
    return DisplayPriceItem(
      currencyCode: code != null && code.isNotEmpty ? code.toUpperCase() : 'USD',
      cancellationFees: _toDouble(json['cancellationFees']),
      noShowFees: _toDouble(json['noShowFees']),
      meetingsAndGreetingsPrice: _toDouble(json['meetingsAndGreetingsPrice']),
      onCurbPrice: _toDouble(json['onCurbPrice']),
      wifiFees: _toDouble(json['wifiFees']),
      minPrice: _toDouble(json['minPrice']),
      returnTripPrice: _toDouble(json['returnTripPrice']),
      returnTripPriceDiscount: _toDouble(json['returnTripPriceDiscount']),
      orginalMinPrice: _toDouble(json['orginalMinPrice']),
      maxPrice: _toDouble(json['maxPrice']),
      extraHourPrice: _toDouble(json['extraHourPrice']),
      totalWithTax: _toDouble(json['totalWithTax']),
      totalWithoutTax: _toDouble(json['totalWithoutTax']),
      taxAmount: _toDouble(json['taxAmount']),
      discountAmount: _toDouble(json['discountAmount']),
      rushSurchargeAmount: _toDouble(json['rushSurchargeAmount']),
    );
  }
}

/// responseDetails from GetChauffeurServicePrices_byRequest API.
class ChauffeurServicePricesResponseDetails {
  final double cancellationFees;
  final int cityDirveRateId;
  final double noShowFees;
  final double meetingsAndGreetingsPrice;
  final double onCurbPrice;
  final int numberOfWaitingHours;
  final bool isWifiAvailable;
  final double wifiFees;
  final int minimumExtraHourRequests;
  final double minPrice;
  final double returnTripPrice;
  final double returnTripPriceDiscount;
  final double orginalMinPrice;
  final double maxPrice;
  final double extraHourPrice;
  final double totalWithTax;
  final double totalWithoutTax;
  final double taxAmount;
  final double taxRate;
  final double discountAmount;
  final int? matchedRushHourId;
  final bool applyRushSurcharge;
  final int graceDurationMinutes;
  final int tripDurationMinutes;
  final double rushSurchargeAmount;
  final bool applyOffer;
  final double offerDiscount;
  final int offerDiscountType;
  final String? currencyCode;
  final List<DisplayPriceItem> displayPrices;

  const ChauffeurServicePricesResponseDetails({
    required this.totalWithTax,
    this.cancellationFees = 0,
    this.cityDirveRateId = 0,
    this.noShowFees = 0,
    this.meetingsAndGreetingsPrice = 0,
    this.onCurbPrice = 0,
    this.numberOfWaitingHours = 0,
    this.isWifiAvailable = false,
    this.wifiFees = 0,
    this.minimumExtraHourRequests = 0,
    this.minPrice = 0,
    this.returnTripPrice = 0,
    this.returnTripPriceDiscount = 0,
    this.orginalMinPrice = 0,
    this.maxPrice = 0,
    this.extraHourPrice = 0,
    this.totalWithoutTax = 0,
    this.taxAmount = 0,
    this.taxRate = 0,
    this.discountAmount = 0,
    this.matchedRushHourId,
    this.applyRushSurcharge = false,
    this.graceDurationMinutes = 0,
    this.tripDurationMinutes = 0,
    this.rushSurchargeAmount = 0,
    this.applyOffer = false,
    this.offerDiscount = 0,
    this.offerDiscountType = 1,
    this.currencyCode,
    this.displayPrices = const [],
  });

  factory ChauffeurServicePricesResponseDetails.fromJson(Map<String, dynamic> json) {
    final rawList = json['displayPrices'] as List<dynamic>?;
    final list = rawList != null
        ? rawList
            .map((e) => DisplayPriceItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <DisplayPriceItem>[];

    return ChauffeurServicePricesResponseDetails(
      cancellationFees: _toDouble(json['cancellationFees']),
      cityDirveRateId: (json['cityDirveRate_Id'] as num?)?.toInt() ?? 0,
      noShowFees: _toDouble(json['noShowFees']),
      meetingsAndGreetingsPrice: _toDouble(json['meetingsAndGreetingsPrice']),
      onCurbPrice: _toDouble(json['onCurbPrice']),
      numberOfWaitingHours: (json['numberOfWaitingHours'] as num?)?.toInt() ?? 0,
      isWifiAvailable: json['isWifiAvailable'] as bool? ?? false,
      wifiFees: _toDouble(json['wifiFees']),
      minimumExtraHourRequests:
          (json['minimumExtraHourRequests'] as num?)?.toInt() ?? 0,
      minPrice: _toDouble(json['minPrice']),
      returnTripPrice: _toDouble(json['returnTripPrice']),
      returnTripPriceDiscount: _toDouble(json['returnTripPriceDiscount']),
      orginalMinPrice: _toDouble(json['orginalMinPrice']),
      maxPrice: _toDouble(json['maxPrice']),
      extraHourPrice: _toDouble(json['extraHourPrice']),
      totalWithTax: _toDouble(json['totalWithTax']),
      totalWithoutTax: _toDouble(json['totalWithoutTax']),
      taxAmount: _toDouble(json['taxAmount']),
      taxRate: _toDouble(json['taxReate']),
      discountAmount: _toDouble(json['discountAmount']),
      matchedRushHourId: (json['matchedRushHourId'] as num?)?.toInt(),
      applyRushSurcharge: json['applyRushSurcharge'] as bool? ?? false,
      graceDurationMinutes: (json['graceDurationMinutes'] as num?)?.toInt() ?? 0,
      tripDurationMinutes: (json['tripDurationMinutes'] as num?)?.toInt() ?? 0,
      rushSurchargeAmount: _toDouble(json['rushSurchargeAmount']),
      applyOffer: json['applyOffer'] as bool? ?? false,
      offerDiscount: _toDouble(json['offerDiscount']),
      offerDiscountType: (json['offerDiscoutType'] as num?)?.toInt() ?? 1,
      currencyCode: json['currencyCode'] as String?,
      displayPrices: list,
    );
  }
}

double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0.0;
