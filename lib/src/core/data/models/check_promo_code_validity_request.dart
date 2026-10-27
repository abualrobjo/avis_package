/// Request body for CheckPromoCodeValidity API.
class CheckPromoCodeValidityRequest {
  final String promoCode;
  final int companyId;
  final int applicableApplication;
  final int branchId;
  final int lineOfBusiness;
  final int tripTypeId;
  final String pickupDateTime;
  final int customerId;
  final int classId;

  const CheckPromoCodeValidityRequest({
    required this.promoCode,
    required this.companyId,
    required this.tripTypeId,
    required this.pickupDateTime,
    this.applicableApplication = 2,
    required this.branchId,
    this.lineOfBusiness = 5,
    required this.customerId,
    required this.classId,
  });

  Map<String, dynamic> toJson() => {
        'PromoCode': promoCode,
        'CompanyId': companyId,
        'ApplicableApplication': applicableApplication,
        'BranchId': branchId,
        'LineOfBusiness': lineOfBusiness,
        'TripTypeId': tripTypeId,
        'PickupDateTime': pickupDateTime,
        'CustomerId': customerId,
        'ClassId': classId,
      };
}
