import 'package:avis_package/src/core/_core.dart';

abstract class PaymentService {
  Future<Result<bool?, NetworkException>> checkPaymentStatus(int tripId);
}
