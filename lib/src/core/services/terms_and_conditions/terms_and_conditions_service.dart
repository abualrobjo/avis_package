import 'package:avis_package/avis_package.dart';

abstract class TermsAndConditionsService {
  Future<ApiResponseModel<List<TermsAndConditionsModel>>> getTermsAndConditions();
}
