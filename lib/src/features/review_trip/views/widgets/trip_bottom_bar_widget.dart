import 'package:flutter/material.dart';
import '../../models/review_trip_ui_model.dart';
import 'package:avis_package/src/core/_core.dart'
    show AppContextExtension, AppTextStyles, TextWidget, AppButton, AppSpaces;

class TripBottomBarWidget extends StatelessWidget {
  final ReviewTripPriceUiModel price;
  final String buttonText;
  final bool isIndividual;
  final VoidCallback? onConfirm;

  const TripBottomBarWidget({
    super.key,
    required this.price,
    required this.buttonText,
    required this.isIndividual,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withValues(alpha: 0.05),
            blurRadius: 5.4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: !isIndividual
          ? const EdgeInsets.all(44)
          : const EdgeInsets.symmetric(
              horizontal: AppSpaces.large,
              vertical: AppSpaces.medium,
            ),
      child: SafeArea(
        top: false,
        bottom: isIndividual,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isIndividual)
              TextWidget(
                price.formattedPrice,
                style: AppTextStyles.h2.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
            if (isIndividual)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  TextWidget(
                    price.label,
                    style: AppTextStyles.bodyXSmall.copyWith(
                      color: context.colors.tertiaryText,
                    ),
                  ),
                  if (price.formattedTaxAmount != null)
                    TextWidget(
                      price.formattedTaxAmount!,
                      style: AppTextStyles.bodyXSmallBold.copyWith(
                        color: context.colors.tertiaryText,
                      ),
                    ),
                ],
              ),
            if (isIndividual) const SizedBox(height: AppSpaces.onSides),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: !isIndividual ? 0 : 20),
              child: AppButton.primary(onPressed: onConfirm, text: buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
