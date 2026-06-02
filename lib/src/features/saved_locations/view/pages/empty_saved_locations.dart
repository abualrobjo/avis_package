import 'package:flutter/material.dart';
import 'package:avis_package/src/core/_core.dart'
    show SvgIconWidget, AppButton, AppContextExtension, AppTextStyles;

class EmptySavedLocations extends StatelessWidget {
  const EmptySavedLocations({super.key, required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const SvgIconWidget(name: 'save_location', width: 228, height: 228),
          const SizedBox(height: 11),
          Text(
            'No Saved Locations Yet',
            style: AppTextStyles.h1.copyWith(color: context.colors.divider),
          ),
          const SizedBox(height: 8),
          Text(
            'Save Home and work for faster bookings',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMediumBold.copyWith(
              color: context.colors.divider,
            ),
          ),
          const Spacer(),
          AppButton.secondary(
            text: 'Add your First Location',
            onPressed: onAddPressed,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
