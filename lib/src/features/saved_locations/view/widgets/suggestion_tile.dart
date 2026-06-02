import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart'
    show SvgIconWidget, AppTextStyles, TextWidget, AppContextExtension;

class SuggestionTile extends StatelessWidget {
  const SuggestionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String? distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,

              child: Column(
                children: [
                  SvgIconWidget(
                    name: 'location-favourite',
                    width: 24.w,
                    height: 24.w,
                    color: context.colors.primary,
                  ),
                  if (distance != null && distance!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    TextWidget(
                      distance!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.secondaryText,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
         Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  TextWidget(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
