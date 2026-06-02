/// GetCustomerInfo API responseDetails (single object).
class CustomerInfoModel {
  final int clientbranchId;
  final String? customerPrimaryName;
  final String? customerSecondaryname;
  final String? countryCode;
  final String? customerPhoneNumber;
  final String? customerEmail;
  final bool belongsToCompany;
  final String? countryPrimaryName;
  final String? nationalitySecondaryName;
  final bool isNameMasking;
  final bool isPhoneMasking;
  final int totalLoyalityPoints;
  final int maxRedeemablePoints;
  final int minimumPointsValueForTransfer;
  final int? airlineId;
  final String? frequentFlyerNumber;

  const CustomerInfoModel({
    required this.clientbranchId,
    this.customerPrimaryName,
    this.customerSecondaryname,
    this.countryCode,
    this.customerPhoneNumber,
    this.customerEmail,
    this.belongsToCompany = false,
    this.countryPrimaryName,
    this.nationalitySecondaryName,
    this.isNameMasking = false,
    this.isPhoneMasking = false,
    this.totalLoyalityPoints = 0,
    this.maxRedeemablePoints = 0,
    this.minimumPointsValueForTransfer = 0,
    this.airlineId,
    this.frequentFlyerNumber,
  });

  factory CustomerInfoModel.fromJson(Map<String, dynamic> json) {
    return CustomerInfoModel(
      clientbranchId: (json['clientbranchId'] as num?)?.toInt() ?? 0,
      customerPrimaryName: json['customerPrimaryName'] as String?,
      customerSecondaryname: json['customerSecondaryname'] as String?,
      countryCode: json['countryCode'] as String?,
      customerPhoneNumber: json['customerPhoneNumber'] as String?,
      customerEmail: json['customerEmail'] as String?,
      belongsToCompany: json['belongsToCompany'] as bool? ?? false,
      countryPrimaryName: json['countryPrimaryName'] as String?,
      nationalitySecondaryName: json['nationalitySecondaryName'] as String?,
      isNameMasking: json['isNameMasking'] as bool? ?? false,
      isPhoneMasking: json['isPhoneMasking'] as bool? ?? false,
      totalLoyalityPoints: (json['totalLoyalityPoints'] as num?)?.toInt() ?? 0,
      maxRedeemablePoints: (json['maxRedeemablePoints'] as num?)?.toInt() ?? 0,
      minimumPointsValueForTransfer:
          (json['minimumPointsValueForTransfer'] as num?)?.toInt() ?? 0,
      airlineId: (json['airlineId'] as num?)?.toInt(),
      frequentFlyerNumber: json['frequentFlyerNumber'] as String?,
    );
  }

  /// Empty instance for API failure / no data.
  static const CustomerInfoModel empty = CustomerInfoModel(clientbranchId: 0);
}
