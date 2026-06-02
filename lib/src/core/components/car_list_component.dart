import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarListComponent extends StatelessWidget {
  final double height;
  final AvailableVehicleModel data;
  final bool isSelected;

  const CarListComponent({
    required this.data,
    this.height = 126,
    this.isSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122.w,
      height: height.w,
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.warningBackground
            : context.colors.secondaryContainer,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppCornerRadius.medium),
        ),
        border: isSelected
            ? Border.all(color: context.colors.primary, width: 1)
            : null,
      ),
      padding: EdgeInsets.all(isSelected ? 9.r : 10.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget(
            data.manufacturerLocalized(context),
            style: AppTextStyles.bodySmallBold,
          ),
          // Center(child: NetworkImageWidget(url: '')),
          Center(
            child: SizedBox(
              width: 100.w,
              height: 80.w,
              child: Image.asset(
                'assets/images/av_car.png',
                package: 'avis_package',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.directions_car,
                  size: 40.w,
                  color: context.colors.tertiaryText,
                ),
              ),
            ),
          ),

          Row(
            children: [
              TextWidget(data.plateNumber, style: AppTextStyles.labelBold),
              SizedBox(width: 5.w),
              TextWidget(
                data.isLastUsed == 1
                    ? '. ${LocaleKeys.home_last_used.tr()}'
                    : '',
                style: AppTextStyles.labelBold.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CarListComponentModel {
  String name;
  String imageUrl;
  String model;
  String lastUse;
  CarListComponentModel({
    required this.name,
    required this.imageUrl,
    required this.model,
    required this.lastUse,
  });
}
