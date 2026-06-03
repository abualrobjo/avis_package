import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';

/// Simple reason option for low rating (no lookup API).
class RateReasonOption {
  const RateReasonOption(this.id, this.label);
  final int id;
  final String label;
}

/// Static options for "reason for low rating" dropdown.
const List<RateReasonOption> kDefaultRateReasons = [
  RateReasonOption(1, 'Other'),
  RateReasonOption(2, 'Late'),
  RateReasonOption(3, 'Rude'),
  RateReasonOption(4, 'Vehicle condition'),
  RateReasonOption(5, 'Unsafe driving'),
];

class RatingBottomSheet extends StatefulWidget {
  const RatingBottomSheet({
    super.key,
    required this.tripId,
    required this.driverId,
    required this.customerId,
    this.title,
    this.submitButtonText,
    this.reasonOptions = kDefaultRateReasons,
  });

  final int tripId;
  final int driverId;
  final int customerId;
  final String? title;
  final String? submitButtonText;
  final List<RateReasonOption>? reasonOptions;

  static Future<void> show(
    BuildContext context, {
    required int tripId,
    required int driverId,
    required int customerId,
    String? title,
    List<RateReasonOption>? reasonOptions,
    String? submitButtonText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => sl<RatingProvider>(),
        child: RatingBottomSheet(
          tripId: tripId,
          driverId: driverId,
          customerId: customerId,
          title: title,
          reasonOptions: reasonOptions ?? kDefaultRateReasons,
          submitButtonText: submitButtonText,
        ),
      ),
    );
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  final _reviewController = TextEditingController();

  int _rating = 3;
  RateReasonOption? _selectedReason;
  bool _markAsFavorite = false;

  String get title =>
      widget.title ?? avisTr(LocaleKeys.common_rate_title, context: context);
  String get submitButtonText =>
      widget.submitButtonText ??
      avisTr(LocaleKeys.common_submit, context: context);

  String _ratingLabel(BuildContext context) {
    final key = switch (_rating) {
      1 => LocaleKeys.common_poor,
      2 => LocaleKeys.common_could_be_better,
      3 => LocaleKeys.common_good,
      4 => LocaleKeys.common_average,
      _ => LocaleKeys.common_great_experience,
    };
    return avisTr(key, context: context);
  }

  Future<void> _submit() async {
    final rootContext = Navigator.of(context).context;
    final provider = context.read<RatingProvider>();

    final result = await provider.submitRating(
      tripId: widget.tripId,
      driverId: widget.driverId,
      customerId: widget.customerId,
      rateValue: _rating,
      comment: _reviewController.text.trim(),
      lowRateReason: _selectedReason?.id,
      markAsFavorite: _markAsFavorite,
    );

    if (result) {
      if (mounted) {
        Navigator.pop(context);
      }
      if (rootContext.mounted) {
        await SuccessBottomSheet.show(rootContext);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              avisTr(
                _markAsFavorite
                    ? LocaleKeys.common_failed_to_mark_favourite_driver
                    : LocaleKeys.common_failed_to_rate_customer,
                context: context,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reasons = widget.reasonOptions ?? kDefaultRateReasons;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppCornerRadius.large),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(child: BottomSheetHandle()),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextWidget(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h3.copyWith(
                      color: context.colors.primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 1, thickness: 1, color: context.colors.divider),
                const SizedBox(height: 24),
                Center(
                  child: TextWidget(
                    avisTr(
                      LocaleKeys.common_your_overall_rating,
                      context: context,
                    ),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _StarRating(onChanged: (v) => setState(() => _rating = v)),
                const SizedBox(height: 8),
                TextWidget(
                  _ratingLabel(context),
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
                const SizedBox(height: 20),
                AppCustomDropdown<RateReasonOption>(
                  items: reasons,
                  title: '',
                  hintText: avisTr(
                    LocaleKeys.common_please_select_a_reason,
                    context: context,
                  ),
                  selectedTextStyle: _selectedReason != null
                      ? AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.primaryText,
                        )
                      : AppTextStyles.bodySmall.copyWith(
                          color: context.colors.secondaryText,
                        ),
                  height: 48,
                  selectedValue: _selectedReason,
                  itemAsString: (item) => item.label,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  borderColor: context.colors.inputBorder,
                  borderRadius: BorderRadius.circular(
                    AppCornerRadius.xSmall,
                  ),
                  iconWidget: const SvgIconWidget(name: 'arrow-down'),
                ),
                const SizedBox(height: 24),
                AppTextFormFieldComponent(
                  controller: _reviewController,
                  title: avisTr(
                    LocaleKeys.common_write_your_review,
                    context: context,
                  ),
                  hintText: avisTr(
                    LocaleKeys.common_enter_here,
                    context: context,
                  ),
                  titleStyle: AppTextStyles.bodyMedium.copyWith(
                    color: context.colors.primaryText,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        avisTr(
                          LocaleKeys.common_mark_as_favourite_driver,
                          context: context,
                        ),
                        style: AppTextStyles.bodyMediumBold.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _markAsFavorite,
                        onChanged: (value) {
                          setState(() => _markAsFavorite = value);
                        },
                        activeThumbColor: context.colors.surface,
                        activeTrackColor: context.colors.primary,
                        inactiveThumbColor: context.colors.surface,
                        inactiveTrackColor: context.colors.surfaceDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Selector<RatingProvider, bool>(
                  selector: (context, provider) => provider.isLoading,
                  builder: (context, isLoading, child) {
                    return AppButton.primary(
                      isLoading: isLoading,
                      onPressed: _submit,
                      text: submitButtonText,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.onChanged});

  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: width,
      child: Center(
        child: RatingBar.builder(
          initialRating: 3,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          glow: false,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) {
            onChanged(rating.toInt());
          },
        ),
      ),
    );
  }
}
