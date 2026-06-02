import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:avis_package/src/core/_core.dart';

/// Duration field with label, value text, and a slider with - / + buttons. Used for Hourly booking.
class DurationSliderWidget extends StatelessWidget {
  const DurationSliderWidget({
    super.key,
    required this.durationHours,
    required this.onChanged,
    this.minHours = 1,
    this.maxHours = 8,
    this.isByDay = false,
    /// When non-empty (e.g. from API `availableNumberOfHours` like `"4,6,10"`), only these values are selectable.
    this.allowedHours,
  });

  final int durationHours;
  final ValueChanged<int> onChanged;
  final int minHours;
  final int maxHours;
  /// When true, value is shown as "day/days" instead of "hour/hours".
  final bool isByDay;
  final List<int>? allowedHours;

  @override
  Widget build(BuildContext context) {
    final opts = allowedHours != null && allowedHours!.isNotEmpty
        ? (List<int>.from(allowedHours!)..sort())
        : null;
    final useDiscrete = opts != null;
    final currentIdx = useDiscrete
        ? (opts!.indexOf(durationHours) >= 0
            ? opts.indexOf(durationHours)
            : 0)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bordered container: only "Duration" label + value (e.g. "3 hours")
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpaces.onSides,
            horizontal: AppSpaces.medium,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.inputBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgIconWidget(
                name: 'time',
                width: 24.w,
                height: 24.w,
                color: context.colors.secondaryText,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    'Duration',
                    style: AppTextStyles.bodyXSmallBold.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                  TextWidget(
                    '$durationHours ${isByDay ? (durationHours == 1 ? 'day' : 'days') : (durationHours == 1 ? 'hour' : 'hours')}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Slider outside the border: - [slider] +
        SizedBox(height: 12.h),
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: useDiscrete
                    ? (currentIdx > 0
                        ? () => onChanged(opts![currentIdx - 1])
                        : null)
                    : (durationHours > minHours
                        ? () => onChanged(durationHours - 1)
                        : null),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  child: Icon(
                    Icons.remove,
                    size: 24.r,
                    color: useDiscrete
                        ? (currentIdx > 0
                            ? context.colors.secondaryText
                            : context.colors.tertiaryText)
                        : (durationHours > minHours
                            ? context.colors.secondaryText
                            : context.colors.tertiaryText),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: context.colors.primary,
                  inactiveTrackColor:
                      context.colors.primary.withValues(alpha: 0.2),
                  thumbColor: context.colors.primary,
                  overlayColor:
                      context.colors.primary.withValues(alpha: 0.2),
                  trackHeight: 4,
                ),
                child: useDiscrete && opts!.length > 1
                    ? Slider(
                        value: currentIdx.toDouble(),
                        min: 0,
                        max: (opts.length - 1).toDouble(),
                        divisions: opts.length - 1,
                        onChanged: (v) {
                          final i =
                              v.round().clamp(0, opts.length - 1);
                          onChanged(opts[i]);
                        },
                      )
                    : useDiscrete && opts!.length == 1
                        ? Slider(
                            value: 0,
                            min: 0,
                            max: 1,
                            divisions: null,
                            onChanged: null,
                          )
                        : Slider(
                            value: durationHours.toDouble(),
                            min: minHours.toDouble(),
                            max: maxHours.toDouble(),
                            divisions: maxHours - minHours,
                            onChanged: (v) => onChanged(v.round()),
                          ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: useDiscrete
                    ? (currentIdx < opts!.length - 1
                        ? () => onChanged(opts[currentIdx + 1])
                        : null)
                    : (durationHours < maxHours
                        ? () => onChanged(durationHours + 1)
                        : null),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  child: Icon(
                    Icons.add,
                    size: 24.r,
                    color: useDiscrete
                        ? (currentIdx < opts.length - 1
                            ? context.colors.secondaryText
                            : context.colors.tertiaryText)
                        : (durationHours < maxHours
                            ? context.colors.secondaryText
                            : context.colors.tertiaryText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
