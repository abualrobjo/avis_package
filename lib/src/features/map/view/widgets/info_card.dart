import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        AppButton,
        AppContextExtension,
        AppCornerRadius,
        AppRoutes,
        AppSpaces,
        AppTextStyles,
        CancellationProvider,
        CancellationState,
        CustomerTripByIdModelExtension,
        DraggableMapCard,
        DriverCard,
        HorizontalDivider,
        TextWidget,
        TripRouteWidget,
        errorDialog,
        sl,
        successDialog;
import 'package:avis_package/src/core/data/models/customer_trip_by_id_model.dart';
import 'package:avis_package/src/features/map/provider/map_provider.dart';
import 'package:avis_package/src/features/map/view/widgets/_widgets.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.tripInfo});

  final CustomerTripByIdModel tripInfo;

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, provider, _) {
        return DraggableMapCard(
          showBlackContainer: provider.hasValidDropOffCoordinates,
          maxHeightFactor: tripInfo.isCancellationAllowed ? 0.65 : 0.62,
          initialHeightFactor: tripInfo.isCancellationAllowed ? 0.65 : 0.62,
          minHeightFactor: 0.13,
          text: provider.loadingEta
              ? 'Calculating route...'
              : 'Estimated time to destination',
          time: provider.loadingEta
              ? '...'
              : (provider.etaDurationLabel ?? '--'),
          subtext: provider.loadingEta ? null : provider.etaSubtextLabel,
          child: MapBaseContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpaces.large),
                MapCarInfoCard(tripInfo: tripInfo),
                const SizedBox(height: AppSpaces.large),
                DriverCard(data: tripInfo),
                const SizedBox(height: AppSpaces.large),
                const HorizontalDivider(padding: EdgeInsets.zero, thickness: 5),
                const SizedBox(height: 6),
                Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(
                      AppCornerRadius.absolute,
                    ),
                  ),
                  child: TextWidget(
                    tripInfo.tripTypePrimaryName ?? '',
                    style: AppTextStyles.labelBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TripRouteWidget(
                  pickupLabel: 'Start Location',
                  pickupTime: CustomerTripByIdModel.formatTripDateTime(
                    tripInfo.tripDateTime,
                  ),
                  pickupLocation: tripInfo.pickupLatitude ?? '',
                  dropOffLabel: 'Your Destination',
                  dropOffLocation: tripInfo.dropOffLatitude ?? '',
                  horizontalPadding: 0,
                ),
                const SizedBox(height: AppSpaces.large),
                const HorizontalDivider(padding: EdgeInsets.zero, thickness: 5),
                const SizedBox(height: AppSpaces.large),
                CancelTripButton(trip: tripInfo),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CancelTripButton extends StatelessWidget {
  final CustomerTripByIdModel trip;

  const CancelTripButton({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    if (!trip.isCancellationAllowed) {
      return const SizedBox.shrink();
    }

    return ChangeNotifierProvider<CancellationProvider>.value(
      value: sl<CancellationProvider>(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpaces.large),
        child: Consumer<CancellationProvider>(
          builder: (context, provider, child) {
            return AppButton.secondary(
              isLoading:
                  provider.cancellationState == CancellationState.loading,
              onPressed: () => _cancelTrip(context, provider),
              text: 'Cancel Trip',
              foregroundColor: context.colors.error,
              customBorderColor: context.colors.error,
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancelTrip(
    BuildContext context,
    CancellationProvider provider,
  ) async {
    await provider.cancelRideRequest(trip.tripId);

    if (!context.mounted) return;

    if (provider.cancellationStatus == 1) {
      successDialog(
        context,
        message: 'Your ride has been canceled.',
        onPressed: () {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.myTrips, (route) => false);
        },
      );
    } else {
      errorDialog(context, message: 'Something went wrong');
    }
  }
}
