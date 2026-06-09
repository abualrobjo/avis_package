/// One item from displayPrices array in GetVehicleClassesPriceByTripType response.
class VehicleClassDisplayPrice {
  final double price;
  final double taxValue;
  final double total;
  final String currencyCode;

  const VehicleClassDisplayPrice({
    required this.price,
    required this.taxValue,
    required this.total,
    required this.currencyCode,
  });

  factory VehicleClassDisplayPrice.fromJson(Map<String, dynamic> json) {
    final code = json['currencyCode'] as String?;
    return VehicleClassDisplayPrice(
      price: (json['price'] as num?)?.toDouble() ?? 0,
      taxValue: (json['taxValue'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      currencyCode: code != null && code.isNotEmpty ? code.toUpperCase() : 'USD',
    );
  }
}

/// One item from GetVehicleClassesPriceByTripType API responseDetails.
class VehicleClassPriceModel {
  final int classId;
  final String name;
  final String? image;
  final String? classMiniDesc;
  final double price;
  final double taxValue;
  final double total;
  final double tax;
  final int passengersNo;
  final int suitcasesNo;
  final List<VehicleClassDisplayPrice> displayPrices;

  const VehicleClassPriceModel({
    required this.classId,
    required this.name,
    this.image,
    this.classMiniDesc,
    required this.price,
    required this.taxValue,
    required this.total,
    required this.tax,
    required this.passengersNo,
    required this.suitcasesNo,
    this.displayPrices = const [],
  });

  factory VehicleClassPriceModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['displayPrices'] as List<dynamic>?;
    final displayPrices = rawList != null
        ? rawList
            .map(
              (e) => VehicleClassDisplayPrice.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : <VehicleClassDisplayPrice>[];

    return VehicleClassPriceModel(
      classId: (json['classId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      classMiniDesc: json['classMiniDesc'] as String?,
      price: (json['price'] as num).toDouble(),
      taxValue: (json['taxValue'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      passengersNo: (json['passengersNo'] as num?)?.toInt() ?? 0,
      suitcasesNo: (json['suitcasesNo'] as num?)?.toInt() ?? 0,
      displayPrices: displayPrices,
    );
  }

  VehicleClassDisplayPrice? priceForCurrency(String currencyCode) {
    if (displayPrices.isEmpty) return null;
    final normalized = currencyCode.toUpperCase();
    for (final item in displayPrices) {
      if (item.currencyCode.toUpperCase() == normalized) return item;
    }
    return null;
  }

  VehicleClassPriceModel withCurrency(String currencyCode) {
    final displayPrice = priceForCurrency(currencyCode);
    if (displayPrice == null) return this;
    return VehicleClassPriceModel(
      classId: classId,
      name: name,
      image: image,
      classMiniDesc: classMiniDesc,
      price: displayPrice.price,
      taxValue: displayPrice.taxValue,
      total: displayPrice.total,
      tax: displayPrice.taxValue,
      passengersNo: passengersNo,
      suitcasesNo: suitcasesNo,
      displayPrices: displayPrices,
    );
  }
}
