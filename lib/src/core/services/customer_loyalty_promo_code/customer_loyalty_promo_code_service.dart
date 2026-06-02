import 'package:avis_package/src/core/_core.dart';

abstract class CustomerLoyaltyPromoCodeService {
  /// Redeems loyalty points and returns the generated promo code (responseDetails string).
  Future<ApiResponseModel<String>> generateCustomerLoyaltyPromoCode(
    GenerateCustomerLoyaltyPromoCodeRequest request,
  );
}
