import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastNotification {
  static void showSuccessNotification(BuildContext context, {String? message}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.flatColored,
      title: const Text('Success!'),
      description: Text(message ?? 'Operation completed successfully.'),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  static void showErrorNotification(BuildContext context, {String? message}) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.flatColored,
      title: const Text('Error!'),
      description: Text(message ?? 'An error occurred.'),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  static void showWarningNotification(BuildContext context, {String? message}) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.flatColored,
      title: const Text('Warning!'),
      description: Text(message ?? 'This is a warning message.'),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
