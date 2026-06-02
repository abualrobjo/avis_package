import 'package:flutter/material.dart';

import 'package:avis_package/src/core/data/models/customer_trip_by_id_model.dart';
import 'package:avis_package/src/core/_core.dart'
    show
        AppSpaces,
        AppTextStyles,
        AppContextExtension,
        AppCornerRadius,
        NetworkImageWidget,
        CustomerTripByIdModelExtension,
        SvgIconWidget,
        TextWidget;

class MapCarInfoCard extends StatelessWidget {
  const MapCarInfoCard({super.key, required this.tripInfo});

  final CustomerTripByIdModel tripInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpaces.medium,
        horizontal: AppSpaces.onSides,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextWidget(
                    'Trip ID',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpaces.xSmall),
                  TextWidget(
                    '${tripInfo.tripId}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpaces.small),
              Text(tripInfo.plateNumber ?? '', style: AppTextStyles.h2),
              const SizedBox(height: AppSpaces.small),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:
                          tripInfo.colorCode != null &&
                              tripInfo.colorCode!.startsWith('#')
                          ? Color(
                              int.parse(
                                tripInfo.colorCode!.replaceAll('#', '0xFF'),
                              ),
                            )
                          : null,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpaces.xSmall),
                  Text(
                    '${tripInfo.manufacturerPrimaryName ?? ''} - ${tripInfo.colorPrimaryName ?? ''}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpaces.small),
              Row(
                children: [
                  SvgIconWidget(
                    name: 'account',
                    width: 18,
                    height: 18,
                    color: context.colors.secondaryText,
                  ),
                  const SizedBox(width: AppSpaces.xSmall),
                  TextWidget(
                    '${tripInfo.passengersNo ?? 0}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpaces.medium),
                  SvgIconWidget(
                    name: 'bag',
                    width: 18,
                    height: 18,
                    color: context.colors.secondaryText,
                  ),
                  const SizedBox(width: AppSpaces.xSmall),
                  TextWidget(
                    '${tripInfo.suitcasesNo ?? 0}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 102,
            height: 49,
            child: Stack(
              children: [
                if (tripInfo.vehicleClassImage != null)
                  NetworkImageWidget(
                    url: tripInfo.vehicleClassImage!,
                    width: 102,
                    height: 49,
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 68,
                    height: 18,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(
                        AppCornerRadius.absolute,
                      ),
                    ),
                    child: Text(
                      tripInfo.vehicleClassLocalized(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
