import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/generated/locale_keys.g.dart';

/// Dialog to pick a cancel reason and submit.
class CancelTripReasonDialog extends StatefulWidget {
  const CancelTripReasonDialog({
    super.key,
    required this.categories,
    required this.isArabic,
    this.isLoading = false,
  });

  final List<CancelationCategoryModel> categories;
  final bool isArabic;
  final bool isLoading;

  static Future<CancelationCategoryModel?> show(
    BuildContext context, {
    required List<CancelationCategoryModel> categories,
    bool isLoading = false,
  }) {
    final isArabic = _isArabic(context);
    return showDialog<CancelationCategoryModel>(
      context: context,
      builder: (ctx) => CancelTripReasonDialog(
        categories: categories,
        isArabic: isArabic,
        isLoading: isLoading,
      ),
    );
  }

  /// Read language from the caller. [showDialog] puts this dialog on the
  /// navigator overlay, outside the route-scoped [LocalizationProvider].
  static bool _isArabic(BuildContext context) {
    try {
      return context.isArabic;
    } on ProviderNotFoundException {
      return Localizations.localeOf(context).languageCode == 'ar';
    }
  }

  @override
  State<CancelTripReasonDialog> createState() => _CancelTripReasonDialogState();
}

class _CancelTripReasonDialogState extends State<CancelTripReasonDialog> {
  CancelationCategoryModel? _selectedReason;
  String? _validationError;

  String _displayName(CancelationCategoryModel item) {
    final primary = item.primaryName ?? item.name ?? '';
    final secondary = item.secondaryName;
    if (widget.isArabic && secondary != null) return secondary;
    return primary;
  }

  void _onSubmit() {
    if (_selectedReason == null) {
      setState(() {
        _validationError = avisTr(
          LocaleKeys.common_please_select_a_reason,
          context: context,
        );
      });
      return;
    }
    Navigator.of(context).pop(_selectedReason);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppCornerRadius.medium),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextWidget(
              'Cancel Trip',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: context.colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            TextWidget(
              'Please select a reason for cancelling this trip.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.colors.secondaryText,
              ),
            ),
            SizedBox(height: 24.h),
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.categories.isEmpty)
              TextWidget(
                'No cancellation reasons available.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colors.secondaryText,
                ),
              )
            else
              AppCustomDropdown<CancelationCategoryModel>(
                items: widget.categories,
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
                itemAsString: _displayName,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                    _validationError = null;
                  });
                },
                borderColor: context.colors.inputBorder,
                borderRadius: BorderRadius.circular(AppCornerRadius.xSmall),
                iconWidget: const SvgIconWidget(name: 'arrow-down'),
              ),
            if (_validationError != null) ...[
              SizedBox(height: 8.h),
              TextWidget(
                _validationError!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.error,
                ),
              ),
            ],
            SizedBox(height: 24.h),
            AppButton.primary(
              onPressed: widget.isLoading || widget.categories.isEmpty
                  ? null
                  : _onSubmit,
              text: avisTr(LocaleKeys.common_submit, context: context),
              width: double.infinity,
              height: 48.w,
            ),
            SizedBox(height: 12.h),
            AppButton.secondary(
              onPressed: () => Navigator.of(context).pop(),
              text: avisTr(LocaleKeys.common_cancel, context: context),
              width: double.infinity,
              height: 48.w,
              customBorderColor: context.colors.border,
            ),
          ],
        ),
      ),
    );
  }
}
