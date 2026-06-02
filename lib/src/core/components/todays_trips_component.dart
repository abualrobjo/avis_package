import 'package:avis_package/src/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../_core.dart';

class TodaysTripsComponent extends StatelessWidget {
  final List<TripItemData> trips;
  final VoidCallback? onViewAllTap;

  const TodaysTripsComponent({
    super.key,
    required this.trips,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget(
              LocaleKeys.common_trips_todays_trips.tr(),
              style: AppTextStyles.bodyLarge,
            ),
            InkWell(
              onTap: onViewAllTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    LocaleKeys.common_trips_view_all.tr(),
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.w,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16.w),

        // Trip List
        ...trips.map(
          (trip) => TripItemComponent(
            destination: trip.destination,
            dateTime: trip.dateTime,
            status: trip.status,
            carImageUrl: trip.carImageUrl,
            onTap: trip.onTap,
          ),
        ),
      ],
    );
  }
}

class TripItemData {
  final String destination;
  final String dateTime;
  final TripStatus status;
  final String? carImageUrl;
  final VoidCallback? onTap;

  TripItemData({
    required this.destination,
    required this.dateTime,
    required this.status,
    this.carImageUrl,
    this.onTap,
  });
}
