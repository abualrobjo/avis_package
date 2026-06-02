import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';

/// Tappable container that shows a location label + value (or placeholder). Opens map picker on tap.
class LocationTapContainer extends StatelessWidget {
  const LocationTapContainer({
    super.key,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.prefixIcon,
    required this.onTap,
  });

  final String label;
  final String value;
  final String placeholder;
  final Widget prefixIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpaces.onSides,
            horizontal: AppSpaces.medium,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.inputBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: hasValue
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWidget(
                      label,
                      style: AppTextStyles.bodySmallBold.copyWith(
                        color: context.colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        prefixIcon,
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextWidget(
                            value,
                            style: AppTextStyles.bodyMediumBold.copyWith(
                              color: context.colors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    prefixIcon,
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextWidget(
                        placeholder,
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: context.colors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
