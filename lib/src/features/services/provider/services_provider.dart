import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/review_trip/models/review_trip_page_args.dart';

class ServicesProvider extends ChangeNotifier {
  ServicesProvider(
    this._authLocalService,
    this._tripsTypeService,
    this._flightNamesService,
    this._customerSavedPlacesRepository,
    this._customerInfoService,
    this._latestTripRateService,
    this._airportsService,
    this._allowedPolygonsService,
    this._vehicleClassesPriceService,
  ) {
    dateController = TextEditingController(text: dateFormat.format(selectedDate));
    timeController = TextEditingController(text: timeText);
    flightNumberController = TextEditingController();
    flightDateController = TextEditingController(
      text: dateTimeFormat.format(selectedFlightDate),
    );
    returnDate = DateTime.now().add(const Duration(days: 1));
    returnTime = const TimeOfDay(hour: 10, minute: 0);
    returnDateController = TextEditingController(
      text: dateFormat.format(returnDate),
    );
    returnTimeController = TextEditingController(
      text: timeFormat.format(
        DateTime(2000, 1, 1, returnTime.hour, returnTime.minute),
      ),
    );
  }

  final AuthLocalService _authLocalService;
  final TripsTypeService _tripsTypeService;
  final FlightNamesService _flightNamesService;
  final CustomerSavedPlacesRepository _customerSavedPlacesRepository;
  final CustomerInfoService _customerInfoService;
  final LatestTripRateService _latestTripRateService;
  final AirportsService _airportsService;
  final AllowedPolygonsService _allowedPolygonsService;
  final VehicleClassesPriceService _vehicleClassesPriceService;

  static final DateFormat dateFormat = DateFormat('EEE, d MMM');
  static final DateFormat timeFormat = DateFormat('hh:mm a');
  static final DateFormat dateTimeFormat = DateFormat('EEE, d MMM, hh:mm a');

  static const List<String> fallbackTabLabels = [
    'City to City',
    'Airport',
    'Hourly',
  ];

  int selectedServiceTypeIndex = 0;
  int selectedVehicleIndex = 0;
  int durationHours = 3;
  bool isFullDay = false;
  bool roundTripCheckboxSelected = false;
  bool isHalfDay = false;

  List<TripTypeWithConfigModel> tripTypes = [];
  bool loadingTripsType = true;
  String? tripsTypeError;

  List<FlightNameModel> flightNames = [];
  bool loadingFlightNames = false;
  FlightNameModel? selectedFlightName;

  List<CustomerSavedPlaceModel> savedPlaces = [];
  List<AirportModel> airports = [];
  CustomerInfoModel? customerInfo;

  List<VehicleClassPriceModel> vehicleClasses = [];
  int selectedVehicleClassIndex = -1;
  int selectedCurrencyIndex = 0;
  bool loadingVehicleClasses = false;
  int pickupZoneId = 0;
  int dropZoneId = 0;

  List<List<LatLng>> allowedPolygons = [];

  String fromPlaceName = '';
  String dropOffPlaceName = '';
  LatLng? fromLatLng;
  LatLng? dropOffLatLng;
  bool pickupFromAirportList = false;
  bool dropOffFromAirportList = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedFlightDate = DateTime.now();
  DateTime returnDate = DateTime.now();
  TimeOfDay returnTime = const TimeOfDay(hour: 10, minute: 0);

  late final TextEditingController dateController;
  late final TextEditingController timeController;
  late final TextEditingController flightNumberController;
  late final TextEditingController flightDateController;
  late final TextEditingController returnDateController;
  late final TextEditingController returnTimeController;

  LatestTripRateModel? pendingRatingTrip;

  bool _disposed = false;

  int get effectiveBranchId {
    final id = customerInfo?.clientbranchId;
    if (id == null || id < 1) return 1;
    return id;
  }

  List<TripTypeWithConfigModel> get allTripTypeNodes {
    return tripTypes.expand((e) => e.preorderNodes).toList();
  }

  List<TripTypeWithConfigModel> get visibleRootTripTypes {
    final list = tripTypes.where((e) => e.isVisible).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  TripTypeWithConfigModel? get selectedRootTripType {
    final roots = visibleRootTripTypes;
    if (roots.isEmpty) return null;
    var i = selectedServiceTypeIndex;
    if (i < 0 || i >= roots.length) i = 0;
    return roots[i];
  }

  TripTypeWithConfigModel? get selectedTripType => selectedRootTripType;

  int get bookingTripTypeId => selectedTripType?.id ?? 1;

  List<int> get discreteHourlyDurations {
    if (!(selectedTripType?.requiresHourDuration ?? false)) return const [];
    if ((selectedTripType?.displayCheckBoxIsByDay ?? false) && isFullDay) {
      return const [];
    }
    return parseAvailableNumberOfHours(
      selectedTripType?.availableNumberOfHours,
    );
  }

  bool get showByDayCheckbox =>
      selectedRootTripType?.displayCheckBoxIsByDay == true;

  bool get showRoundTripCheckbox =>
      selectedRootTripType?.displayCheckBoxIsRoundTrip == true;

  bool get showsReturnDateTimeRow =>
      showRoundTripCheckbox && roundTripCheckboxSelected;

  DateTime get selectedReturnDateTime => DateTime(
    returnDate.year,
    returnDate.month,
    returnDate.day,
    returnTime.hour,
    returnTime.minute,
  );

  String get returnTripDateTimeApiString {
    final d = returnDate;
    final t = returnTime;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  }

  List<TimeOfDay> get availableReturnTimeSlots {
    final pickup = selectedPickupDateTime;
    final retDay = DateTime(returnDate.year, returnDate.month, returnDate.day);
    final pickupDay = DateTime(pickup.year, pickup.month, pickup.day);
    if (retDay.isBefore(pickupDay)) return [];
    final all = allTimeSlotsToday;
    if (retDay.isAfter(pickupDay)) return all;
    final pm = pickup.hour * 60 + pickup.minute;
    return all.where((t) => t.hour * 60 + t.minute > pm).toList();
  }

  DateTime? get latestAllowedReturnCalendarDate {
    if (!showsReturnDateTimeRow) return null;
    final trip = selectedTripType;
    final rule = trip?.returnDateRule ?? 0;
    final pickup = selectedPickupDateTime;
    final pickupDay = DateTime(pickup.year, pickup.month, pickup.day);

    if (rule == 1) return pickupDay;
    if (rule == 2) {
      final maxDays = trip?.maxDurationForReturnDateByHour ?? 0;
      if (maxDays <= 0) return null;
      return pickupDay.add(Duration(days: maxDays));
    }
    final maxDays = trip?.maxDurationForReturnDateByHour ?? 0;
    if (maxDays <= 0) return null;
    return pickupDay.add(Duration(days: maxDays));
  }

  String get timeText => timeFormat.format(
    DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
  );

  DateTime get selectedPickupDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  DateTime get minBookingDateTime {
    final hours = selectedTripType?.minHoursBeforeReservation ?? 0;
    return DateTime.now().add(Duration(hours: hours));
  }

  DateTime get minBookingDate => DateTime(
    minBookingDateTime.year,
    minBookingDateTime.month,
    minBookingDateTime.day,
  );

  bool get isSelectedDateMinDate =>
      selectedDate.year == minBookingDate.year &&
      selectedDate.month == minBookingDate.month &&
      selectedDate.day == minBookingDate.day;

  TimeOfDay get minBookingTimeOfDay => TimeOfDay(
    hour: minBookingDateTime.hour,
    minute: minBookingDateTime.minute,
  );

  int get timeSlotMinutes => selectedTripType?.timeSlotByMin ?? 30;

  List<TimeOfDay> get allTimeSlotsToday {
    final slotMin = timeSlotMinutes;
    if (slotMin <= 0) return [];
    final list = <TimeOfDay>[];
    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += slotMin) {
        list.add(TimeOfDay(hour: h, minute: m));
      }
    }
    return list;
  }

  List<TimeOfDay> get availableTimeSlots {
    final all = allTimeSlotsToday;
    if (!isSelectedDateMinDate) return all;
    final first = firstSlotAtOrAfter(minBookingTimeOfDay);
    return all.where((t) => !timeOfDayIsBefore(t, first)).toList();
  }

  String get tripDateTimeApiString {
    final d = selectedDate;
    final t = selectedTime;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  }

  DateTime get pickDateFirstDate => minBookingDate;

  DateTime get pickDateInitialDate =>
      selectedDate.isBefore(minBookingDate) ? minBookingDate : selectedDate;

  DateTime get pickFlightDateFirstDate {
    final pickup = selectedPickupDateTime;
    return DateTime(pickup.year, pickup.month, pickup.day);
  }

  DateTime get pickFlightDateInitialDate {
    final first = pickFlightDateFirstDate;
    return selectedFlightDate.isBefore(first) ? first : selectedFlightDate;
  }

  DateTime get returnDatePickerFirstDate {
    final pickup = selectedPickupDateTime;
    return DateTime(pickup.year, pickup.month, pickup.day);
  }

  List<VehicleClassDisplayPrice> get currencyOptions =>
      vehicleClasses.isNotEmpty && vehicleClasses.first.displayPrices.isNotEmpty
      ? vehicleClasses.first.displayPrices
      : const [];

  String get selectedCurrencyCode {
    final options = currencyOptions;
    if (options.isEmpty) return 'USD';
    final index = selectedCurrencyIndex.clamp(0, options.length - 1);
    return options[index].currencyCode;
  }

  double? get selectedVehicleTotalForCurrency {
    if (selectedVehicleClassIndex < 0 ||
        selectedVehicleClassIndex >= vehicleClasses.length) {
      return null;
    }
    return vehicleTotalForCurrency(selectedCurrencyCode);
  }

  static List<int> parseAvailableNumberOfHours(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    final out = <int>[];
    for (final part in raw.split(',')) {
      final v = int.tryParse(part.trim());
      if (v != null && v > 0) out.add(v);
    }
    return out;
  }

  void initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadTripsTypeWithConfig();
      loadCustomerSavedPlaces();
      loadCustomerInfo();
      loadCheckLatestTripRate();
      loadAirports();
      loadAllowedPolygons();
    });
  }

  void retryLoadTripsType() {
    loadingTripsType = true;
    tripsTypeError = null;
    _notify();
    loadTripsTypeWithConfig();
  }

  DateTime returnDatePickerLastDate(DateTime pickupFirstDate) {
    final cap = latestAllowedReturnCalendarDate;
    final farFuture = DateTime.now().add(const Duration(days: 365));
    var last = cap != null && cap.isBefore(farFuture) ? cap : farFuture;
    if (last.isBefore(pickupFirstDate)) last = pickupFirstDate;
    return last;
  }

  DateTime returnDatePickerInitialDate(DateTime firstDate, DateTime lastDate) {
    var initial = returnDate.isBefore(firstDate) ? firstDate : returnDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    return initial;
  }

  static bool timeOfDayIsBefore(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour < b.hour;
    return a.minute < b.minute;
  }

  TimeOfDay firstSlotAtOrAfter(TimeOfDay min) {
    final slotMin = timeSlotMinutes;
    if (slotMin <= 0) return min;
    final m = min.hour * 60 + min.minute;
    final slot = ((m + slotMin - 1) ~/ slotMin) * slotMin;
    final h = (slot ~/ 60) % 24;
    final mn = slot % 60;
    return TimeOfDay(hour: h, minute: mn);
  }

  TimeOfDay snapToNearestSlot(TimeOfDay t) {
    final slotMin = timeSlotMinutes;
    if (slotMin <= 0) return t;
    final m = t.hour * 60 + t.minute;
    final slot = (m / slotMin).round() * slotMin;
    final h = (slot ~/ 60) % 24;
    final mn = slot % 60;
    return TimeOfDay(hour: h, minute: mn);
  }

  bool returnIsStrictlyAfterPickup() =>
      selectedReturnDateTime.isAfter(selectedPickupDateTime);

  void syncDurationHoursToDiscreteOptions() {
    final opts = discreteHourlyDurations;
    if (opts.isEmpty) return;
    if (!opts.contains(durationHours)) {
      durationHours = opts.first;
    }
  }

  void clampDateAndTimeToMinBooking() {
    final min = minBookingDateTime;
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (selected.isBefore(min)) {
      selectedDate = minBookingDate;
      selectedTime = firstSlotAtOrAfter(minBookingTimeOfDay);
      dateController.text = dateFormat.format(selectedDate);
      timeController.text = timeFormat.format(
        DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
      );
      invalidateVehicleList();
    } else {
      selectedTime = snapToNearestSlot(selectedTime);
      timeController.text = timeFormat.format(
        DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
      );
    }
    ensureReturnAfterPickup();
    _notify();
  }

  void ensureFlightDateAfterPickup() {
    final minFlightDateTime = selectedPickupDateTime.add(
      const Duration(minutes: 1),
    );
    if (!selectedFlightDate.isAfter(selectedPickupDateTime)) {
      selectedFlightDate = minFlightDateTime;
      flightDateController.text = dateTimeFormat.format(selectedFlightDate);
      _notify();
    }
  }

  void clampReturnDateToMaxDurationWindow() {
    if (!showsReturnDateTimeRow) return;
    final latest = latestAllowedReturnCalendarDate;
    if (latest == null) return;
    final retDay = DateTime(returnDate.year, returnDate.month, returnDate.day);
    if (!retDay.isAfter(latest)) return;
    returnDate = DateTime(latest.year, latest.month, latest.day);
    if (!availableReturnTimeSlots.any(
      (t) => t.hour == returnTime.hour && t.minute == returnTime.minute,
    )) {
      final slots = availableReturnTimeSlots;
      if (slots.isNotEmpty) {
        returnTime = slots.first;
      }
    }
  }

  void bumpReturnUntilStrictlyAfterPickup() {
    if (returnIsStrictlyAfterPickup()) return;
    final slot = timeSlotMinutes > 0 ? timeSlotMinutes : 30;
    var dt = selectedPickupDateTime.add(Duration(minutes: slot));
    returnDate = DateTime(dt.year, dt.month, dt.day);
    returnTime = snapToNearestSlot(
      TimeOfDay(hour: dt.hour, minute: dt.minute),
    );
    if (!returnIsStrictlyAfterPickup()) {
      dt = selectedPickupDateTime.add(Duration(minutes: slot * 2));
      returnDate = DateTime(dt.year, dt.month, dt.day);
      returnTime = snapToNearestSlot(
        TimeOfDay(hour: dt.hour, minute: dt.minute),
      );
    }
  }

  void ensureReturnAfterPickup() {
    if (!showsReturnDateTimeRow) return;
    clampReturnDateToMaxDurationWindow();
    if (!returnIsStrictlyAfterPickup()) {
      bumpReturnUntilStrictlyAfterPickup();
    }
    clampReturnDateToMaxDurationWindow();
    if (!returnIsStrictlyAfterPickup()) {
      bumpReturnUntilStrictlyAfterPickup();
      clampReturnDateToMaxDurationWindow();
    }
    returnDateController.text = dateFormat.format(returnDate);
    returnTimeController.text = timeFormat.format(
      DateTime(2000, 1, 1, returnTime.hour, returnTime.minute),
    );
    _notify();
  }

  void invalidateVehicleList() {
    vehicleClasses = [];
    selectedVehicleClassIndex = -1;
    selectedCurrencyIndex = 0;
    _notify();
  }

  void swapFromAndDropOff() {
    final from = fromPlaceName;
    fromPlaceName = dropOffPlaceName;
    dropOffPlaceName = from;
    final fromCoord = fromLatLng;
    fromLatLng = dropOffLatLng;
    dropOffLatLng = fromCoord;
    final pickupAirport = pickupFromAirportList;
    pickupFromAirportList = dropOffFromAirportList;
    dropOffFromAirportList = pickupAirport;
    invalidateVehicleList();
  }

  void resetFormValues() {
    fromPlaceName = '';
    dropOffPlaceName = '';
    fromLatLng = null;
    dropOffLatLng = null;
    pickupFromAirportList = false;
    dropOffFromAirportList = false;
    selectedDate = DateTime.now();
    selectedTime = snapToNearestSlot(TimeOfDay.now());
    dateController.text = dateFormat.format(selectedDate);
    timeController.text = timeFormat.format(
      DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
    );
    flightNumberController.clear();
    selectedFlightName = null;
    selectedFlightDate = DateTime.now();
    flightDateController.text = dateTimeFormat.format(selectedFlightDate);
    durationHours = 3;
    vehicleClasses = [];
    selectedVehicleClassIndex = -1;
    selectedVehicleIndex = 0;
    returnDate = DateTime.now().add(const Duration(days: 1));
    returnTime = const TimeOfDay(hour: 10, minute: 0);
    returnDateController.text = dateFormat.format(returnDate);
    returnTimeController.text = timeFormat.format(
      DateTime(2000, 1, 1, returnTime.hour, returnTime.minute),
    );
    roundTripCheckboxSelected = false;
    syncDurationHoursToDiscreteOptions();
    _notify();
  }

  void setHourlyByDayMode(bool byDay) {
    isFullDay = byDay;
    if (!isFullDay) {
      final opts = discreteHourlyDurations;
      if (opts.isNotEmpty) {
        if (!opts.contains(durationHours)) {
          durationHours = opts.first;
        }
      } else {
        final maxH = (selectedTripType?.displayCheckBoxIsHalfDay ?? false)
            ? 15
            : 11;
        if (durationHours > maxH) {
          durationHours = maxH;
        }
      }
    }
    invalidateVehicleList();
  }

  void onRoundTripCheckboxChanged(bool? value) {
    if (value == null) return;
    roundTripCheckboxSelected = value;
    syncDurationHoursToDiscreteOptions();
    clampDateAndTimeToMinBooking();
    invalidateVehicleList();
    if (value) {
      ensureReturnAfterPickup();
    } else {
      _notify();
    }
  }

  void selectServiceTypeIndex(int index) {
    if (index == selectedServiceTypeIndex) return;
    selectedServiceTypeIndex = index;
    resetFormValues();
    clampDateAndTimeToMinBooking();
  }

  void setDurationHours(int v) {
    durationHours = v;
    if (discreteHourlyDurations.isEmpty) {
      if (!isFullDay && durationHours > 11) {
        isHalfDay = true;
      } else {
        isHalfDay = false;
      }
    }
    invalidateVehicleList();
  }

  void selectVehicleClassIndex(int index) {
    selectedVehicleClassIndex = index;
    _notify();
  }

  void selectCurrencyIndex(int index) {
    selectedCurrencyIndex = index;
    _notify();
  }

  void applyPickedDate(DateTime picked) {
    selectedDate = picked;
    if (isSelectedDateMinDate &&
        timeOfDayIsBefore(selectedTime, minBookingTimeOfDay)) {
      selectedTime = firstSlotAtOrAfter(minBookingTimeOfDay);
      timeController.text = timeFormat.format(
        DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
      );
    } else {
      selectedTime = snapToNearestSlot(selectedTime);
      timeController.text = timeFormat.format(
        DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
      );
    }
    dateController.text = dateFormat.format(selectedDate);
    ensureFlightDateAfterPickup();
    ensureReturnAfterPickup();
    invalidateVehicleList();
  }

  void applyPickedTime(TimeOfDay slot) {
    selectedTime = slot;
    timeController.text = timeFormat.format(
      DateTime(2000, 1, 1, slot.hour, slot.minute),
    );
    ensureFlightDateAfterPickup();
    ensureReturnAfterPickup();
    invalidateVehicleList();
  }

  void applyPickedReturnDate(DateTime picked) {
    returnDate = picked;
    returnDateController.text = dateFormat.format(returnDate);
    if (!availableReturnTimeSlots.any(
      (t) => t.hour == returnTime.hour && t.minute == returnTime.minute,
    )) {
      final slots = availableReturnTimeSlots;
      if (slots.isNotEmpty) {
        returnTime = slots.first;
        returnTimeController.text = timeFormat.format(
          DateTime(2000, 1, 1, returnTime.hour, returnTime.minute),
        );
      }
    }
    ensureReturnAfterPickup();
    invalidateVehicleList();
  }

  void applyPickedReturnTime(TimeOfDay slot) {
    returnTime = slot;
    returnTimeController.text = timeFormat.format(
      DateTime(2000, 1, 1, slot.hour, slot.minute),
    );
    invalidateVehicleList();
  }

  String? applyFlightDateTime(DateTime pickedFlightDateTime) {
    if (!pickedFlightDateTime.isAfter(selectedPickupDateTime)) {
      return 'Flight time must be after pickup time';
    }
    selectedFlightDate = pickedFlightDateTime;
    flightDateController.text = dateTimeFormat.format(selectedFlightDate);
    _notify();
    return null;
  }

  void applyPlaceFromMap({
    required bool isFrom,
    required String placeName,
    required LatLng latLng,
  }) {
    if (isFrom) {
      fromPlaceName = placeName;
      fromLatLng = latLng;
      pickupFromAirportList = false;
      invalidateVehicleList();
      return;
    }
    dropOffPlaceName = placeName;
    dropOffLatLng = latLng;
    dropOffFromAirportList = false;
    invalidateVehicleList();
  }

  Future<String?> applyPlaceFromSheet({
    required String name,
    required LatLng? coord,
    required bool isFrom,
    bool fromAirportList = false,
  }) async {
    if (isFrom) {
      fromPlaceName = name;
      fromLatLng = coord;
      pickupFromAirportList = fromAirportList;
      invalidateVehicleList();
      return null;
    }
    if (coord != null && fromLatLng != null) {
      final error = await checkDropOffAllowed(coord);
      if (error != null) return error;
    }
    dropOffPlaceName = name;
    dropOffLatLng = coord;
    dropOffFromAirportList = fromAirportList;
    invalidateVehicleList();
    return null;
  }

  Future<void> loadAllowedPolygons() async {
    final result = await _allowedPolygonsService.getAllowedPolygonsAreas();
    if (_disposed) return;
    if (result.isSuccess && result.data.isNotEmpty) {
      allowedPolygons = AllowedPolygonPointModel.toPolygons(result.data);
      _notify();
    }
  }

  Future<void> loadAirports() async {
    final result = await _airportsService.getAirports();
    if (_disposed) return;
    if (result.isSuccess) {
      airports = result.data;
      _notify();
    }
  }

  Future<LatestTripRateModel?> loadCheckLatestTripRate() async {
    final customerId =
        _authLocalService.getUserId() ?? AppConst.fallbackCustomerId;
    final result = await _latestTripRateService.checkLatestTripRate(customerId);
    if (_disposed) return null;
    if (result.isSuccess &&
        result.data.tripId != 0 &&
        !result.data.isRatedByCustomer) {
      pendingRatingTrip = result.data;
      _notify();
      return result.data;
    }
    pendingRatingTrip = null;
    return null;
  }

  void clearPendingRatingTrip() {
    pendingRatingTrip = null;
    _notify();
  }

  Future<void> loadCustomerInfo() async {
    final customerId =
        _authLocalService.getUserId() ?? AppConst.fallbackCustomerId;
    final result = await _customerInfoService.getCustomerInfo(customerId);
    if (_disposed) return;
    if (result.isSuccess) {
      customerInfo = result.data;
      _notify();
    }
  }

  Future<void> loadCustomerSavedPlaces() async {
    final customerId =
        _authLocalService.getUserId() ?? AppConst.fallbackCustomerId;

    String lat = '';
    String lng = '';
    try {
      if (await Geolocator.isLocationServiceEnabled() &&
          (await Geolocator.checkPermission() == LocationPermission.whileInUse ||
              await Geolocator.checkPermission() == LocationPermission.always)) {
        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude.toString();
        lng = pos.longitude.toString();
      }
    } catch (_) {}

    final params = GetCustomerSavedPlacesParams(
      customerId: customerId,
      latitude: lat,
      longtitude: lng,
    );
    final result = await _customerSavedPlacesRepository.getCustomerSavedPlaces(
      params,
    );
    if (_disposed) return;
    result.when(
      success: (places) {
        savedPlaces = places;
        _notify();
      },
      failure: (_) {
        savedPlaces = [];
        _notify();
      },
    );
  }

  Future<void> loadTripsTypeWithConfig() async {
    final result = await _tripsTypeService.getTripsTypeWithConfig();
    if (_disposed) return;
    loadingTripsType = false;
    if (result.isSuccess && result.data.isNotEmpty) {
      tripTypes = result.data;
      tripsTypeError = null;
      if (selectedServiceTypeIndex >= visibleRootTripTypes.length) {
        selectedServiceTypeIndex = 0;
      }
      roundTripCheckboxSelected = false;
      syncDurationHoursToDiscreteOptions();
      final needsFlightNames = allTripTypeNodes.any(
        (t) => t.isVisible && t.requiresFlightName,
      );
      if (needsFlightNames && flightNames.isEmpty) {
        loadFlightNames('ar');
      }
      final needsAirports = allTripTypeNodes.any(
        (t) => t.isVisible && t.requiresFlightNumber,
      );
      if (needsAirports && airports.isEmpty) {
        loadAirports();
      }
      clampDateAndTimeToMinBooking();
    } else {
      tripsTypeError = result.errorMessage;
      tripTypes = [];
      _notify();
    }
  }

  Future<void> loadFlightNames(String language) async {
    if (loadingFlightNames) return;
    loadingFlightNames = true;
    _notify();
    final result = await _flightNamesService.getFlightNames(language);
    if (_disposed) return;
    loadingFlightNames = false;
    if (result.isSuccess && result.data.isNotEmpty) {
      flightNames = result.data;
    }
    _notify();
  }

  Future<String?> loadVehicleClasses() async {
    if (loadingVehicleClasses) return null;
    final requireDropOff = selectedTripType?.allowDropOff ?? true;
    if (fromPlaceName.isEmpty ||
        (requireDropOff && dropOffPlaceName.isEmpty)) {
      return requireDropOff
          ? 'Please select pickup and drop-off locations'
          : 'Please select pickup location';
    }
    if (fromLatLng == null) {
      return 'Please select pickup location';
    }
    loadingVehicleClasses = true;
    _notify();
    final tripTypeId = bookingTripTypeId;
    log('Load vehicle: tripTypeId=$tripTypeId', name: 'ServicesProvider');
    final double dlat;
    final double dlong;
    if (requireDropOff && dropOffLatLng != null) {
      dlat = dropOffLatLng!.latitude;
      dlong = dropOffLatLng!.longitude;
    } else {
      dlat = 0;
      dlong = 0;
    }
    final zoneResponse = await _allowedPolygonsService
        .checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId(
          platitude: fromLatLng!.latitude,
          plongtitude: fromLatLng!.longitude,
          tripTypeId: tripTypeId,
          dlatitude: dlat,
          dlongtitude: dlong,
        );
    if (_disposed) return null;
    if (requireDropOff &&
        (!zoneResponse.isSuccess || !zoneResponse.data.isAllowed)) {
      loadingVehicleClasses = false;
      _notify();
      return zoneResponse.data.primaryMessage ??
          zoneResponse.data.secondaryMessage ??
          zoneResponse.errorMessage ??
          'This drop-off location is not allowed for the selected pickup.';
    }
    final newPickupZoneId = zoneResponse.data.pickupZoneId ?? 0;
    final newDropZoneId = zoneResponse.data.dropZoneId ?? 0;
    final customerId =
        _authLocalService.getUserId() ?? AppConst.fallbackCustomerId;
    final request = VehicleClassesPriceRequest(
      tripId: tripTypeId,
      customerId: customerId,
      hoursCount: durationHours,
      tripHours: durationHours,
      companyCustomerId: null,
      branchId: effectiveBranchId,
      tripDateTime: tripDateTimeApiString,
      returnTripDateTime: showsReturnDateTimeRow ? returnTripDateTimeApiString : null,
      fromCityId: newPickupZoneId,
      toCityId: newDropZoneId,
      tripDays: 0,
      isHalfDay: isHalfDay,
      isRoundTrip: showsReturnDateTimeRow,
      isPerDay: (selectedTripType?.displayCheckBoxIsByDay ?? false) && isFullDay,
      isDropoffAirport: requireDropOff && dropOffFromAirportList,
    );
    final result = await _vehicleClassesPriceService
        .getVehicleClassesPriceByTripType(request);
    if (_disposed) return null;
    loadingVehicleClasses = false;
    pickupZoneId = newPickupZoneId;
    dropZoneId = newDropZoneId;
    if (result.isSuccess && result.data.isNotEmpty) {
      vehicleClasses = result.data;
      selectedVehicleClassIndex = 0;
      selectedCurrencyIndex = 0;
      _notify();
      return null;
    }
    _notify();
    return result.errorMessage ?? 'Could not load vehicle options. Try again.';
  }

  Future<String?> checkDropOffAllowed(LatLng dropLatLng) async {
    if (fromLatLng == null) return null;
    final tripTypeId = bookingTripTypeId;
    final response = await _allowedPolygonsService
        .checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId(
          platitude: fromLatLng!.latitude,
          plongtitude: fromLatLng!.longitude,
          tripTypeId: tripTypeId,
          dlatitude: dropLatLng.latitude,
          dlongtitude: dropLatLng.longitude,
        );
    if (!response.isSuccess || !response.data.isAllowed) {
      return response.data.primaryMessage ??
          response.data.secondaryMessage ??
          response.errorMessage ??
          'This drop-off location is not allowed for the selected pickup.';
    }
    return null;
  }

  Future<List<List<LatLng>>> polygonsForMapPicker({required bool isFrom}) async {
    if (!isFrom && fromLatLng != null) {
      final tripTypeId = bookingTripTypeId;
      final response = await _allowedPolygonsService
          .findAllowedAreasPolygonByPickupCordTripId(
            platitude: fromLatLng!.latitude,
            plongtitude: fromLatLng!.longitude,
            tripTypeId: tripTypeId,
          );
      return (response.isSuccess && response.data.isNotEmpty)
          ? AllowedPolygonPointModel.toPolygons(response.data)
          : <List<LatLng>>[];
    }
    return allowedPolygons;
  }

  String? validateForReviewTrip() {
    if (vehicleClasses.isEmpty || selectedVehicleClassIndex < 0) {
      return 'Please load vehicle options and select a vehicle';
    }
    final requireDropOff = selectedTripType?.allowDropOff ?? true;
    if (fromPlaceName.isEmpty ||
        (requireDropOff && dropOffPlaceName.isEmpty)) {
      return requireDropOff
          ? 'Please select pickup and drop-off locations'
          : 'Please select pickup location';
    }
    if (showsReturnDateTimeRow && !returnIsStrictlyAfterPickup()) {
      return 'Return date and time must be after pickup';
    }
    return null;
  }

  ReviewTripPageArgs? buildReviewTripArgs() {
    final error = validateForReviewTrip();
    if (error != null) return null;
    final requireDropOff = selectedTripType?.allowDropOff ?? true;
    final selectedVehicle = vehicleClasses[selectedVehicleClassIndex]
        .withCurrency(selectedCurrencyCode);
    return ReviewTripPageArgs(
      vehicles: [selectedVehicle],
      fromPlaceName: fromPlaceName,
      dropOffPlaceName: requireDropOff ? dropOffPlaceName : '',
      date: dateFormat.format(selectedDate),
      time: timeFormat.format(
        DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
      ),
      tripTypeConfig: selectedTripType,
      pickupLatLng: fromLatLng,
      dropOffLatLng: requireDropOff ? dropOffLatLng : null,
      tripTypeId: bookingTripTypeId,
      branchId: effectiveBranchId,
      durationHours: durationHours,
      fromZoneId: pickupZoneId,
      toZoneId: dropZoneId,
      tripDateTimeApiString: tripDateTimeApiString,
      hasFlightInfo: false,
      isByDay: (selectedTripType?.displayCheckBoxIsByDay ?? false) && isFullDay,
      isDropoffAirport: requireDropOff ? dropOffFromAirportList : false,
      isHalfDay: isHalfDay,
      isRoundTrip: showsReturnDateTimeRow,
      returnDate: showsReturnDateTimeRow ? dateFormat.format(returnDate) : null,
      returnTime: showsReturnDateTimeRow
          ? timeFormat.format(
              DateTime(2000, 1, 1, returnTime.hour, returnTime.minute),
            )
          : null,
      returnTripDateTimeApiString:
          showsReturnDateTimeRow ? returnTripDateTimeApiString : null,
      totalLoyalityPoints: customerInfo?.totalLoyalityPoints ?? 0,
      maxRedeemablePoints: customerInfo?.maxRedeemablePoints ?? 0,
      minimumPointsValueForTransfer:
          customerInfo?.minimumPointsValueForTransfer ?? 0,
      currencyCode: selectedCurrencyCode,
    );
  }

  String iconNameForTabIndex(int index, int count) {
    if (count <= 3) {
      if (index == 0) return 'city to city';
      if (index == 1) return 'Airport';
      return 'Hourly';
    }
    final list = visibleRootTripTypes;
    if (index < list.length) {
      final name = list[index].primaryName?.toLowerCase() ?? '';
      if (name.contains('airport')) return 'Airport';
      if (name.contains('hour') || name.contains('hourly')) return 'Hourly';
    }
    return 'city to city';
  }

  double vehicleTotalForCurrency(String currencyCode) {
    if (selectedVehicleClassIndex >= 0 &&
        selectedVehicleClassIndex < vehicleClasses.length) {
      final vehicle = vehicleClasses[selectedVehicleClassIndex];
      final displayPrice = vehicle.priceForCurrency(currencyCode);
      if (displayPrice != null) return displayPrice.total;
      return vehicle.total;
    }
    if (vehicleClasses.isNotEmpty) {
      final displayPrice = vehicleClasses.first.priceForCurrency(currencyCode);
      if (displayPrice != null) return displayPrice.total;
      return vehicleClasses.first.total;
    }
    return 0;
  }

  String formattedVehiclePrice(VehicleClassPriceModel vehicle) {
    final displayPrice = vehicle.priceForCurrency(selectedCurrencyCode);
    if (displayPrice != null) {
      return '${currencySymbol(displayPrice.currencyCode)}${displayPrice.total.toStringAsFixed(2)}';
    }
    return '\$${vehicle.total.toStringAsFixed(2)}';
  }

  String currencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'JOD':
        return 'JOD ';
      case 'EGP':
        return 'EGP ';
      default:
        return '$code ';
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    dateController.dispose();
    timeController.dispose();
    flightNumberController.dispose();
    flightDateController.dispose();
    returnDateController.dispose();
    returnTimeController.dispose();
    super.dispose();
  }
}
