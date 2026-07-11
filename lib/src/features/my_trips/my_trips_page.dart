import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/_features.dart'
    show MapPage, MyTripsProvider;

/// Active-tab trips with these status ids open the live map; all others open trip details.
const _myTripsMapStatusIds = {8, 9};

bool _shouldOpenLiveMap(
  CustomerTripDetailModel trip, {
  required _MyTripsTab tab,
}) {
  final id = trip.statusId;
  return trip.showMap ||
      (tab == _MyTripsTab.active &&
          id != null &&
          _myTripsMapStatusIds.contains(id));
}

void _navigateTripFromMyTrips(
  BuildContext context,
  CustomerTripDetailModel trip, {
  required _MyTripsTab tab,
}) {
  if (_shouldOpenLiveMap(trip, tab: tab)) {
    AvisNavigation.push(
      context,
      AppRoutes.map,
      arguments: trip.tripId,
    );
  } else {
    AvisNavigation.push(
      context,
      AppRoutes.tripDetails,
      arguments: trip.tripId,
    );
  }
}

/// Recent-trip map card: inverse of [_navigateTripFromMyTrips].
void _navigateRecentTripMapCard(
  BuildContext context,
  CustomerTripDetailModel trip,
) {
  if (_shouldOpenLiveMap(trip, tab: _MyTripsTab.active)) {
    AvisNavigation.push(
      context,
      AppRoutes.tripDetails,
      arguments: trip.tripId,
    );
  } else {
    AvisNavigation.push(
      context,
      AppRoutes.map,
      arguments: trip.tripId,
    );
  }
}

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

enum _MyTripsTab { upcoming, active, finished, cancelled }

extension on _MyTripsTab {
  String get label {
    switch (this) {
      case _MyTripsTab.upcoming:
        return 'Upcoming';
      case _MyTripsTab.active:
        return 'Active';
      case _MyTripsTab.finished:
        return 'Completed';
      case _MyTripsTab.cancelled:
        return 'Cancelled';
    }
  }

  String get emptyMessage {
    switch (this) {
      case _MyTripsTab.upcoming:
        return 'No upcoming trips';
      case _MyTripsTab.active:
        return 'No active trips';
      case _MyTripsTab.finished:
        return 'No Completed trips';
      case _MyTripsTab.cancelled:
        return 'No cancelled trips';
    }
  }

  MyTripTab get filter => switch (this) {
        _MyTripsTab.upcoming => MyTripTab.upcoming,
        _MyTripsTab.active => MyTripTab.active,
        _MyTripsTab.finished => MyTripTab.finished,
        _MyTripsTab.cancelled => MyTripTab.cancelled,
      };
}

class _MyTripsPageState extends State<MyTripsPage> {
  _MyTripsTab _selectedTab = _MyTripsTab.upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        getCustomerTripsHistory();
      }
    });
  }

  Future<void> getCustomerTripsHistory() async {
    if (!mounted) return;
    await context.read<MyTripsProvider>().getCustomerTripsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTripsProvider>(
      builder: (context, provider, _) {
        if (provider.loading && provider.trips.isEmpty) {
          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: AppBar(
              backgroundColor: context.colors.background,
              elevation: 0,
              leading: const BackArrowWidget(),
              title: TextWidget(
                'My Trips',
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
        if (provider.errorMessage != null && provider.trips.isEmpty) {
          return Scaffold(
            backgroundColor: context.colors.background,
            appBar: AppBar(
              backgroundColor: context.colors.background,
              elevation: 0,
              leading: const BackArrowWidget(),
              title: TextWidget(
                'My Trips',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryText,
                ),
              ),
              centerTitle: true,
            ),
            body: RefreshIndicator(
              onRefresh: getCustomerTripsHistory,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWidget(
                          provider.errorMessage!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
                          onPressed: getCustomerTripsHistory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final filteredTrips = provider.trips
            .where((trip) => trip.myTripTab == _selectedTab.filter)
            .toList();

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBar(
            backgroundColor: context.colors.background,
            elevation: 0,
            leading: const BackArrowWidget(),
            title: TextWidget(
              'My Trips',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.primaryText,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _TripsTabBar(
                    selectedTab: _selectedTab,
                    onTabSelected: (tab) {
                      setState(() => _selectedTab = tab);
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                if (filteredTrips.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: TextWidget(
                      '${filteredTrips.length} trips',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.secondaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: getCustomerTripsHistory,
                    child: filteredTrips.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                            ).copyWith(bottom: 20.h),
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.25,
                              ),
                              Center(
                                child: TextWidget(
                                  provider.trips.isEmpty
                                      ? 'No trips yet'
                                      : _selectedTab.emptyMessage,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: context.colors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Scrollbar(
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                              ).copyWith(bottom: 20.h),
                              itemCount: filteredTrips.length,
                              separatorBuilder: (_, _) => SizedBox(height: 14.h),
                              itemBuilder: (context, index) {
                                final trip = filteredTrips[index];

                                return _TripListItem(
                                  trip: trip,
                                  onTap: () {
                                    _navigateTripFromMyTrips(
                                      context,
                                      trip,
                                      tab: _selectedTab,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TripsTabBar extends StatelessWidget {
  const _TripsTabBar({
    required this.selectedTab,
    required this.onTabSelected,
  });

  final _MyTripsTab selectedTab;
  final ValueChanged<_MyTripsTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _MyTripsTab.values.map((tab) {
          final isSelected = selectedTab == tab;
          final isLast = tab == _MyTripsTab.cancelled;

          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTabSelected(tab),
                borderRadius: BorderRadius.circular(AppCornerRadius.absolute),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppCornerRadius.absolute,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.border,
                    ),
                  ),
                  child: Center(
                    child: TextWidget(
                      tab.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? context.colors.inverseText
                            : context.colors.primaryText,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.trip});

  final CustomerTripDetailModel trip;

  @override
  Widget build(BuildContext context) {
    final dropOffLocation = CustomerTripDetailModel.parseLatLngString(
      trip.dropOffLongtitude,
    );

    final futurePlaceName = dropOffLocation == null
        ? Future.value(trip.tripListPlaceTitle)
        : AppGeocoding.getPlaceName(
            LatLng(dropOffLocation.lat, dropOffLocation.lon),
          );

    return FutureBuilder<String>(
      future: futurePlaceName,
      builder: (context, snapshot) {
        final placeName = snapshot.connectionState == ConnectionState.done
            ? snapshot.data ?? ''
            : trip.tripListPlaceTitle;

        final dateTimeText = CustomerTripDetailModel.formatTripDateTime(
          trip.tripDateTime,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
          child: SizedBox(
            height: 220.h,
            child: Stack(
              children: [
                MapPage(
                  tripId: trip.tripId,
                  showInfoCard: false,
                  showBackArrow: false,
                  isStaticMap: true,
                ),
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.h,
                  child: _MapOverlayCard(
                    title: placeName,
                    subtitle: dateTimeText,
                    onLoopTap: () {},
                    trip: trip,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapOverlayCard extends StatelessWidget {
  const _MapOverlayCard({
    required this.title,
    required this.subtitle,
    this.onLoopTap,
    required this.trip,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onLoopTap;
  final CustomerTripDetailModel trip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _navigateRecentTripMapCard(context, trip);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppCornerRadius.small.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    title,
                    style: AppTextStyles.bodyLargeBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  TextWidget(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripListItem extends StatelessWidget {
  const _TripListItem({required this.trip, required this.onTap});

  final CustomerTripDetailModel trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final placeName = trip.tripListPlaceTitle;

    final dateTimeText = CustomerTripDetailModel.formatTripDateTime(
      trip.tripDateTime,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: context.colors.infoBackground,
                borderRadius: BorderRadius.circular(AppCornerRadius.small.r),
              ),
              child: SizedBox(
                height: 40.w,
                width: 40.w,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppCornerRadius.small.r,
                    ),
                    child: Image.asset(
                      'assets/images/av_car.png',
                      package: 'avis_package',
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.directions_car,
                        color: context.colors.tertiaryText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    placeName,
                    style: AppTextStyles.bodyLargeBold.copyWith(
                      color: context.colors.primaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  TextWidget(
                    dateTimeText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpaces.xxSmall,
                          horizontal: AppSpaces.xSmall,
                        ),
                        decoration: BoxDecoration(
                          color: trip.statusBackgroundColor(context),
                          borderRadius: BorderRadius.circular(
                            AppCornerRadius.xSmall,
                          ),
                        ),
                        child: TextWidget(
                          trip.statusLocalized(context),
                          style: AppTextStyles.labelBold.copyWith(
                            color: trip.statusTextColor(context),
                          ),
                        ),
                      ),
                      if (trip.tripTypeLocalized(context).isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpaces.xxSmall,
                            horizontal: AppSpaces.xSmall,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.border,
                            borderRadius: BorderRadius.circular(
                              AppCornerRadius.xSmall,
                            ),
                          ),
                          child: TextWidget(
                            trip.tripTypeLocalized(context),
                            style: AppTextStyles.labelBold.copyWith(
                              color: context.colors.primaryText,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpaces.small),

            Center(
              child: SvgIconWidget(
                name: 'arrow-with-circel',
                width: 35.w,
                height: 35.w,
                color: context.colors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
