import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._paymentService);

  final PaymentService _paymentService;

  @override
  Future<Result<bool?, NetworkException>> checkPaymentStatus(int tripId) async {
    return await _paymentService.checkPaymentStatus(tripId);
  }
}
