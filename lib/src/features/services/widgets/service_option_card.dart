import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';

import 'vehicle_option.dart';

class ServiceOptionCard extends StatelessWidget {
  const ServiceOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final VehicleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
        child: Container(
          width: 140.w,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.warningBackground
                : context.colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
            border: isSelected
                ? Border.all(color: context.colors.primary, width: 1)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                option.name,
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              SizedBox(height: 4.w),
              Row(
                children: [
                  SvgIconWidget(
                    name: 'account',
                    width: 12.w,
                    height: 12.w,
                    color: context.colors.secondaryText,
                  ),
                  SizedBox(width: 4.w),
                  TextWidget('${option.passengers}', style: AppTextStyles.labelBold),
                  SizedBox(width: 8.w),
                  SvgIconWidget(
                    name: 'bag',
                    width: 12.w,
                    height: 12.w,
                    color: context.colors.secondaryText,
                  ),
                  SizedBox(width: 4.w),
                  TextWidget('${option.bags}', style: AppTextStyles.labelBold),
                ],
              ),
              Center(
                child: SizedBox(
                  width: 100.w,
                  height: 60.w,
                  child:NetworkImageWidget(url: option.imagePath,fit: BoxFit.contain,),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    option.price,
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  TextWidget(
                    option.eta,
                    style: AppTextStyles.labelBold.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
