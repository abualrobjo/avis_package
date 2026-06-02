import 'package:avis_package/src/core/_core.dart';
import 'payment_service.dart';

class PaymentServiceImpl implements PaymentService {
  @override
  Future<Result<bool?, NetworkException>> checkPaymentStatus(int tripId) async {
    return await dioClient.get(
      endpoint: ApiEndpoints.checkPaymentStatus,
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          return raw as bool?;
        });
        return response.data;
      },
    );
  }
}
