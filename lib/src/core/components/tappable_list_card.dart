import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart' show AppContextExtension, AppCornerRadius;

/// Reusable tappable card for list items (e.g. Inspection list, Trip History).
/// Use [child] for main content and optional [trailing] for right-side widget (e.g. status + arrow).
class TappableListCard extends StatelessWidget {
  const TappableListCard({
    super.key,
    required this.child,
    this.onTap,
    this.trailing,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: context.colors.cardBackground,
            border: Border.all(color: context.colors.border),
            borderRadius: BorderRadius.circular(AppCornerRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: trailing != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: child),
                    trailing!,
                  ],
                )
              : child,
        ),
      ),
    );
  }
}
