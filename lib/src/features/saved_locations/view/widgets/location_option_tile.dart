import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avis_package/src/core/_core.dart'
    show SvgIconWidget, AppTextStyles, TextWidget, AppContextExtension;

class LocationOptionTile extends StatelessWidget {
  const LocationOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.hideBottomBorder = false,
    required this.onTap,
    this.onEditTap,
    this.onDeleteTap,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool hideBottomBorder;
  final VoidCallback onTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: hideBottomBorder
            ? null
            : Border(bottom: BorderSide(color: context.colors.divider)),
      ),
      child: ListTile(
        onTap: onTap,
        titleAlignment: ListTileTitleAlignment.titleHeight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: SvgIconWidget(
          name: icon,
          width: 24.w,
          height: 24.w,
          color: context.colors.primaryText,
        ),
        title: TextWidget(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.primaryText,
          ),
        ),
        subtitle: subtitle != null
            ? TextWidget(
                '$subtitle',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.secondaryText,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8.w),
            if (onEditTap != null)
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: context.colors.tertiaryText,
                  size: 20.r,
                ),
                onPressed: onEditTap,
              ),
            if (onDeleteTap != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: context.colors.error,
                  size: 20.r,
                ),
                onPressed: onDeleteTap,
              ),
          ],
        ),
      ),
    );
  }
}
