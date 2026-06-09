import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../_features.dart';
import 'package:avis_package/src/core/_core.dart';
import 'map_place_picker_page.dart';
import 'place_picker_result.dart';

/// Services / booking page using system components.
class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  bool _ratingSheetShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().addListener(_onProviderUpdate);
      _maybeShowRatingSheet();
    });
  }

  @override
  void dispose() {
    context.read<ServicesProvider>().removeListener(_onProviderUpdate);
    super.dispose();
  }

  void _onProviderUpdate() => _maybeShowRatingSheet();

  Future<void> _maybeShowRatingSheet() async {
    if (_ratingSheetShown || !mounted) return;
    final provider = context.read<ServicesProvider>();
    final data = provider.pendingRatingTrip;
    if (data == null) return;
    _ratingSheetShown = true;
    provider.clearPendingRatingTrip();
    if (!mounted) return;
    await RatingBottomSheet.show(
      context,
      tripId: data.tripId,
      driverId: data.chauffeurId,
      customerId: data.customerId,
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickDate(BuildContext context, ServicesProvider p) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: p.pickDateInitialDate,
      firstDate: p.pickDateFirstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      p.applyPickedDate(picked);
    }
  }

  Future<void> _pickTime(BuildContext context, ServicesProvider p) async {
    final slots = p.availableTimeSlots;
    if (slots.isEmpty) return;
    final selected = p.selectedTime;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: TextWidget(
                  'Select time',
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.w,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final label = ServicesProvider.timeFormat.format(
                      DateTime(2000, 1, 1, slot.hour, slot.minute),
                    );
                    final isSelected =
                        slot.hour == selected.hour &&
                        slot.minute == selected.minute;
                    return ListTile(
                      title: TextWidget(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.primaryText,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        if (!mounted) return;
                        p.applyPickedTime(slot);
                      },
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

  Future<void> _pickReturnDate(BuildContext context, ServicesProvider p) async {
    final firstDate = p.returnDatePickerFirstDate;
    final lastDate = p.returnDatePickerLastDate(firstDate);
    final initialDate = p.returnDatePickerInitialDate(firstDate, lastDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      p.applyPickedReturnDate(picked);
    }
  }

  Future<void> _pickReturnTime(BuildContext context, ServicesProvider p) async {
    final slots = p.availableReturnTimeSlots;
    if (slots.isEmpty) {
      _showSnack('Choose a return date after pickup first');
      return;
    }
    final selected = p.returnTime;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: TextWidget(
                  'Return time',
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.w,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final label = ServicesProvider.timeFormat.format(
                      DateTime(2000, 1, 1, slot.hour, slot.minute),
                    );
                    final isSelected =
                        slot.hour == selected.hour &&
                        slot.minute == selected.minute;
                    return ListTile(
                      title: TextWidget(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.primaryText,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        if (!mounted) return;
                        p.applyPickedReturnTime(slot);
                      },
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

  void _showPlaceSelectionSheet(ServicesProvider p, {required bool isFrom}) {
    final label = isFrom ? 'Pickup location' : 'Drop-off location';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => PlaceSelectionSheet(
        title: label,
        savedPlaces: p.savedPlaces,
        airports: p.airports,
        showAirports: p.selectedTripType?.requiresFlightNumber ?? false,
        allowedPolygons: isFrom ? p.allowedPolygons : null,
        validateLocation: !isFrom && p.fromLatLng != null
            ? (latLng) async {
                final error = await p.checkDropOffAllowed(latLng);
                if (error != null) {
                  _showSnack(error);
                  return false;
                }
                return true;
              }
            : null,
        localizeAirportName: (airport) => context.localized(
          airport.airportPimaryName ?? '',
          airport.airportSecondaryName,
        ),
        onChooseFromMap: () {
          Navigator.of(sheetContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openMapPicker(p, isFrom: isFrom);
          });
        },
        onPlaceSelected: ({
          required name,
          required latLng,
          required fromAirportList,
        }) async {
          final error = await p.applyPlaceFromSheet(
            name: name,
            coord: latLng,
            isFrom: isFrom,
            fromAirportList: fromAirportList,
          );
          if (error != null) _showSnack(error);
        },
      ),
    );
  }

  Future<void> _openMapPicker(ServicesProvider p, {required bool isFrom}) async {
    final title = isFrom
        ? 'Select pickup location'
        : 'Select drop-off location';
    final polygons = await p.polygonsForMapPicker(isFrom: isFrom);
    if (!mounted) return;
    final result = await Navigator.of(context).push<PlacePickerResult?>(
      MaterialPageRoute(
        builder: (context) => MapPlacePickerPage(
          title: title,
          allowedPolygons: polygons.isEmpty ? null : polygons,
        ),
      ),
    );
    if (result != null && mounted) {
      if (isFrom) {
        p.applyPlaceFromMap(
          isFrom: true,
          placeName: result.placeName,
          latLng: result.latLng,
        );
      } else {
        final error = await p.checkDropOffAllowed(result.latLng);
        if (error != null) {
          _showSnack(error);
          return;
        }
        p.applyPlaceFromMap(
          isFrom: false,
          placeName: result.placeName,
          latLng: result.latLng,
        );
      }
    }
  }

  Future<void> _loadVehicleClasses(ServicesProvider p) async {
    final error = await p.loadVehicleClasses();
    if (error != null && mounted) _showSnack(error);
  }

  void _goToReviewTrip(ServicesProvider p) {
    final error = p.validateForReviewTrip();
    if (error != null) {
      _showSnack(error);
      return;
    }
    final args = p.buildReviewTripArgs();
    if (args != null) {
      AvisNavigation.push(context, AppRoutes.reviewTrip, arguments: args);
    }
  }

  void _showCurrencyPicker(BuildContext context, ServicesProvider p) {
    final options = p.currencyOptions;
    if (options.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextWidget(
                  'Select currency',
                  style: AppTextStyles.bodyLargeBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                ),
              ),
              ...List.generate(options.length, (i) {
                final item = options[i];
                final selected = i == p.selectedCurrencyIndex;
                final total = p.vehicleTotalForCurrency(item.currencyCode);
                return ListTile(
                  title: TextWidget(
                    '${item.currencyCode} - ${p.currencySymbol(item.currencyCode)}${total.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: selected
                          ? context.colors.primary
                          : context.colors.primaryText,
                    ),
                  ),
                  onTap: () {
                    p.selectCurrencyIndex(i);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ServicesProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const ServicePageBackgroundWidget(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (widget.showBackButton)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: const Row(
                          children: [BackArrowWidget()],
                        ),
                      ),
                    const SizedBox(height: 100),
                    if (p.loadingTripsType)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 20.w,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 12.h),
                              if (p.tripsTypeError != null)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextWidget(
                                          p.tripsTypeError!,
                                          style: AppTextStyles.bodyXSmall
                                              .copyWith(color: Colors.red),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: p.retryLoadTripsType,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              _buildServiceTypeTabs(context, p),
                              SizedBox(height: 20.h),
                              LocationFieldsWithSwapWidget(
                                fromPlaceName: p.fromPlaceName,
                                dropOffPlaceName: p.dropOffPlaceName,
                                onFromTap: () =>
                                    _showPlaceSelectionSheet(p, isFrom: true),
                                onDropOffTap: () {
                                  if (p.fromPlaceName.isEmpty) {
                                    _showSnack(
                                      'Please select pickup location first',
                                    );
                                    return;
                                  }
                                  _showPlaceSelectionSheet(p, isFrom: false);
                                },
                                onSwap: p.swapFromAndDropOff,
                                showDropOffAndSwap:
                                    p.selectedTripType?.allowDropOff ?? true,
                              ),
                              SizedBox(height: 16.h),
                              if (p.selectedTripType?.requiresHourDuration ??
                                  false) ...[
                                DurationSliderWidget(
                                  durationHours: p.durationHours,
                                  allowedHours: p.discreteHourlyDurations.isNotEmpty
                                      ? p.discreteHourlyDurations
                                      : null,
                                  maxHours:
                                      (p.selectedTripType
                                                  ?.displayCheckBoxIsByDay ??
                                              false) &&
                                          p.isFullDay
                                      ? 30
                                      : (p.selectedTripType
                                                ?.displayCheckBoxIsHalfDay ??
                                            false)
                                      ? 15
                                      : 11,
                                  isByDay:
                                      (p.selectedTripType
                                              ?.displayCheckBoxIsByDay ??
                                          false) &&
                                      p.isFullDay,
                                  onChanged: p.setDurationHours,
                                ),
                                SizedBox(height: 16.h),
                              ],
                              _buildDateAndTimeRow(context, p),
                              SizedBox(height: 16.h),
                              if (p.showRoundTripCheckbox ||
                                  p.showByDayCheckbox) ...[
                                _buildTripOptionCheckboxes(context, p),
                                SizedBox(height: 16.h),
                              ],
                              if (p.showsReturnDateTimeRow) ...[
                                _buildReturnDateAndTimeRow(context, p),
                                SizedBox(height: 24.h),
                              ],
                              _buildChooseVehicleSection(context, p),
                              SizedBox(height: 24.h),
                              AppButton.primary(
                                onPressed:
                                    p.vehicleClasses.isNotEmpty &&
                                        p.selectedVehicleClassIndex >= 0
                                    ? () => _goToReviewTrip(p)
                                    : null,
                                text: 'CONFIRM RIDE',
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripOptionCheckboxes(
    BuildContext context,
    ServicesProvider p,
  ) {
    Widget row({
      required bool value,
      required ValueChanged<bool?> onChanged,
      required String title,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: value,
                    onChanged: onChanged,
                    activeColor: context.colors.primary,
                  ),
                  Expanded(
                    child: TextWidget(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.colors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (p.showRoundTripCheckbox)
          row(
            value: p.roundTripCheckboxSelected,
            onChanged: p.onRoundTripCheckboxChanged,
            title: context.localized('Round trip', null),
          ),
        if (p.showByDayCheckbox)
          row(
            value: p.isFullDay,
            onChanged: (v) {
              if (v == null) return;
              p.setHourlyByDayMode(v);
            },
            title: context.localized('By day', null),
          ),
      ],
    );
  }

  Widget _buildServiceTypeTabs(BuildContext context, ServicesProvider p) {
    final list = p.visibleRootTripTypes;
    final labels = list.isNotEmpty
        ? list.map((e) => e.displayName).toList()
        : ServicesProvider.fallbackTabLabels;
    final count = labels.length;
    if (count == 0) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isSelected = p.selectedServiceTypeIndex == index;
          final label = labels[index];
          final iconName = p.iconNameForTabIndex(index, count);
          return Padding(
            padding: EdgeInsets.only(right: index < count - 1 ? 8.w : 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => p.selectServiceTypeIndex(index),
                borderRadius: BorderRadius.circular(AppCornerRadius.medium.r),
                child: Container(
                  height: 32.w,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  constraints: BoxConstraints(minWidth: 80.w),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.greyEF : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppCornerRadius.absolute,
                    ),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIconWidget(name: iconName, width: 16.r, height: 16.r),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: TextWidget(
                          label,
                          style: AppTextStyles.bodyXSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDateAndTimeRow(BuildContext context, ServicesProvider p) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppTextFormFieldComponent(
              controller: p.dateController,
              readOnly: true,
              onTap: () => _pickDate(context, p),
              focusedBorderSameAsEnabled: true,
              hintText: 'Pickup date',
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpaces.onSides,
                horizontal: AppSpaces.medium,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: SvgIconWidget(
                  name: 'calendar',
                  width: 20.w,
                  height: 20.w,
                  color: context.colors.secondaryText,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppTextFormFieldComponent(
              controller: p.timeController,
              readOnly: true,
              onTap: () => _pickTime(context, p),
              focusedBorderSameAsEnabled: true,
              hintText: 'Pickup time',
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpaces.onSides,
                horizontal: AppSpaces.medium,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: SvgIconWidget(
                  name: 'time',
                  width: 20.w,
                  height: 20.w,
                  color: context.colors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnDateAndTimeRow(BuildContext context, ServicesProvider p) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppTextFormFieldComponent(
              controller: p.returnDateController,
              readOnly: true,
              onTap: () => _pickReturnDate(context, p),
              focusedBorderSameAsEnabled: true,
              hintText: 'Return date',
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpaces.onSides,
                horizontal: AppSpaces.medium,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: SvgIconWidget(
                  name: 'calendar',
                  width: 20.w,
                  height: 20.w,
                  color: context.colors.secondaryText,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppTextFormFieldComponent(
              controller: p.returnTimeController,
              readOnly: true,
              onTap: () => _pickReturnTime(context, p),
              focusedBorderSameAsEnabled: true,
              hintText: 'Return time',
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpaces.onSides,
                horizontal: AppSpaces.medium,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: SvgIconWidget(
                  name: 'time',
                  width: 20.w,
                  height: 20.w,
                  color: context.colors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context, ServicesProvider p) {
    final options = p.currencyOptions;
    if (options.isEmpty) return const SizedBox.shrink();

    final selected =
        options[p.selectedCurrencyIndex.clamp(0, options.length - 1)];
    final selectedTotal = p.selectedVehicleTotalForCurrency;

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showCurrencyPicker(context, p),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: AppSpaces.medium,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.inputBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              TextWidget(
                'Currency: ${selected.currencyCode}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.colors.secondaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  selectedTotal != null
                      ? '${p.currencySymbol(selected.currencyCode)}${selectedTotal.toStringAsFixed(2)}'
                      : '',
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: context.colors.primaryText,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 24,
                color: context.colors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChooseVehicleSection(BuildContext context, ServicesProvider p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (p.currencyOptions.isNotEmpty) ...[
          _buildCurrencySelector(context, p),
          SizedBox(height: 12.h),
        ],
        TextWidget(
          'CHOOSE VEHICLE',
          style: AppTextStyles.bodySmallBold.copyWith(
            color: context.colors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        if (p.vehicleClasses.isEmpty && !p.loadingVehicleClasses)
          AppButton.primary(
            onPressed: () => _loadVehicleClasses(p),
            text: 'LOAD VEHICLE OPTIONS',
          )
        else if (p.loadingVehicleClasses)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: p.vehicleClasses.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              mainAxisExtent: 195.h,
            ),
            itemBuilder: (context, index) {
              final v = p.vehicleClasses[index];
              final option = VehicleOption(
                name: v.name,
                price: p.formattedVehiclePrice(v),
                eta: '',
                passengers: v.passengersNo,
                bags: v.suitcasesNo,
                imagePath: v.image ?? '',
                classMiniDesc: v.classMiniDesc,
              );
              final isSelected = p.selectedVehicleClassIndex == index;
              return ServiceOptionCard(
                option: option,
                isSelected: isSelected,
                onTap: () => p.selectVehicleClassIndex(index),
              );
            },
          ),
      ],
    );
  }
}
