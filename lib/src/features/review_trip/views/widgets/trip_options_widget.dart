import 'package:flutter/material.dart';
import '../../models/review_trip_ui_model.dart';
import 'package:avis_package/src/core/_core.dart';

class TripOptionsWidget extends StatelessWidget {
  final List<ReviewTripOptionUiModel> options;

  const TripOptionsWidget({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 0,
            ), // Adjust spacing if needed
            child: Row(
              children: [
                SvgIconWidget(
                  name: option.iconName,
                  width: 19,
                  height: 19,
                  color: context.colors.tertiaryText,
                ),
                const SizedBox(width: AppSpaces.medium),
                TextWidget(
                  option.title,
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: context.colors.tertiaryText,
                  ),
                ),
                const Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: option.isEnabled,
                    onChanged: option.isSelectable ? option.onChanged : null,
                    activeThumbColor: context.colors.surface,
                    activeTrackColor: context.colors.primary,
                    inactiveThumbColor: context.colors.surface,
                    inactiveTrackColor: context.colors.surfaceDim,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
