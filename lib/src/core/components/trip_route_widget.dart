import 'package:flutter/material.dart';
import 'package:avis_package/src/core/_core.dart';

class TripRouteWidget extends StatelessWidget {
  final String pickupLabel;
  final String pickupTime;
  final String pickupLocation;
  final String dropOffLabel;
  final String? dropOffTime;
  final String dropOffLocation;
  final double horizontalPadding;

  const TripRouteWidget({
    super.key,
    required this.pickupLabel,
    required this.pickupTime,
    required this.pickupLocation,
    required this.dropOffLabel,
    this.dropOffTime,
    required this.dropOffLocation,
    this.horizontalPadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TimeLineIcon(iconName: 'dot', paddingValue: 9),
              SizedBox(
                height: AppSpaces.large,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 13.5),
                  child: CustomPaint(
                    painter: VerticalDashedBorderPainter(
                      color: context.colors.border,
                    ),
                  ),
                ),
              ),
              const _TimeLineIcon(
                iconName: 'pick-up',
                paddingValue: AppSpaces.xSmall,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextWidget(
                        pickupLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.tertiaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextWidget(
                      pickupTime,
                      style: AppTextStyles.bodyXSmallBold.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                TextWidget(
                  pickupLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: context.colors.primaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextWidget(
                        dropOffLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.tertiaryText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (dropOffTime != null)
                      TextWidget(
                        dropOffTime!,
                        style: AppTextStyles.bodyXSmallBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                TextWidget(
                  dropOffLocation,
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: context.colors.primaryText,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLineIcon extends StatelessWidget {
  const _TimeLineIcon({required this.iconName, required this.paddingValue});
  final String iconName;
  final double paddingValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      padding: EdgeInsets.all(paddingValue),
      decoration: BoxDecoration(
        color: context.colors.border,
        shape: BoxShape.circle,
      ),
      child: SvgIconWidget(name: iconName),
    );
  }
}
