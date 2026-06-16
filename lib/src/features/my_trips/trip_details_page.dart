import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart' show MyTripsProvider, PaymentProvider;
import 'package:avis_package/src/features/payment/views/payment_screen.dart';

class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key, required this.tripId});

  final int? tripId;

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchTripById();
      }
    });
  }

  Future<void> _fetchTripById() async {
    if (widget.tripId == null) return;
    final tripId = widget.tripId;
    if (tripId == null) return;

    final myTripsProvider = context.read<MyTripsProvider>();
    await myTripsProvider.getCustomerTripById(tripId);
  }

  Future<void> _onTripPayment() async {
    final tripId = widget.tripId;
    if (tripId == null || tripId <= 0) return;

    final paymentUrl =
        'https://chauffeurdriven.avis.eg/ChauffeurService/ChauffeurPayment?TripId=$tripId&f=0&RequestSource=3';

    if (!mounted) return;
    final isPaymentSuccess = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(paymentUrl: paymentUrl),
          ),
        ) ??
        false;

    if (!mounted) return;
    if (!isPaymentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment was not completed. Please try again.')),
      );
      return;
    }

    if (!mounted) return;
    context.read<PaymentProvider>().markPaidConfirmedFromWebView();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! Finalizing your booking...'),
        backgroundColor: Colors.green,
      ),
    );

    final customerId = sl<AuthLocalService>().getUserId() ?? AppConst.fallbackCustomerId;
    await sl<CustomerInfoService>().getCustomerInfo(customerId);
    if (!mounted) return;

    await context.read<MyTripsProvider>().getCustomerTripById(tripId);
  }

  static Future<bool?> _showCancelConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: const Text(
          'Are you sure you want to cancel this trip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCancelTrip(
    BuildContext context,
    CancellationProvider provider,
    int tripId,
  ) async {
    final confirmed = await _showCancelConfirmDialog(context);
    if (confirmed != true || !context.mounted) return;

    await provider.cancelRideRequest(tripId);
    if (!context.mounted) return;

    if (provider.cancellationState == CancellationState.success &&
        provider.cancellationStatus == 1) {
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
          route.settings.name == AppRoutes.myTrips || route.isFirst,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tripId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: const Center(child: Text('No trip data')),
      );
    }

    return Consumer<MyTripsProvider>(
      builder: (context, myTripsProvider, _) {
        if (myTripsProvider.loadingTripById) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: context.colors.background,
              leading: const BackArrowWidget(),
              title: TextWidget(
                'Trip Details',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryText,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (myTripsProvider.tripByIdErrorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: context.colors.background,
              leading: const BackArrowWidget(),
              title: TextWidget(
                'Trip Details',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryText,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Text(
                myTripsProvider.tripByIdErrorMessage ?? 'Something went wrong!',
              ),
            ),
          );
        }

        final displayTrip = myTripsProvider.tripById;
        final showPayment = displayTrip?.statusId == 7;
        final showCancel = displayTrip?.isCancellationAllowed ?? false;
        final tripId = widget.tripId!;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBar(
            backgroundColor: context.colors.background,
            elevation: 0,
            leading: const BackArrowWidget(),
            title: TextWidget(
              'Trip Details',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.primaryText,
              ),
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: showPayment || showCancel
              ? _TripDetailsBottomBar(
                  showPayment: showPayment,
                  showCancel: showCancel,
                  onPayPressed: () => _onTripPayment(),
                  onCancelPressed: showCancel
                      ? (provider) =>
                          _onCancelTrip(context, provider, tripId)
                      : null,
                )
              : null,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _VehicleCard(data: displayTrip),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.r),
                  child: DriverCard(
                    data: displayTrip,
                    showContactActions:
                        displayTrip?.isActiveTripSession ?? false,
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _ScheduledRow(
                    text: CustomerTripByIdModel.formatTripDateTime(
                      displayTrip?.tripDateTime,
                    ),
                  ),
                ),
                if (displayTrip?.showsTripHours == true) ...[
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _TripHoursRow(hours: displayTrip!.tripHoursLabel),
                  ),
                ],
                SizedBox(height: 20.h),
                TripRouteWidget(
                  pickupLabel: 'Start Location',
                  pickupTime: CustomerTripByIdModel.formatTime(
                    displayTrip?.tripDateTime,
                  ),
                  pickupLocation: displayTrip?.pickupLatitude ?? '',
                  dropOffLabel:
                      displayTrip?.routeDropOffSectionLabel ?? 'Your Destination',
                  dropOffTime: '',
                  dropOffLocation:
                      displayTrip?.routeDropOffSectionLocation ?? '',
                  showDropOff: displayTrip?.showsDropOffSection ?? true,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.data});

  final CustomerTripByIdModel? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.infoBackground,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextWidget(
                'Trip No',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.secondaryText,
                ),
              ),
              SizedBox(width: 4.w),
              TextWidget(
                '${data!.tripId}',
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 80.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: context.colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppCornerRadius.small.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppCornerRadius.small.r),
                  child: NetworkImageWidget(
                    url: data?.vehicleImagePath ?? '',
                    errorWidget: Icon(
                      Icons.directions_car,
                      size: 36.w,
                      color: context.colors.tertiaryText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextWidget(
                  '  ${data?.vehicleClassPrimaryName} - ${data?.tripTypePrimaryName ?? ''}',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SvgIconWidget(
                name: 'account',
                width: 18.w,
                height: 18.w,
                color: context.colors.secondaryText,
              ),
              SizedBox(width: 4.w),
              TextWidget(
                '${data?.passengersNo}',
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              SizedBox(width: 12.w),
              SvgIconWidget(
                name: 'bag',
                width: 18.w,
                height: 18.w,
                color: context.colors.secondaryText,
              ),
              SizedBox(width: 4.w),
              TextWidget(
                '${data?.suitcasesNo}',
                style: AppTextStyles.bodyMediumBold.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripHoursRow extends StatelessWidget {
  const _TripHoursRow({required this.hours});

  final String hours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIconWidget(
          name: 'clock',
          width: 24.w,
          height: 24.w,
          color: context.colors.secondaryText,
        ),
        SizedBox(width: 12.w),
        TextWidget(
          'Trip Hours',
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.secondaryText,
          ),
        ),
        SizedBox(width: 8.w),
        TextWidget(
          hours,
          style: AppTextStyles.bodyMediumBold.copyWith(
            color: context.colors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _ScheduledRow extends StatelessWidget {
  const _ScheduledRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIconWidget(
          name: 'calendar',
          width: 24.w,
          height: 24.w,
          color: context.colors.secondaryText,
        ),
        SizedBox(width: 12.w),
        TextWidget(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.colors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _TripDetailsBottomBar extends StatelessWidget {
  const _TripDetailsBottomBar({
    required this.showPayment,
    required this.showCancel,
    required this.onPayPressed,
    this.onCancelPressed,
  });

  final bool showPayment;
  final bool showCancel;
  final VoidCallback onPayPressed;
  final void Function(CancellationProvider provider)? onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withValues(alpha: 0.05),
            blurRadius: 5.4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpaces.large,
        vertical: AppSpaces.medium,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPayment) ...[
                AppButton.primary(onPressed: onPayPressed, text: 'Pay Now'),
                if (showCancel) const SizedBox(height: AppSpaces.medium),
              ],
              if (showCancel)
                ChangeNotifierProvider<CancellationProvider>.value(
                  value: sl<CancellationProvider>(),
                  child: Consumer<CancellationProvider>(
                    builder: (context, cancellationProvider, _) {
                      return AppButton.secondary(
                        isLoading: cancellationProvider.cancellationState ==
                            CancellationState.loading,
                        onPressed: onCancelPressed == null
                            ? null
                            : () =>
                                onCancelPressed!(cancellationProvider),
                        text: 'Cancel Trip',
                        foregroundColor: context.colors.error,
                        customBorderColor: context.colors.error,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
