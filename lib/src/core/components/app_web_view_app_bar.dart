import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

/// Compact, fixed-height app bar for in-app WebViews (payment, PDFs, etc.).
class AppWebViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppWebViewAppBar({
    super.key,
    required this.title,
    this.isLoading = false,
  });

  final String title;
  final bool isLoading;

  static const double _toolbarHeight = kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        _toolbarHeight + (isLoading ? 2 : 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: _toolbarHeight,
      leadingWidth: 56,
      backgroundColor: context.colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: const BackArrowWidget(),
      title: MediaQuery.withNoTextScaling(
        child: TextWidget(
          title,
          style: AppTextStyles.bodyLargeBold.copyWith(
            color: context.colors.primaryText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottom: isLoading
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(minHeight: 2),
            )
          : null,
    );
  }
}
