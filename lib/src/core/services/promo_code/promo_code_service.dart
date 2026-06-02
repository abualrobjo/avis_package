import 'package:avis_package/src/core/_core.dart';

abstract class PromoCodeService {
  Future<ApiResponseModel<CheckPromoCodeValidityDetails>> checkPromoCodeValidity(
    CheckPromoCodeValidityRequest request,
  );
}
