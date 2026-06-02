import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../_core.dart';

enum TripStatus { completed, cancelled, pending, active }

class TripItemComponent extends StatelessWidget {
  final String destination;
  final String dateTime;
  final TripStatus status;
  final String? carImageUrl;
  final VoidCallback? onTap;

  const TripItemComponent({
    super.key,
    required this.destination,
    required this.dateTime,
    required this.status,
    this.carImageUrl,
    this.onTap,
  });

  Color _getStatusColor(BuildContext context) {
    switch (status) {
      case TripStatus.completed:
        return context.colors.success;
      case TripStatus.active:
        return context.colors.success;
      case TripStatus.cancelled:
        return context.colors.error;
      case TripStatus.pending:
        return context.colors.warning;
    }
  }

  String _getStatusText() {
    switch (status) {
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
      case TripStatus.pending:
        return 'Pending';
      case TripStatus.active:
        return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Car Image
            Container(
              width: 66.w,
              height: 54.w,
              decoration: BoxDecoration(
                color: context.colors.inputBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: carImageUrl != null && carImageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: NetworkImageWidget(url: carImageUrl!),
                    )
                  : Icon(
                      Icons.directions_car,
                      size: 40.w,
                      color: context.colors.tertiaryText,
                    ),
            ),

            SizedBox(width: 12.w),

            // Trip Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(destination, style: AppTextStyles.bodyMediumBold),
                  SizedBox(height: 4.w),
                  TextWidget(
                    dateTime,
                    style: AppTextStyles.bodyXSmallBold.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 4.w),
                  TextWidget(
                    _getStatusText(),
                    style: AppTextStyles.bodyXSmall.copyWith(
                      color: _getStatusColor(context),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Navigation Arrow
            SvgIconWidget(
              name: 'arrow-with-circel',
              width: 32.w,
              height: 32.w,
              color: context.colors.tertiaryText,
            ),
          ],
        ),
      ),
    );
  }
}
