import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        TextWidget,
        AppTextStyles,
        AppContextExtension,
        AppSpaces,
        AppButton,
        CounterWidget,
        sl,
        AuthLocalService,
        AppConst,
        CustomerInfoService,
        CustomerLoyaltyPromoCodeService,
        GenerateCustomerLoyaltyPromoCodeRequest;
import 'bottom_sheet_handle.dart';

class RedeemLoyaltyPointsBottomSheet extends StatefulWidget {
  const RedeemLoyaltyPointsBottomSheet({
    super.key,
    this.totalLoyalityPoints,
    this.maxRedeemablePoints,
    this.minimumPointsValueForTransfer,
    this.onRedeemed,
  });

  final int? totalLoyalityPoints;
  final int? maxRedeemablePoints;
  final int? minimumPointsValueForTransfer;
  final void Function(String code)? onRedeemed;

  static Future<void> show(
    BuildContext context, {
    int? totalLoyalityPoints,
    int? maxRedeemablePoints,
    int? minimumPointsValueForTransfer,
    void Function(String code)? onRedeemed,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => RedeemLoyaltyPointsBottomSheet(
        totalLoyalityPoints: totalLoyalityPoints,
        maxRedeemablePoints: maxRedeemablePoints,
        minimumPointsValueForTransfer: minimumPointsValueForTransfer,
        onRedeemed: onRedeemed,
      ),
    );
  }

  @override
  State<RedeemLoyaltyPointsBottomSheet> createState() =>
      _RedeemLoyaltyPointsBottomSheetState();
}

class _RedeemLoyaltyPointsBottomSheetState
    extends State<RedeemLoyaltyPointsBottomSheet> {
  int _pointsCount = 0;
  bool _loading = false;
  bool _loadingInfo = true;
  int _totalLoyalityPoints = 0;
  int _maxRedeemablePoints = 0;
  int _minimumPointsValueForTransfer = 0;

  int get _customerId =>
      sl<AuthLocalService>().getUserId() ?? AppConst.fallbackCustomerId;

  @override
  void initState() {
    super.initState();
    final fromArgs = widget.totalLoyalityPoints != null &&
        widget.maxRedeemablePoints != null &&
        widget.minimumPointsValueForTransfer != null;
    if (fromArgs) {
      _totalLoyalityPoints = widget.totalLoyalityPoints!;
      _maxRedeemablePoints = widget.maxRedeemablePoints!;
      _minimumPointsValueForTransfer = widget.minimumPointsValueForTransfer!;
      _pointsCount = _minimumPointsValueForTransfer.clamp(0, _maxRedeemablePoints);
      _loadingInfo = false;
    } else {
      _loadCustomerInfo();
    }
  }

  Future<void> _loadCustomerInfo() async {
    final response = await sl<CustomerInfoService>().getCustomerInfo(_customerId);
    if (!mounted) return;
    setState(() {
      _loadingInfo = false;
      if (response.isSuccess) {
        _totalLoyalityPoints = response.data.totalLoyalityPoints;
        _maxRedeemablePoints = response.data.maxRedeemablePoints;
        _minimumPointsValueForTransfer = response.data.minimumPointsValueForTransfer;
        _pointsCount = _minimumPointsValueForTransfer.clamp(0, _maxRedeemablePoints);
      }
    });
  }

  Future<void> _redeem() async {
    if (_pointsCount < _minimumPointsValueForTransfer ||
        _pointsCount > _maxRedeemablePoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select points within the allowed range')),
      );
      return;
    }
    if (_pointsCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select points to redeem')),
      );
      return;
    }
    setState(() => _loading = true);
    final request = GenerateCustomerLoyaltyPromoCodeRequest(
      createdBy: 0,
      fkCustomerId: _customerId,
      pointsAmount: _pointsCount,
    );
    final response = await sl<CustomerLoyaltyPromoCodeService>()
        .generateCustomerLoyaltyPromoCode(request);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.errorMessage ?? 'Could not redeem loyalty points.',
          ),
        ),
      );
      return;
    }
    final code = response.data;
    if (code.isNotEmpty) {
      widget.onRedeemed?.call(code);
    }
    if (mounted) Navigator.of(context).pop();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code.isEmpty
                ? 'Loyalty points redeemed successfully'
                : 'Loyalty code applied: $code',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // Extra bottom padding to avoid ~35px overflow under the white container.
        padding: const EdgeInsets.fromLTRB(20.5, 12, 20.5, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(child: BottomSheetHandle()),
            const SizedBox(height: AppSpaces.xxlarge),
            TextWidget(
              'Redeem Loyalty Points',
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
                'Use your loyalty points to reduce\nthe cost of this trip.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: context.colors.tertiaryText,
                ),
              ),
            ),
            const SizedBox(height: AppSpaces.xxlarge),
            SizedBox(
              width: double.infinity,
              child: _loadingInfo
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          'Total: $_totalLoyalityPoints',
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                        TextWidget(
                          'Max Redeemable: $_maxRedeemablePoints',
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                        TextWidget(
                          'Min Redeemable: $_minimumPointsValueForTransfer',
                          style: AppTextStyles.bodyLargeBold.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpaces.small),
                        TextWidget(
                          'Redeem',
                          style: AppTextStyles.bodySmallBold.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: AppSpaces.xSmall),
                        CounterWidget(
                          count: _pointsCount,
                          onIncrement: () => setState(() {
                            if (_pointsCount < _maxRedeemablePoints) {
                              _pointsCount++;
                            }
                          }),
                          onDecrement: () => setState(() {
                            if (_pointsCount > _minimumPointsValueForTransfer) {
                              _pointsCount--;
                            }
                          }),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpaces.xlarge),
            AppButton.primary(
              onPressed: (_loading || _loadingInfo) ? null : _redeem,
              text: _loading ? 'Redeeming...' : 'Redeem',
            ),
            const SizedBox(height: AppSpaces.xSmall),

          ],
        ),
      ),
    );
  }
}
