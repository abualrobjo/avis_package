import 'package:avis_package/src/core/_core.dart';

abstract class PaymentRepository {
  Future<Result<bool?, NetworkException>> checkPaymentStatus(int tripId);
}
