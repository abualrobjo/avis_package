import 'package:avis_package/src/core/_core.dart';

abstract class CustomerInfoService {
  Future<ApiResponseModel<CustomerInfoModel>> getCustomerInfo(int customerId);
}
