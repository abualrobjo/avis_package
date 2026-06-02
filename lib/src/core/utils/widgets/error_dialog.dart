import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart'
    show AppButton, AppCornerRadius, AppSpaces, TextWidget;

Future<dynamic> errorDialog(BuildContext context, {required String message}) {
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppCornerRadius.small),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade100,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpaces.medium),
              TextWidget('Error', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpaces.onSides),
              TextWidget(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpaces.medium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppButton.tertiary(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: 'Close',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
