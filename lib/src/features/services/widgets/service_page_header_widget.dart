
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avis_package/src/core/_core.dart';

class ServicePageHeaderWidget extends StatelessWidget {
  final String customerName;
  const ServicePageHeaderWidget({
    super.key,
    required this.customerName
  });


  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextWidget(
              customerName,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.grey400,
              ),
            ),
            SizedBox(height: 8.w),
            TextWidget(
              'Where do you will go?',
              style: AppTextStyles.h1.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
