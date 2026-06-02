import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';

import 'location_tap_container.dart';
import 'from_location_icon.dart';

/// From and optional Drop-off location containers with an optional swap button.
/// For Hourly, set [showDropOffAndSwap] to false to show only From and hide the orange swap circle.
class LocationFieldsWithSwapWidget extends StatelessWidget {
  const LocationFieldsWithSwapWidget({
    super.key,
    required this.fromPlaceName,
    required this.dropOffPlaceName,
    required this.onFromTap,
    required this.onDropOffTap,
    required this.onSwap,
    this.showDropOffAndSwap = true,
  });

  final String fromPlaceName;
  final String dropOffPlaceName;
  final VoidCallback onFromTap;
  final VoidCallback onDropOffTap;
  final VoidCallback onSwap;
  /// When false (e.g. Hourly), only From is shown and the swap button is hidden.
  final bool showDropOffAndSwap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LocationTapContainer(
              label: 'From',
              value: fromPlaceName,
              placeholder: 'Pickup location',
              prefixIcon: FromLocationIcon(colors: context.colors),
              onTap: onFromTap,
            ),
            if (showDropOffAndSwap) ...[
              SizedBox(height: 8.h),
              LocationTapContainer(
                label: 'Drop-off',
                value: dropOffPlaceName,
                placeholder: 'Drop-off location?',
                prefixIcon: SvgIconWidget(
                  name: 'location',
                  width: 20.w,
                  height: 20.w,
                  color: context.colors.tertiaryText,
                ),
                onTap: onDropOffTap,
              ),
            ],
          ],
        ),
        if (showDropOffAndSwap)
          Positioned(
            right: 0,
            top: 10,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSwap,
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgIconWidget(
                        name: 'arrow-up-down',
                        width: 20.r,
                        height: 20.r,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
