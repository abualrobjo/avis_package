import 'package:flutter/material.dart';
import '../../models/review_trip_ui_model.dart';
import 'package:avis_package/src/core/_core.dart'
    show
        NetworkImageWidget,
        AppContextExtension,
        AppTextStyles,
        SvgIconWidget,
        TextWidget;

class TripHeaderWidget extends StatelessWidget {
  final ReviewTripVehicleUiModel vehicle;
  final ReviewTripPriceUiModel price;
  final bool isIndividual;

  const TripHeaderWidget({
    super.key,
    required this.vehicle,
    required this.price,
    required this.isIndividual,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(21, 22, 0, 15),
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: [
              NetworkImageWidget(
                url: vehicle.imageUrl,
                width: 159,
                height: 76,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicle.name,
                        style: AppTextStyles.bodyLargeBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 12),
                      SvgIconWidget(
                        name: 'profile',
                        color: context.colors.primaryText,
                        width: 16,
                        height: 16,
                      ),
                      TextWidget(
                        vehicle.passengerCapacity.toString(),
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SvgIconWidget(
                        name: 'bag',
                        color: context.colors.primaryText,
                        width: 16,
                        height: 16,
                      ),
                      TextWidget(
                        vehicle.luggageCapacity.toString(),
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  if (isIndividual) const SizedBox(height: 10),
                  if (isIndividual)
                    TextWidget(
                      price.formattedPrice,
                      style: AppTextStyles.bodyLargeBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
