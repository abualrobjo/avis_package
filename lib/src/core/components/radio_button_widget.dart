import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../_core.dart';

class RadioButtonWidget<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final String label;
  final Color? activeColor;
  final TextStyle? textStyle;

  const RadioButtonWidget({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.activeColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (activeColor ?? context.colors.primary)
                      : context.colors.border,
                  width: 2,
                ),
                color: isSelected
                    ? (activeColor ?? context.colors.primary)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: context.colors.inverseText,
                        size: 14.w,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            TextWidget(
              label,
              style:
                  textStyle ??
                  AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.primaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
