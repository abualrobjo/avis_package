/// Request body for CheckPromoCodeValidity API.
class CheckPromoCodeValidityRequest {
  final String promoCode;
  final int companyId;
  final int applicableApplication;
  final int branchId;
  final int lineOfBusiness;
  final int tripTypeId;

  const CheckPromoCodeValidityRequest({
    required this.promoCode,
    required this.companyId,
    required this.tripTypeId,
    this.applicableApplication = 2,
    required this.branchId,
    this.lineOfBusiness = 5,
  });

  Map<String, dynamic> toJson() => {
        'PromoCode': promoCode,
        'CompanyId': companyId,
        'ApplicableApplication': applicableApplication,
        'BranchId': branchId,
        'LineOfBusiness': lineOfBusiness,
        'TripTypeId': tripTypeId,
      };
}
