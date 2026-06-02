/// Request body for GenerateCustomerLoyaltyPromoCode API.
class GenerateCustomerLoyaltyPromoCodeRequest {
  final int? createdBy;
  final int fkCustomerId;
  final int pointsAmount;

  const GenerateCustomerLoyaltyPromoCodeRequest({
    this.createdBy,
    required this.fkCustomerId,
    required this.pointsAmount,
  });

  Map<String, dynamic> toJson() => {
        'CreatedBy': createdBy ?? 0,
        'Fk_CustomerId': fkCustomerId,
        'pointsAmount': pointsAmount,
      };
}
