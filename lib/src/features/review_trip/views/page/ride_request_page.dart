import 'package:avis_package/src/core/utils/_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/features/_features.dart' show ReviewTripUiModel;
import 'package:avis_package/src/core/_core.dart'
    show
        AppButton,
        AppContextExtension,
        AppCornerRadius,
        AppRoutes,
        AppSpaces,
        AppTextStyles,
        BackArrowWidget,
        CancelTripReasonDialog,
        CancellationProvider,
        CancellationState,
        CustomerTripsRepository,
        SvgIconWidget,
        TextWidget,
        VerticalDashedBorderPainter,
        NetworkImageWidget,
        sl;

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({
    super.key,
    required this.tripModel,
    this.tripId,
    this.tripTypeId,
    this.fromMyTrips = false,
    this.cancellationBookLaterEnabled = false,
  });
  final ReviewTripUiModel tripModel;
  final int? tripId;
  final int? tripTypeId;
  final bool fromMyTrips;
  final bool cancellationBookLaterEnabled;

  @override
  State<RideRequestPage> createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {
  String? _classMiniDesc;
  late final CancellationProvider _cancellationProvider;

  bool get _showDropOff => widget.tripTypeId != 2;

  @override
  void initState() {
    super.initState();
    _cancellationProvider = sl<CancellationProvider>();
    _loadClassMiniDesc();
    if (widget.cancellationBookLaterEnabled) {
      _cancellationProvider.fetchCancelationCategories();
    }
  }

  Future<void> _loadClassMiniDesc() async {
    final tripId = widget.tripId;
    if (tripId == null) return;

    final response =
        await sl<CustomerTripsRepository>().getCustomerTripById(tripId);
    if (!mounted) return;

    response.when(
      success: (trip) {
        final desc = trip.classMiniDesc?.trim();
        if (desc != null && desc.isNotEmpty) {
          setState(() => _classMiniDesc = desc);
        }
      },
      failure: (_) {},
    );
  }

  Future<void> _onCancelTrip(
    BuildContext context,
    CancellationProvider provider,
  ) async {
    if (provider.cancelationCategories.isEmpty) {
      await provider.fetchCancelationCategories();
      if (!context.mounted) return;
    }

    final reason = await CancelTripReasonDialog.show(
      context,
      categories: provider.cancelationCategories,
    );
    if (reason == null || !context.mounted) return;

    await provider.cancelRideRequest(
      widget.tripId!,
      cancelationReasonId: reason.id,
    );
    if (!context.mounted) return;

    if (!context.mounted) return;
    if (provider.cancellationState == CancellationState.success &&
        (provider.cancellationStatus == 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your ride has been cancelled.')),
      );
    } else if (provider.cancellationState == CancellationState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Something went wrong. Could not cancel.',
          ),
        ),
      );
    }
    if (!context.mounted) return;
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              (widget.fromMyTrips ? AppRoutes.myTrips : AppRoutes.servicePage) ||
          route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        leading: BackArrowWidget(
          onTap: () {
            Navigator.of(context).popUntil(
              (route) =>
                  route.settings.name ==
                      (widget.fromMyTrips ? AppRoutes.myTrips : AppRoutes.servicePage) ||
                  route.isFirst,
            );
          },
        ),
        title: TextWidget(
          'Ride Request',
          style: AppTextStyles.bodyLargeBold.copyWith(
            color: context.colors.primaryText,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.tripId != null)
                    Row(
                      children: [
                        TextWidget(
                          'Trip No',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: context.colors.secondaryText,
                          ),
                        ),
                        const SizedBox(width: AppSpaces.xSmall),
                        TextWidget(
                          '${widget.tripId}',
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: context.colors.primaryText,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpaces.medium,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.successBackground,
                      borderRadius: BorderRadius.circular(
                        AppCornerRadius.absolute,
                      ),
                    ),
                    child: TextWidget(
                      'Confirmed',
                      style: AppTextStyles.bodySmallBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpaces.medium),
              Container(
                width: width,
                padding: const EdgeInsets.all(AppSpaces.small),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(AppCornerRadius.medium),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),
                        const _TimeLineIcon(iconName: 'dot', paddingValue: 9),
                        if (_showDropOff) ...[
                          SizedBox(
                            height: AppSpaces.xxlarge,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 13.5,
                              ),
                              child: CustomPaint(
                                painter: VerticalDashedBorderPainter(
                                  color: context.colors.warningBackground,
                                ),
                              ),
                            ),
                          ),
                          const _TimeLineIcon(
                            iconName: 'location',
                            paddingValue: 0,
                            isWithBacgroundColor: false,
                          ),
                        ],
                        const SizedBox(height: 6),
                      ],
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWidget(
                            'From',
                            style: AppTextStyles.bodyXSmallBold.copyWith(
                              color: context.colors.tertiaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextWidget(
                            widget.tripModel.route.pickupLocation,
                            style: AppTextStyles.bodySmallBold.copyWith(
                              color: context.colors.primaryText,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_showDropOff) ...[
                            const SizedBox(height: AppSpaces.medium),
                            const HorizontalDivider(
                              padding: EdgeInsets.zero,
                              thickness: 1,
                            ),
                            const SizedBox(height: AppSpaces.medium),
                            TextWidget(
                              'To',
                              style: AppTextStyles.bodyXSmallBold.copyWith(
                                color: context.colors.tertiaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextWidget(
                              widget.tripModel.route.dropOffLocation,
                              style: AppTextStyles.bodySmallBold.copyWith(
                                color: context.colors.primaryText,
                                fontSize: 13,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpaces.onSides),
              Container(
                width: width,
                padding: const EdgeInsets.all(AppSpaces.small),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(AppCornerRadius.medium),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NetworkImageWidget(
                      url: widget.tripModel.vehicle.imageUrl,
                      width: 120,
                      height: 76,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.tripModel.vehicle.name,
                                  style: AppTextStyles.bodyLargeBold.copyWith(
                                    color: context.colors.primaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SvgIconWidget(
                                name: 'profile',
                                color: context.colors.primaryText,
                                width: 16,
                                height: 16,
                              ),
                              TextWidget(
                                widget.tripModel.vehicle.passengerCapacity
                                    .toString(),
                                style: AppTextStyles.bodyXSmallBold.copyWith(
                                  color: context.colors.primaryText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SvgIconWidget(
                                name: 'bag',
                                color: context.colors.primaryText,
                                width: 16,
                                height: 16,
                              ),
                              TextWidget(
                                widget.tripModel.vehicle.luggageCapacity
                                    .toString(),
                                style: AppTextStyles.bodyXSmallBold.copyWith(
                                  color: context.colors.primaryText,
                                ),
                              ),
                            ],
                          ),
                          if (_classMiniDesc != null) ...[
                            const SizedBox(height: 6),
                            TextWidget(
                              _classMiniDesc!,
                              style: AppTextStyles.bodyXSmall.copyWith(
                                color: context.colors.tertiaryText,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (widget.tripModel.isIndividual)
                            const SizedBox(height: 10),
                          if (widget.tripModel.isIndividual)
                            TextWidget(
                              widget.tripModel.price.formattedPrice,
                              style: AppTextStyles.bodyLargeBold.copyWith(
                                color: context.colors.primaryText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // TextWidget(
              //   'What happens next',
              //   style: AppTextStyles.bodyMediumBold.copyWith(
              //     color: context.colors.primaryText,
              //   ),
              // ),
              // const SizedBox(height: 18),
              // Row(
              //   children: [
              //     const SvgIconWidget(
              //       name: 'teenyicons_tick-circle-solid',
              //       width: 16,
              //       height: 16,
              //     ),
              //     const SizedBox(width: AppSpaces.small),
              //     TextWidget(
              //       'We’re confirming your ride',
              //       style: AppTextStyles.bodySmallBold.copyWith(
              //         color: context.colors.secondaryText,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: AppSpaces.medium),
              // Row(
              //   children: [
              //     const SvgIconWidget(
              //       name: 'teenyicons_tick-circle-solid',
              //       width: 16,
              //       height: 16,
              //     ),
              //     const SizedBox(width: AppSpaces.small),
              //     TextWidget(
              //       'You’ll receive a notification once confirmed',
              //       style: AppTextStyles.bodySmallBold.copyWith(
              //         color: context.colors.secondaryText,
              //       ),
              //     ),
              //   ],
              // ),
              const Spacer(),
              if (widget.cancellationBookLaterEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpaces.large,
                  ),
                  child: ChangeNotifierProvider<CancellationProvider>.value(
                    value: _cancellationProvider,
                    child: Consumer<CancellationProvider>(
                      builder: (context, cancellationProvider, _) {
                        return AppButton.secondary(
                          isLoading:
                              cancellationProvider.cancellationState ==
                                  CancellationState.loading,
                          onPressed: widget.tripId == null
                              ? null
                              : () => _onCancelTrip(
                                    context,
                                    cancellationProvider,
                                  ),
                          text: 'Cancel Trip',
                          foregroundColor: context.colors.error,
                          customBorderColor: context.colors.error,
                        );
                      },
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeLineIcon extends StatelessWidget {
  const _TimeLineIcon({
    required this.iconName,
    required this.paddingValue,
    this.isWithBacgroundColor = true,
  });
  final String iconName;
  final double paddingValue;
  final bool isWithBacgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      padding: EdgeInsets.all(paddingValue),
      decoration: BoxDecoration(
        color: isWithBacgroundColor
            ? context.colors.warningBackground
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: SvgIconWidget(name: iconName, color: context.colors.primary),
    );
  }
}
