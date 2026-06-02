import 'package:flutter/material.dart';
import '../../models/review_trip_ui_model.dart';
import 'package:avis_package/src/core/_core.dart'
    show
        AddPromoCodeBottomSheet,
        AppContextExtension,
        AppSpaces,
        AppTextStyles,
        CheckPromoCodeValidityDetails,
        RedeemLoyaltyPointsBottomSheet,
        SvgIconWidget,
        TextWidget;

class TripActionsWidget extends StatelessWidget {
  final List<ReviewTripActionUiModel> actions;
  final int tripTypeId;
  final String? appliedPromoCode;
  final void Function(String code, CheckPromoCodeValidityDetails details)?
      onPromoCodeApplied;
  final VoidCallback? onPromoCodeRemoved;
  final int? loyaltyTotalPoints;
  final int? loyaltyMaxRedeemablePoints;
  final int? loyaltyMinRedeemablePoints;
  final String? appliedLoyaltyCode;
  final void Function(String code)? onLoyaltyRedeemed;
  final VoidCallback? onLoyaltyRemoved;

  const TripActionsWidget({
    super.key,
    required this.actions,
    required this.tripTypeId,
    this.appliedPromoCode,
    this.onPromoCodeApplied,
    this.onPromoCodeRemoved,
    this.loyaltyTotalPoints,
    this.loyaltyMaxRedeemablePoints,
    this.loyaltyMinRedeemablePoints,
    this.appliedLoyaltyCode,
    this.onLoyaltyRedeemed,
    this.onLoyaltyRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          final isPromoCode = action.title.toLowerCase() == 'promo code';
          final isLoyaltyPoints = action.title.toLowerCase() == 'loyalty points';
          final hasPromoApplied = isPromoCode &&
              appliedPromoCode != null &&
              appliedPromoCode!.isNotEmpty;
          final hasLoyaltyApplied = isLoyaltyPoints &&
              appliedLoyaltyCode != null &&
              appliedLoyaltyCode!.isNotEmpty;
          void handleActionTap() {
            if (isPromoCode) {
              if (!hasPromoApplied) {
                AddPromoCodeBottomSheet.show(
                  context,
                  tripTypeId: tripTypeId,
                  onPromoApplied: onPromoCodeApplied,
                );
              }
            } else if (isLoyaltyPoints) {
              if (!hasLoyaltyApplied) {
                RedeemLoyaltyPointsBottomSheet.show(
                  context,
                  totalLoyalityPoints: loyaltyTotalPoints,
                  maxRedeemablePoints: loyaltyMaxRedeemablePoints,
                  minimumPointsValueForTransfer: loyaltyMinRedeemablePoints,
                  onRedeemed: onLoyaltyRedeemed,
                );
              }
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < actions.length - 1 ? AppSpaces.large : 0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: handleActionTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          action.title,
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: context.colors.tertiaryText,
                          ),
                        ),
                        if (hasPromoApplied) ...[
                          const SizedBox(height: 4),
                          TextWidget(
                            appliedPromoCode!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                        if (hasLoyaltyApplied) ...[
                          const SizedBox(height: 4),
                          TextWidget(
                            appliedLoyaltyCode!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.colors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isPromoCode && hasPromoApplied)
                  GestureDetector(
                    onTap: onPromoCodeRemoved,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        size: 21,
                        color: context.colors.tertiaryText,
                      ),
                    ),
                  )
                else if (isLoyaltyPoints && hasLoyaltyApplied)
                  GestureDetector(
                    onTap: onLoyaltyRemoved,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        size: 21,
                        color: context.colors.tertiaryText,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: handleActionTap,
                    child: SvgIconWidget(
                      name: 'arrow-right',
                      width: 21,
                      height: 21,
                      color: context.colors.tertiaryText,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
