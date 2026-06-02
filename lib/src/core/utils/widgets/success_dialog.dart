import 'package:avis_package/src/core/components/svg_icon_widget.dart';
import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart'
    show TextWidget, AppSpaces, AppCornerRadius, AppButton;

Future<dynamic> successDialog(
  BuildContext context, {
  required String message,
  required void Function()? onPressed,
}) {
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: const SvgIconWidget(
                  name: 'checkmark-circle',
                  width: 78,
                  height: 78,
                ),
              ),
              const SizedBox(height: AppSpaces.medium),
              TextWidget('Congratulations!', style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpaces.onSides),
              TextWidget(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpaces.medium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppButton.primary(onPressed: onPressed, text: 'Thanks'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
