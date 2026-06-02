import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../_core.dart';

class PickupDropOffComponent extends StatelessWidget {
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? pickupTime;
  final String? dropoffTime;
  final bool showPickupIcon;
  final bool showDropoffIcon;

  const PickupDropOffComponent({
    super.key,
    this.pickupLocation,
    this.dropoffLocation,
    this.pickupTime,
    this.dropoffTime,
    this.showPickupIcon = true,
    this.showDropoffIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.colors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icons Column with Dotted Line
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pickup Icon
              if (showPickupIcon) _PickupIcon(),
              // Dotted Connecting Line
              if (showPickupIcon && showDropoffIcon)
                Container(
                  width: 1,
                  height: 40.w,
                  margin: EdgeInsets.symmetric(vertical: 4.w),
                  child: CustomPaint(
                    painter: _DottedLinePainter(color: context.colors.border),
                  ),
                ),

              // Dropoff Icon
              if (showDropoffIcon) _DropoffIcon(),
            ],
          ),

          SizedBox(width: 12.w),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pickup Section
                if (pickupLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        pickupLocation!,
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (pickupTime != null) ...[
                        SizedBox(height: 4.w),
                        TextWidget(
                          pickupTime!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 12),
                Divider(height: 1, color: context.colors.border, thickness: 1),
                const SizedBox(height: 12),

                // Dropoff Section
                if (dropoffLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        dropoffLocation!,
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dropoffTime != null) ...[
                        SizedBox(height: 4.w),
                        TextWidget(
                          dropoffTime!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Pickup Icon: Solid orange circle inside translucent orange circle
class _PickupIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primary.withValues(alpha: 0.15),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}

// Dropoff Icon: Location SVG icon
class _DropoffIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgIconWidget(
      name: 'location',
      width: 24.w,
      height: 24.w,
      color: context.colors.primary,
    );
  }
}

// Custom painter for dotted vertical line
class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashHeight = 3.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      color != oldDelegate.color;
}
