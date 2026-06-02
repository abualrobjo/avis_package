import 'package:avis_package/src/core/_core.dart';

abstract class ChauffeurServicePricesService {
  Future<ApiResponseModel<ChauffeurServicePricesResponseDetails>>
      getChauffeurServicePricesByRequest(
    ChauffeurServicePricesByRequestBody body,
  );
}
