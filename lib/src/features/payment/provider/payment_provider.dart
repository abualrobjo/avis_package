import 'package:flutter/material.dart';

import 'package:avis_package/src/features/payment/repository/payment_repository.dart';

enum PaymentStatus {
  initial,
  loading,
  success,
  failure,
}

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  PaymentProvider(this._paymentRepository);

  PaymentStatus _paymentStatus = PaymentStatus.initial;

  PaymentStatus get paymentStatus => _paymentStatus;

  /// After [PaymentScreen] closes with success (success redirect URL), do not call
  /// [CheckIFChauffeurServiceRequestPaid]; the WebView outcome is treated as paid.
  void markPaidConfirmedFromWebView() {
    _paymentStatus = PaymentStatus.success;
    notifyListeners();
  }

  Future<void> checkPaymentStatus(int tripId) async {
    _paymentStatus = PaymentStatus.loading;
    notifyListeners();

    final result = await _paymentRepository.checkPaymentStatus(tripId);

    result.when(
      failure: (failure) {
        _paymentStatus = PaymentStatus.failure;
        notifyListeners();
      },
      success: (success) {
        if (success == true) {
          _paymentStatus = PaymentStatus.success;
        } else {
          _paymentStatus = PaymentStatus.failure;
        }
        notifyListeners();
      },
    );
  }
}
