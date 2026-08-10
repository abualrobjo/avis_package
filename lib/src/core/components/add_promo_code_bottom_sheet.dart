import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        TextWidget,
        AppTextStyles,
        AppContextExtension,
        AppSpaces,
        AppButton,
        AppTextFormFieldComponent,
        SvgIconWidget,
        sl,
        PromoCodeService,
        CheckPromoCodeValidityRequest,
        CheckPromoCodeValidityDetails,
        AuthLocalService,
        CustomerInfoService;
import 'bottom_sheet_handle.dart';

class AddPromoCodeBottomSheet extends StatefulWidget {
  const AddPromoCodeBottomSheet({
    super.key,
    required this.tripTypeId,
    required this.pickupDateTime,
    this.onPromoApplied,
  });

  final int tripTypeId;
  final String pickupDateTime;
  final void Function(String code, CheckPromoCodeValidityDetails details)?
      onPromoApplied;

  static Future<void> show(
    BuildContext context, {
    required int tripTypeId,
    required String pickupDateTime,
    void Function(String code, CheckPromoCodeValidityDetails details)?
        onPromoApplied,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddPromoCodeBottomSheet(
        tripTypeId: tripTypeId,
        pickupDateTime: pickupDateTime,
        onPromoApplied: onPromoApplied,
      ),
    );
  }

  @override
  State<AddPromoCodeBottomSheet> createState() => _AddPromoCodeBottomSheetState();
}

class _AddPromoCodeBottomSheetState extends State<AddPromoCodeBottomSheet> {
  final TextEditingController _promoController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  static const int _companyId = 1;
  static const int _defaultBranchId = 1;

  @override
  void initState() {
    super.initState();
    _promoController.addListener(_clearErrorOnTyping);
  }

  @override
  void dispose() {
    _promoController.removeListener(_clearErrorOnTyping);
    _promoController.dispose();
    super.dispose();
  }

  void _clearErrorOnTyping() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  Future<int> _getBranchId() async {
    final customerId = sl<AuthLocalService>().getCustomerId();
    if (customerId == null) return _defaultBranchId;
    final response = await sl<CustomerInfoService>().getCustomerInfo(customerId);
    if (response.isSuccess && response.data.clientbranchId != 0) {
      return response.data.clientbranchId;
    }
    return _defaultBranchId;
  }

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage = 'Please enter a promo code');
      }
      return;
    }
    setState(() => _loading = true);
    setState(() => _errorMessage = null);
    final branchId = await _getBranchId();
    if (!mounted) return;
    final request = CheckPromoCodeValidityRequest(
      promoCode: code,
      companyId: _companyId,
      tripTypeId: widget.tripTypeId,
      branchId: branchId,
      pickupDateTime: widget.pickupDateTime,
    );
    final response = await sl<PromoCodeService>().checkPromoCodeValidity(request);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!response.isSuccess) {
      setState(() => _errorMessage = response.errorMessage ?? 'Could not check promo code.');
      return;
    }
    if (response.data.isPromoValid) {
      widget.onPromoApplied?.call(code, response.data);
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promo code applied successfully')),
        );
      }
    } else {
      setState(() => _errorMessage = 'Invalid promo code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.5, 12, 20.5, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(child: BottomSheetHandle()),
            const SizedBox(height: AppSpaces.xxlarge),
            TextWidget(
              'Add Promo Code',
              style: AppTextStyles.h1.copyWith(
                color: context.colors.primaryText,
              ),
            ),
            const SizedBox(height: AppSpaces.medium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpaces.xxlarge,
              ),
              child: TextWidget(
                'Enter a promo code to get a\ndiscount on this trip.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.colors.tertiaryText,
                ),
              ),
            ),
            const SizedBox(height: AppSpaces.xxlarge),
            AppTextFormFieldComponent(
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpaces.onSides,
                ),
                child: SvgIconWidget(
                  name: 'coupon',
                  width: 20,
                  height: 20,
                  color: _errorMessage != null ? context.colors.error : context.colors.tertiaryText,
                ),
              ),
              hintText: 'Enter promo code',
              controller: _promoController,
              warningMsg: _errorMessage,
            ),
            const SizedBox(height: AppSpaces.xxlarge),
            AppButton.primary(
              onPressed: _loading ? null : _applyPromoCode,
              text: _loading ? 'Checking...' : 'Apply',
            ),
          ],
        ),
      ),
    );
  }
}
