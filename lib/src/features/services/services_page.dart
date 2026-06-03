import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../_features.dart';
import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/review_trip/models/review_trip_page_args.dart';
import 'map_place_picker_page.dart';
import 'place_picker_result.dart';
import 'place_selection_sheet.dart';

/// Services / booking page using system components.
/// Layout: header, service type tabs, from/drop-off inputs, date/time, vehicle options, confirm button.
class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key, this.showBackButton = false});

  /// When true, a back button is shown at the top. Pass from outside (e.g. route arguments).
  final bool showBackButton;

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int _selectedServiceTypeIndex = 0;
  int _selectedVehicleIndex = 0;
  int _durationHours = 3;
  bool _isFullDay = false;
  /// Return leg UI when [TripTypeWithConfigModel.displayCheckBoxIsRoundTrip] is true and user checks the box.
  bool _roundTripCheckboxSelected = false;
  bool isHalfDay = false;

  List<TripTypeWithConfigModel> _tripTypes = [];
  bool _loadingTripsType = true;
  String? _tripsTypeError;

  List<FlightNameModel> _flightNames = [];
  bool _loadingFlightNames = false;
  FlightNameModel? _selectedFlightName;

  List<CustomerSavedPlaceModel> _savedPlaces = [];
  List<AirportModel> _airports = [];
  CustomerInfoModel? _customerInfo;

  /// [CustomerInfoModel.clientbranchId] is often 0 when unset; Vehicle APIs require a positive branch (default 1).
  int get _effectiveBranchId {
    final id = _customerInfo?.clientbranchId;
    if (id == null || id < 1) return 1;
    return id;
  }

  List<VehicleClassPriceModel> _vehicleClasses = [];
  int _selectedVehicleClassIndex = -1;
  int _selectedCurrencyIndex = 0;
  bool _loadingVehicleClasses = false;
  int _pickupZoneId = 0;
  int _dropZoneId = 0;

  /// Polygon areas from GetAllowedPolygonsAreas; passed to map picker to restrict selection.
  List<List<LatLng>> _allowedPolygons = [];

  String _fromPlaceName = '';
  String _dropOffPlaceName = '';
  LatLng? _fromLatLng;
  LatLng? _dropOffLatLng;
  /// Set when pickup was chosen from the airport list (for swap with drop-off airport flag).
  bool _pickupFromAirportList = false;
  /// Set when drop-off was chosen from the airport list; sent as IsDropoffAirport on pricing/booking APIs.
  bool _dropOffFromAirportList = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _flightNumberController;
  late final TextEditingController _flightDateController;

  DateTime _selectedFlightDate = DateTime.now();

  DateTime _returnDate = DateTime.now();
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);
  late final TextEditingController _returnDateController;
  late final TextEditingController _returnTimeController;

  /// Flattened tree: roots from API plus every nested [TripTypeWithConfigModel.children].
  List<TripTypeWithConfigModel> get _allTripTypeNodes {
    return _tripTypes.expand((e) => e.preorderNodes).toList();
  }

  /// Top-level trip types only (tabs). Config and booking use the selected root only.
  List<TripTypeWithConfigModel> get _visibleRootTripTypes {
    final list = _tripTypes.where((e) => e.isVisible).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  TripTypeWithConfigModel? get _selectedRootTripType {
    final roots = _visibleRootTripTypes;
    if (roots.isEmpty) return null;
    var i = _selectedServiceTypeIndex;
    if (i < 0 || i >= roots.length) i = 0;
    return roots[i];
  }

  /// Selected service tab’s trip type (API root only; children are ignored).
  TripTypeWithConfigModel? get _selectedTripType => _selectedRootTripType;

  /// Trip type id for vehicle, polygons, and review/booking.
  int get _bookingTripTypeId => _selectedTripType?.id ?? 1;

  static List<int> _parseAvailableNumberOfHours(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    final out = <int>[];
    for (final part in raw.split(',')) {
      final v = int.tryParse(part.trim());
      if (v != null && v > 0) out.add(v);
    }
    return out;
  }

  /// Allowed hour values for the slider when API sends `availableNumberOfHours` (e.g. `4,6,10`).
  /// Empty → use continuous min/max. Not used for "by day" (full-day) hourly mode.
  List<int> get _discreteHourlyDurations {
    if (!(_selectedTripType?.requiresHourDuration ?? false)) return const [];
    if ((_selectedTripType?.displayCheckBoxIsByDay ?? false) && _isFullDay) {
      return const [];
    }
    return _parseAvailableNumberOfHours(
      _selectedTripType?.availableNumberOfHours,
    );
  }

  void _syncDurationHoursToDiscreteOptions() {
    final opts = _discreteHourlyDurations;
    if (opts.isEmpty) return;
    if (!opts.contains(_durationHours)) {
      _durationHours = opts.first;
    }
  }

  bool get _showByDayCheckbox =>
      _selectedRootTripType?.displayCheckBoxIsByDay == true;

  void _setHourlyByDayMode(bool byDay) {
    setState(() {
      _isFullDay = byDay;
      if (!_isFullDay) {
        final opts = _discreteHourlyDurations;
        if (opts.isNotEmpty) {
          if (!opts.contains(_durationHours)) {
            _durationHours = opts.first;
          }
        } else {
          final maxH = (_selectedTripType?.displayCheckBoxIsHalfDay ?? false)
              ? 15
              : 11;
          if (_durationHours > maxH) {
            _durationHours = maxH;
          }
        }
      }
      _invalidateVehicleList();
    });
  }

  bool get _showRoundTripCheckbox =>
      _selectedRootTripType?.displayCheckBoxIsRoundTrip == true;

  void _onRoundTripCheckboxChanged(bool? value) {
    if (value == null) return;
    setState(() {
      _roundTripCheckboxSelected = value;
      _syncDurationHoursToDiscreteOptions();
      _clampDateAndTimeToMinBooking();
      _invalidateVehicleList();
      if (value) {
        _ensureReturnAfterPickup();
      }
    });
  }

  bool get _showsReturnDateTimeRow =>
      _showRoundTripCheckbox && _roundTripCheckboxSelected;

  DateTime get _selectedReturnDateTime => DateTime(
    _returnDate.year,
    _returnDate.month,
    _returnDate.day,
    _returnTime.hour,
    _returnTime.minute,
  );

  bool _returnIsStrictlyAfterPickup() =>
      _selectedReturnDateTime.isAfter(_selectedPickupDateTime);

  String get _returnTripDateTimeApiString {
    final d = _returnDate;
    final t = _returnTime;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  }

  List<TimeOfDay> get _availableReturnTimeSlots {
    final pickup = _selectedPickupDateTime;
    final retDay = DateTime(_returnDate.year, _returnDate.month, _returnDate.day);
    final pickupDay = DateTime(pickup.year, pickup.month, pickup.day);
    if (retDay.isBefore(pickupDay)) return [];
    final all = _allTimeSlotsToday;
    if (retDay.isAfter(pickupDay)) return all;
    final pm = pickup.hour * 60 + pickup.minute;
    return all.where((t) => t.hour * 60 + t.minute > pm).toList();
  }

  /// Inclusive last calendar day for return from API [returnDateRule] and [maxDurationForReturnDateByHour].
  /// - `returnDateRule == 1`: return date must stay on the **same day** as pickup.
  /// - `returnDateRule == 2`: pickup day + [maxDurationForReturnDateByHour] (day offset; API name uses "Hour").
  /// - Other rules: if [maxDurationForReturnDateByHour] > 0, same offset as rule 2; else no cap.
  DateTime? get _latestAllowedReturnCalendarDate {
    if (!_showsReturnDateTimeRow) return null;
    final trip = _selectedTripType;
    final rule = trip?.returnDateRule ?? 0;
    final pickup = _selectedPickupDateTime;
    final pickupDay = DateTime(pickup.year, pickup.month, pickup.day);

    if (rule == 1) {
      return pickupDay;
    }
    if (rule == 2) {
      final maxDays = trip?.maxDurationForReturnDateByHour ?? 0;
      if (maxDays <= 0) return null;
      return pickupDay.add(Duration(days: maxDays));
    }
    final maxDays = trip?.maxDurationForReturnDateByHour ?? 0;
    if (maxDays <= 0) return null;
    return pickupDay.add(Duration(days: maxDays));
  }

  DateTime _returnDatePickerLastDate(DateTime pickupFirstDate) {
    final cap = _latestAllowedReturnCalendarDate;
    final farFuture = DateTime.now().add(const Duration(days: 365));
    var last =
        cap != null && cap.isBefore(farFuture) ? cap : farFuture;
    if (last.isBefore(pickupFirstDate)) last = pickupFirstDate;
    return last;
  }

  void _clampReturnDateToMaxDurationWindow() {
    if (!_showsReturnDateTimeRow) return;
    final latest = _latestAllowedReturnCalendarDate;
    if (latest == null) return;
    final retDay = DateTime(_returnDate.year, _returnDate.month, _returnDate.day);
    if (!retDay.isAfter(latest)) return;
    _returnDate = DateTime(latest.year, latest.month, latest.day);
    if (!_availableReturnTimeSlots.any(
      (t) =>
          t.hour == _returnTime.hour && t.minute == _returnTime.minute,
    )) {
      final slots = _availableReturnTimeSlots;
      if (slots.isNotEmpty) {
        _returnTime = slots.first;
      }
    }
  }

  void _bumpReturnUntilStrictlyAfterPickup() {
    if (_returnIsStrictlyAfterPickup()) return;
    final slot = _timeSlotMinutes > 0 ? _timeSlotMinutes : 30;
    var dt = _selectedPickupDateTime.add(Duration(minutes: slot));
    _returnDate = DateTime(dt.year, dt.month, dt.day);
    _returnTime = _snapToNearestSlot(
      TimeOfDay(hour: dt.hour, minute: dt.minute),
    );
    if (!_returnIsStrictlyAfterPickup()) {
      dt = _selectedPickupDateTime.add(Duration(minutes: slot * 2));
      _returnDate = DateTime(dt.year, dt.month, dt.day);
      _returnTime = _snapToNearestSlot(
        TimeOfDay(hour: dt.hour, minute: dt.minute),
      );
    }
  }

  void _ensureReturnAfterPickup() {
    if (!_showsReturnDateTimeRow) return;
    _clampReturnDateToMaxDurationWindow();
    if (!_returnIsStrictlyAfterPickup()) {
      _bumpReturnUntilStrictlyAfterPickup();
    }
    _clampReturnDateToMaxDurationWindow();
    if (!_returnIsStrictlyAfterPickup()) {
      _bumpReturnUntilStrictlyAfterPickup();
      _clampReturnDateToMaxDurationWindow();
    }
    _returnDateController.text = _dateFormat.format(_returnDate);
    _returnTimeController.text = _timeFormat.format(
      DateTime(2000, 1, 1, _returnTime.hour, _returnTime.minute),
    );
  }

  static final DateFormat _dateFormat = DateFormat('EEE, d MMM');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('EEE, d MMM, hh:mm a');

  String get _timeText => _timeFormat.format(
    DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
  );

  DateTime get _selectedPickupDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  /// Earliest moment the user can book (now + minHoursBeforeReservation from selected trip type).
  DateTime get _minBookingDateTime {
    final hours = _selectedTripType?.minHoursBeforeReservation ?? 0;
    return DateTime.now().add(Duration(hours: hours));
  }

  /// Earliest selectable date (day of _minBookingDateTime).
  DateTime get _minBookingDate => DateTime(
    _minBookingDateTime.year,
    _minBookingDateTime.month,
    _minBookingDateTime.day,
  );

  bool get _isSelectedDateMinDate =>
      _selectedDate.year == _minBookingDate.year &&
      _selectedDate.month == _minBookingDate.month &&
      _selectedDate.day == _minBookingDate.day;

  TimeOfDay get _minBookingTimeOfDay => TimeOfDay(
    hour: _minBookingDateTime.hour,
    minute: _minBookingDateTime.minute,
  );

  /// Time slot interval in minutes from trip type (e.g. 30); default 30.
  int get _timeSlotMinutes => _selectedTripType?.timeSlotByMin ?? 30;

  /// All time slots for one day at _timeSlotMinutes interval (e.g. 00:00, 00:30, ..., 23:30).
  List<TimeOfDay> get _allTimeSlotsToday {
    final slotMin = _timeSlotMinutes;
    if (slotMin <= 0) return [];
    final list = <TimeOfDay>[];
    for (int h = 0; h < 24; h++) {
      for (int m = 0; m < 60; m += slotMin) {
        list.add(TimeOfDay(hour: h, minute: m));
      }
    }
    return list;
  }

  /// Slots available for the selected date (on min date: only slots >= first allowed slot).
  List<TimeOfDay> get _availableTimeSlots {
    final all = _allTimeSlotsToday;
    if (!_isSelectedDateMinDate) return all;
    final first = _firstSlotAtOrAfter(_minBookingTimeOfDay);
    return all.where((t) => !_timeOfDayIsBefore(t, first)).toList();
  }

  /// First slot at or after [min].
  TimeOfDay _firstSlotAtOrAfter(TimeOfDay min) {
    final slotMin = _timeSlotMinutes;
    if (slotMin <= 0) return min;
    int m = min.hour * 60 + min.minute;
    final slot = ((m + slotMin - 1) ~/ slotMin) * slotMin;
    final h = (slot ~/ 60) % 24;
    final mn = slot % 60;
    return TimeOfDay(hour: h, minute: mn);
  }

  /// Snaps [t] to the nearest time slot.
  TimeOfDay _snapToNearestSlot(TimeOfDay t) {
    final slotMin = _timeSlotMinutes;
    if (slotMin <= 0) return t;
    int m = t.hour * 60 + t.minute;
    final slot = (m / slotMin).round() * slotMin;
    final h = (slot ~/ 60) % 24;
    final mn = slot % 60;
    return TimeOfDay(hour: h, minute: mn);
  }

  static bool _timeOfDayIsBefore(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour < b.hour;
    return a.minute < b.minute;
  }

  /// Ensures _selectedDate and _selectedTime are not before _minBookingDateTime; snaps time to slot.
  void _clampDateAndTimeToMinBooking() {
    final min = _minBookingDateTime;
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (selected.isBefore(min)) {
      _selectedDate = _minBookingDate;
      _selectedTime = _firstSlotAtOrAfter(_minBookingTimeOfDay);
      _dateController.text = _dateFormat.format(_selectedDate);
      _timeController.text = _timeFormat.format(
        DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
      );
      _invalidateVehicleList();
    } else {
      _selectedTime = _snapToNearestSlot(_selectedTime);
      _timeController.text = _timeFormat.format(
        DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
      );
    }
    _ensureReturnAfterPickup();
  }

  /// Ensures selected flight date/time is strictly after pickup date/time.
  void _ensureFlightDateAfterPickup() {
    final minFlightDateTime = _selectedPickupDateTime.add(
      const Duration(minutes: 1),
    );
    if (!_selectedFlightDate.isAfter(_selectedPickupDateTime)) {
      _selectedFlightDate = minFlightDateTime;
      _flightDateController.text = _dateTimeFormat.format(_selectedFlightDate);
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: _dateFormat.format(_selectedDate),
    );
    _timeController = TextEditingController(text: _timeText);
    _flightNumberController = TextEditingController();
    _flightDateController = TextEditingController(
      text: _dateTimeFormat.format(_selectedFlightDate),
    );
    _returnDate = DateTime.now().add(const Duration(days: 1));
    _returnTime = const TimeOfDay(hour: 10, minute: 0);
    _returnDateController = TextEditingController(
      text: _dateFormat.format(_returnDate),
    );
    _returnTimeController = TextEditingController(
      text: _timeFormat.format(
        DateTime(2000, 1, 1, _returnTime.hour, _returnTime.minute),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTripsTypeWithConfig();
      _loadCustomerSavedPlaces();
      _loadCustomerInfo();
      _loadCheckLatestTripRate();
      _loadAirports();
      _loadAllowedPolygons();
    });
  }

  Future<void> _loadAllowedPolygons() async {
    final service = sl<AllowedPolygonsService>();
    final result = await service.getAllowedPolygonsAreas();
    if (!mounted) return;
    setState(() {
      if (result.isSuccess && result.data.isNotEmpty) {
        _allowedPolygons = AllowedPolygonPointModel.toPolygons(result.data);
      }
    });
  }

  Future<void> _loadAirports() async {
    final service = sl<AirportsService>();
    final result = await service.getAirports();
    if (!mounted) return;
    setState(() {
      if (result.isSuccess) {
        _airports = result.data;
      }
    });
  }

  Future<void> _loadCheckLatestTripRate() async {
    final customerId =
        sl<AuthLocalService>().getUserId() ?? AppConst.fallbackCustomerId;
    final service = sl<LatestTripRateService>();
    final result = await service.checkLatestTripRate(customerId);
    if (!mounted) return;
    if (result.isSuccess &&
        result.data.tripId != 0 &&
        !result.data.isRatedByCustomer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        RatingBottomSheet.show(
          context,
          tripId: result.data.tripId,
          driverId: result.data.chauffeurId,
        );
      });
    }
  }

  Future<void> _loadCustomerInfo() async {
    final customerId =
        sl<AuthLocalService>().getUserId() ?? AppConst.fallbackCustomerId;
    final service = sl<CustomerInfoService>();
    final result = await service.getCustomerInfo(customerId);
    if (!mounted) return;
    setState(() {
      if (result.isSuccess) {
        _customerInfo = result.data;
      }
    });
  }

  /// Fallback customer id when user is not logged in (e.g. for testing).
  Future<void> _loadCustomerSavedPlaces() async {
    final customerId =
        sl<AuthLocalService>().getUserId() ?? AppConst.fallbackCustomerId;

    // API body expects current location for latitude/longtitude.
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
    final repository = sl<CustomerSavedPlacesRepository>();
    final result = await repository.getCustomerSavedPlaces(params);
    if (!mounted) return;
    setState(() {
      result.when(
        success: (savedPlaces) {
          _savedPlaces = savedPlaces;
        },
        failure: (failure) {
          _savedPlaces = [];
        },
      );
    });
  }

  Future<void> _loadTripsTypeWithConfig() async {
    final service = sl<TripsTypeService>();
    final result = await service.getTripsTypeWithConfig();
    if (!mounted) return;
    setState(() {
      _loadingTripsType = false;
      if (result.isSuccess && result.data.isNotEmpty) {
        _tripTypes = result.data;
        _tripsTypeError = null;
        if (_selectedServiceTypeIndex >= _visibleRootTripTypes.length) {
          _selectedServiceTypeIndex = 0;
        }
        _roundTripCheckboxSelected = false;
        _syncDurationHoursToDiscreteOptions();
        final needsFlightNames = _allTripTypeNodes.any(
          (t) => t.isVisible && t.requiresFlightName,
        );
        if (needsFlightNames && _flightNames.isEmpty) {
          _loadFlightNames('ar');
        }
        final needsAirports = _allTripTypeNodes.any(
          (t) => t.isVisible && t.requiresFlightNumber,
        );
        if (needsAirports && _airports.isEmpty) {
          _loadAirports();
        }
        _clampDateAndTimeToMinBooking();
      } else {
        _tripsTypeError = result.errorMessage;
        _tripTypes = [];
      }
    });
  }

  Future<void> _loadFlightNames(String language) async {
    if (_loadingFlightNames) return;
    setState(() => _loadingFlightNames = true);
    final service = sl<FlightNamesService>();
    final result = await service.getFlightNames(language);
    if (!mounted) return;
    setState(() {
      _loadingFlightNames = false;
      if (result.isSuccess && result.data.isNotEmpty) {
        _flightNames = result.data;
      }
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _flightNumberController.dispose();
    _flightDateController.dispose();
    _returnDateController.dispose();
    _returnTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final firstDate = _minBookingDate;
    final initialDate = _selectedDate.isBefore(firstDate)
        ? firstDate
        : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        if (_isSelectedDateMinDate &&
            _timeOfDayIsBefore(_selectedTime, _minBookingTimeOfDay)) {
          _selectedTime = _firstSlotAtOrAfter(_minBookingTimeOfDay);
          _timeController.text = _timeFormat.format(
            DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
          );
        } else {
          _selectedTime = _snapToNearestSlot(_selectedTime);
          _timeController.text = _timeFormat.format(
            DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
          );
        }
        _dateController.text = _dateFormat.format(_selectedDate);
        _ensureFlightDateAfterPickup();
        _ensureReturnAfterPickup();
        _invalidateVehicleList();
      });
    }
  }

  Future<void> _pickFlightDate(BuildContext context) async {
    final pickupDateTime = _selectedPickupDateTime;
    final firstFlightDate = DateTime(
      pickupDateTime.year,
      pickupDateTime.month,
      pickupDateTime.day,
    );
    final initialFlightDate = _selectedFlightDate.isBefore(firstFlightDate)
        ? firstFlightDate
        : _selectedFlightDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialFlightDate,
      firstDate: firstFlightDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedFlightDate),
    );
    if (pickedTime != null && mounted) {
      final pickedFlightDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (!pickedFlightDateTime.isAfter(pickupDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flight time must be after pickup time'),
          ),
        );
        return;
      }
      setState(() {
        _selectedFlightDate = pickedFlightDateTime;
        _flightDateController.text = _dateTimeFormat.format(
          _selectedFlightDate,
        );
      });
    } else if (mounted) {
      final updatedFlightDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedFlightDate.hour,
        _selectedFlightDate.minute,
      );
      if (!updatedFlightDate.isAfter(pickupDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flight time must be after pickup time'),
          ),
        );
        return;
      }
      setState(() {
        _selectedFlightDate = updatedFlightDate;
        _flightDateController.text = _dateTimeFormat.format(
          _selectedFlightDate,
        );
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final slots = _availableTimeSlots;
    if (slots.isEmpty) return;
    final selected = _selectedTime;
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
                    final label = _timeFormat.format(
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
                        setState(() {
                          _selectedTime = slot;
                          _timeController.text = _timeFormat.format(
                            DateTime(2000, 1, 1, slot.hour, slot.minute),
                          );
                          _ensureFlightDateAfterPickup();
                          _ensureReturnAfterPickup();
                          _invalidateVehicleList();
                        });
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

  /// Clears loaded vehicle list so user must load again after changing trip details.
  void _invalidateVehicleList() {
    _vehicleClasses = [];
    _selectedVehicleClassIndex = -1;
    _selectedCurrencyIndex = 0;
  }

  void _swapFromAndDropOff() {
    setState(() {
      final from = _fromPlaceName;
      _fromPlaceName = _dropOffPlaceName;
      _dropOffPlaceName = from;
      final fromCoord = _fromLatLng;
      _fromLatLng = _dropOffLatLng;
      _dropOffLatLng = fromCoord;
      final pickupAirport = _pickupFromAirportList;
      _pickupFromAirportList = _dropOffFromAirportList;
      _dropOffFromAirportList = pickupAirport;
      _invalidateVehicleList();
    });
  }

  void _resetFormValues() {
    _fromPlaceName = '';
    _dropOffPlaceName = '';
    _fromLatLng = null;
    _dropOffLatLng = null;
    _pickupFromAirportList = false;
    _dropOffFromAirportList = false;
    _selectedDate = DateTime.now();
    _selectedTime = _snapToNearestSlot(TimeOfDay.now());
    _dateController.text = _dateFormat.format(_selectedDate);
    _timeController.text = _timeFormat.format(
      DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
    );
    _flightNumberController.clear();
    _selectedFlightName = null;
    _selectedFlightDate = DateTime.now();
    _flightDateController.text = _dateTimeFormat.format(_selectedFlightDate);
    _durationHours = 3;
    _vehicleClasses = [];
    _selectedVehicleClassIndex = -1;
    _selectedVehicleIndex = 0;
    _returnDate = DateTime.now().add(const Duration(days: 1));
    _returnTime = const TimeOfDay(hour: 10, minute: 0);
    _returnDateController.text = _dateFormat.format(_returnDate);
    _returnTimeController.text = _timeFormat.format(
      DateTime(2000, 1, 1, _returnTime.hour, _returnTime.minute),
    );
    _roundTripCheckboxSelected = false;
    _syncDurationHoursToDiscreteOptions();
  }

  /// Shows bottom sheet with search, saved places, airports, and map picker.
  void _showPlaceSelectionSheet({required bool isFrom}) {
    final label = isFrom ? 'Pickup location' : 'Drop-off location';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => PlaceSelectionSheet(
        title: label,
        savedPlaces: _savedPlaces,
        airports: _airports,
        showAirports: _selectedTripType?.requiresFlightNumber ?? false,
        allowedPolygons: isFrom ? _allowedPolygons : null,
        validateLocation: !isFrom && _fromLatLng != null
            ? _checkDropOffAllowed
            : null,
        localizeAirportName: (airport) => context.localized(
          airport.airportPimaryName ?? '',
          airport.airportSecondaryName,
        ),
        onChooseFromMap: () {
          Navigator.of(sheetContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openMapPicker(isFrom: isFrom);
          });
        },
        onPlaceSelected: ({
          required name,
          required latLng,
          required fromAirportList,
        }) async {
          await _applyDropOffFromSheet(
            name: name,
            coord: latLng,
            isFrom: isFrom,
            fromAirportList: fromAirportList,
          );
        },
      ),
    );
  }

  /// Builds TripDateTime string for API: "yyyy-MM-ddTHH:mm:ss".
  String get _tripDateTimeApiString {
    final d = _selectedDate;
    final t = _selectedTime;
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  }

  /// Loads vehicle classes from API and shows them in the Choose vehicle section.
  /// Calls CheckDropCoordinatesPolygonWithPickupCoordinatesAndTripId first (with Dlatitude/Dlongtitude=0 when drop-off hidden), then GetVehicleClassesPriceByTripType with FromCityId=pickupZoneId, ToCityId=dropZoneId.
  Future<void> _loadVehicleClasses() async {
    if (_loadingVehicleClasses) return;
    final requireDropOff = _selectedTripType?.allowDropOff ?? true;
    if (_fromPlaceName.isEmpty ||
        (requireDropOff && _dropOffPlaceName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requireDropOff
                ? 'Please select pickup and drop-off locations'
                : 'Please select pickup location',
          ),
        ),
      );
      return;
    }
    if (_fromLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup location')),
      );
      return;
    }
    setState(() => _loadingVehicleClasses = true);
    final tripTypeId = _bookingTripTypeId;
    log('Load vehicle: tripTypeId=$tripTypeId', name: 'ServicesPage');
    final double dlat;
    final double dlong;
    if (requireDropOff && _dropOffLatLng != null) {
      dlat = _dropOffLatLng!.latitude;
      dlong = _dropOffLatLng!.longitude;
    } else {
      dlat = 0;
      dlong = 0;
    }
    final zoneResponse = await sl<AllowedPolygonsService>()
        .checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId(
          platitude: _fromLatLng!.latitude,
          plongtitude: _fromLatLng!.longitude,
          tripTypeId: tripTypeId,
          dlatitude: dlat,
          dlongtitude: dlong,
        );
    if (!mounted) return;
    if (requireDropOff &&
        (!zoneResponse.isSuccess || !zoneResponse.data.isAllowed)) {
      setState(() => _loadingVehicleClasses = false);
      final msg =
          zoneResponse.data.primaryMessage ??
          zoneResponse.data.secondaryMessage ??
          zoneResponse.errorMessage ??
          'This drop-off location is not allowed for the selected pickup.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }
    final pickupZoneId = zoneResponse.data.pickupZoneId ?? 0;
    final dropZoneId = zoneResponse.data.dropZoneId ?? 0;
    final customerId =
        sl<AuthLocalService>().getUserId() ?? AppConst.fallbackCustomerId;
    final request = VehicleClassesPriceRequest(
      tripId: tripTypeId,
      customerId: customerId,
      hoursCount: _durationHours,
      tripHours: _durationHours,
      companyCustomerId: null,
      branchId: _effectiveBranchId,
      tripDateTime: _tripDateTimeApiString,
      returnTripDateTime:
          _showsReturnDateTimeRow ? _returnTripDateTimeApiString : null,
      fromCityId: pickupZoneId,
      toCityId: dropZoneId,
      tripDays: 0,
      isHalfDay: isHalfDay,
      isRoundTrip: _showsReturnDateTimeRow,
      isPerDay:
          (_selectedTripType?.displayCheckBoxIsByDay ?? false) && _isFullDay,
      isDropoffAirport: requireDropOff && _dropOffFromAirportList,
    );
    final service = sl<VehicleClassesPriceService>();
    final result = await service.getVehicleClassesPriceByTripType(request);
    if (!mounted) return;
    setState(() {
      _loadingVehicleClasses = false;
      _pickupZoneId = pickupZoneId;
      _dropZoneId = dropZoneId;
      if (result.isSuccess && result.data.isNotEmpty) {
        _vehicleClasses = result.data;
        _selectedVehicleClassIndex = 0;
        _selectedCurrencyIndex = 0;
      }
    });
    if (!result.isSuccess || result.data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage ?? 'Could not load vehicle options. Try again.',
          ),
        ),
      );
    }
  }

  /// Navigates to review trip with selected vehicle and trip details. Call only when vehicle is selected.
  void _goToReviewTrip() {
    if (_vehicleClasses.isEmpty || _selectedVehicleClassIndex < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please load vehicle options and select a vehicle'),
        ),
      );
      return;
    }
    final requireDropOff = _selectedTripType?.allowDropOff ?? true;
    if (_fromPlaceName.isEmpty ||
        (requireDropOff && _dropOffPlaceName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            requireDropOff
                ? 'Please select pickup and drop-off locations'
                : 'Please select pickup location',
          ),
        ),
      );
      return;
    }
    if (_showsReturnDateTimeRow && !_returnIsStrictlyAfterPickup()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Return date and time must be after pickup'),
        ),
      );
      return;
    }
    final selectedVehicle = _vehicleClasses[_selectedVehicleClassIndex]
        .withCurrency(_selectedCurrencyCode);
    final args = ReviewTripPageArgs(
      vehicles: [selectedVehicle],
      fromPlaceName: _fromPlaceName,
      dropOffPlaceName: requireDropOff ? _dropOffPlaceName : '',
      date: _dateFormat.format(_selectedDate),
      time: _timeFormat.format(
        DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
      ),
      tripTypeConfig: _selectedTripType,
      pickupLatLng: _fromLatLng,
      dropOffLatLng: requireDropOff ? _dropOffLatLng : null,
      tripTypeId: _bookingTripTypeId,
      branchId: _effectiveBranchId,
      durationHours: _durationHours,
      fromZoneId: _pickupZoneId,
      toZoneId: _dropZoneId,
      tripDateTimeApiString: _tripDateTimeApiString,
      hasFlightInfo: false,
      isByDay:
          (_selectedTripType?.displayCheckBoxIsByDay ?? false) && _isFullDay,
      isDropoffAirport: requireDropOff ? _dropOffFromAirportList : false,
      isHalfDay: isHalfDay,
      isRoundTrip: _showsReturnDateTimeRow,
      returnDate: _showsReturnDateTimeRow
          ? _dateFormat.format(_returnDate)
          : null,
      returnTime: _showsReturnDateTimeRow
          ? _timeFormat.format(
              DateTime(2000, 1, 1, _returnTime.hour, _returnTime.minute),
            )
          : null,
      returnTripDateTimeApiString:
          _showsReturnDateTimeRow ? _returnTripDateTimeApiString : null,
      totalLoyalityPoints: _customerInfo?.totalLoyalityPoints ?? 0,
      maxRedeemablePoints: _customerInfo?.maxRedeemablePoints ?? 0,
      minimumPointsValueForTransfer:
          _customerInfo?.minimumPointsValueForTransfer ?? 0,
      currencyCode: _selectedCurrencyCode,
    );
    AvisNavigation.push(context, AppRoutes.reviewTrip, arguments: args);
  }

  /// Returns true if drop-off is allowed for the given coordinates (or no check needed).
  Future<bool> _checkDropOffAllowed(LatLng dropLatLng) async {
    if (_fromLatLng == null) return true;
    final tripTypeId = _bookingTripTypeId;
    final response = await sl<AllowedPolygonsService>()
        .checkDropCoordinatesPolygonWithPickupCoordinatesAndTripId(
          platitude: _fromLatLng!.latitude,
          plongtitude: _fromLatLng!.longitude,
          tripTypeId: tripTypeId,
          dlatitude: dropLatLng.latitude,
          dlongtitude: dropLatLng.longitude,
        );
    if (!response.isSuccess || !response.data.isAllowed) {
      final msg =
          response.data.primaryMessage ??
          response.data.secondaryMessage ??
          response.errorMessage ??
          'This drop-off location is not allowed for the selected pickup.';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      return false;
    }
    return true;
  }

  Future<void> _openMapPicker({required bool isFrom}) async {
    final title = isFrom
        ? 'Select pickup location'
        : 'Select drop-off location';
    List<List<LatLng>> polygons;
    if (!isFrom && _fromLatLng != null) {
      // Drop-off: use only API result for this pickup; do not fall back to general polygons.
      final tripTypeId = _bookingTripTypeId;
      final response = await sl<AllowedPolygonsService>()
          .findAllowedAreasPolygonByPickupCordTripId(
            platitude: _fromLatLng!.latitude,
            plongtitude: _fromLatLng!.longitude,
            tripTypeId: tripTypeId,
          );
      polygons = (response.isSuccess && response.data.isNotEmpty)
          ? AllowedPolygonPointModel.toPolygons(response.data)
          : <List<LatLng>>[];
    } else {
      polygons = _allowedPolygons;
    }
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
        setState(() {
          _fromPlaceName = result.address;
          _fromLatLng = result.latLng;
          _pickupFromAirportList = false;
          _invalidateVehicleList();
        });
      } else {
        final allowed = await _checkDropOffAllowed(result.latLng);
        if (allowed && mounted) {
          setState(() {
            _dropOffPlaceName = result.address;
            _dropOffLatLng = result.latLng;
            _dropOffFromAirportList = false;
            _invalidateVehicleList();
          });
        }
      }
    }
  }

  Future<void> _applyDropOffFromSheet({
    required String name,
    required LatLng? coord,
    required bool isFrom,
    bool fromAirportList = false,
  }) async {
    if (isFrom) {
      setState(() {
        _fromPlaceName = name;
        _fromLatLng = coord;
        _pickupFromAirportList = fromAirportList;
        _invalidateVehicleList();
      });
      return;
    }
    if (coord != null && _fromLatLng != null) {
      final allowed = await _checkDropOffAllowed(coord);
      if (!allowed || !mounted) return;
    }
    setState(() {
      _dropOffPlaceName = name;
      _dropOffLatLng = coord;
      _dropOffFromAirportList = fromAirportList;
      _invalidateVehicleList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        child: Row(
                          children: [
                            BackArrowWidget(),
                          ],
                        ),
                      ),
                    ServicePageHeaderWidget(
                      customerName: _customerInfo != null
                          ? context.localized(
                              _customerInfo!.customerPrimaryName ?? '',
                              _customerInfo!.customerSecondaryname,
                            )
                          : '',
                    ),
                    const SizedBox(height: 30),
                    if (_loadingTripsType)
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
                              if (_tripsTypeError != null)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextWidget(
                                          _tripsTypeError!,
                                          style: AppTextStyles.bodyXSmall
                                              .copyWith(color: Colors.red),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _loadingTripsType = true;
                                            _tripsTypeError = null;
                                          });
                                          _loadTripsTypeWithConfig();
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              _buildServiceTypeTabs(context),
                              SizedBox(height: 20.h),
                              LocationFieldsWithSwapWidget(
                                fromPlaceName: _fromPlaceName,
                                dropOffPlaceName: _dropOffPlaceName,
                                onFromTap: () =>
                                    _showPlaceSelectionSheet(isFrom: true),
                                onDropOffTap: () {
                                  if (_fromPlaceName.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please select pickup location first',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  _showPlaceSelectionSheet(isFrom: false);
                                },
                                onSwap: _swapFromAndDropOff,
                                showDropOffAndSwap:
                                    _selectedTripType?.allowDropOff ?? true,
                              ),
                              SizedBox(height: 16.h),
                              if (_selectedTripType?.requiresHourDuration ??
                                  false) ...[
                                DurationSliderWidget(
                                  durationHours: _durationHours,
                                  allowedHours: _discreteHourlyDurations
                                          .isNotEmpty
                                      ? _discreteHourlyDurations
                                      : null,
                                  maxHours:
                                      (_selectedTripType
                                                  ?.displayCheckBoxIsByDay ??
                                              false) &&
                                          _isFullDay
                                      ? 30
                                      : (_selectedTripType
                                                ?.displayCheckBoxIsHalfDay ??
                                            false)
                                      ? 15
                                      : 11,
                                  isByDay:
                                      (_selectedTripType
                                              ?.displayCheckBoxIsByDay ??
                                          false) &&
                                      _isFullDay,
                                  onChanged: (v) => setState(() {
                                    _durationHours = v;
                                    if (_discreteHourlyDurations.isEmpty) {
                                      if (_isFullDay == false &&
                                          _durationHours > 11) {
                                        isHalfDay = true;
                                      } else {
                                        isHalfDay = false;
                                      }
                                    }
                                    _invalidateVehicleList();
                                  }),
                                ),
                                SizedBox(height: 16.h),
                              ],

                              _buildDateAndTimeRow(context),
                              SizedBox(height: 16.h),
                              if (_showRoundTripCheckbox || _showByDayCheckbox) ...[
                                _buildTripOptionCheckboxes(context),
                                SizedBox(height: 16.h),
                              ],
                              if (_showsReturnDateTimeRow) ...[
                                _buildReturnDateAndTimeRow(context),
                                SizedBox(height: 24.h),
                              ],
                              _buildChooseVehicleSection(context),
                              SizedBox(height: 24.h),
                              AppButton.primary(
                                // onPressed: () {
                                //   AvisNavigation.push(
                                //     context,
                                //     AppRoutes.savedLocations,
                                //   );
                                // },
                                onPressed:
                                    _vehicleClasses.isNotEmpty &&
                                        _selectedVehicleClassIndex >= 0
                                    ? _goToReviewTrip
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

  static const List<String> _fallbackTabLabels = [
    'City to City',
    'Airport',
    'Hourly',
  ];

  /// Round trip / By day from API [TripTypeWithConfigModel.displayCheckBoxIsRoundTrip] / [displayCheckBoxIsByDay].
  Widget _buildTripOptionCheckboxes(BuildContext context) {
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
        if (_showRoundTripCheckbox)
          row(
            value: _roundTripCheckboxSelected,
            onChanged: _onRoundTripCheckboxChanged,
            title: context.localized('Round trip', null),
          ),
        if (_showByDayCheckbox)
          row(
            value: _isFullDay,
            onChanged: (v) {
              if (v == null) return;
              _setHourlyByDayMode(v);
            },
            title: context.localized('By day', null),
          ),
      ],
    );
  }

  Widget _buildServiceTypeTabs(BuildContext context) {
    final list = _visibleRootTripTypes;
    final labels = list.isNotEmpty
        ? list.map((e) => e.displayName).toList()
        : _fallbackTabLabels;
    final count = labels.length;
    if (count == 0) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isSelected = _selectedServiceTypeIndex == index;
          final label = labels[index];
          final iconName = _iconNameForTabIndex(index, count);
          return Padding(
            padding: EdgeInsets.only(right: index < count - 1 ? 8.w : 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (index != _selectedServiceTypeIndex) {
                    setState(() {
                      _selectedServiceTypeIndex = index;
                      _resetFormValues();
                      _clampDateAndTimeToMinBooking();
                    });
                  }
                },
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

  String _iconNameForTabIndex(int index, int count) {
    if (count <= 3) {
      if (index == 0) return 'city to city';
      if (index == 1) return 'Airport';
      return 'Hourly';
    }
    final list = _visibleRootTripTypes;
    if (index < list.length) {
      final name = list[index].primaryName?.toLowerCase() ?? '';
      if (name.contains('airport')) return 'Airport';
      if (name.contains('hour') || name.contains('hourly')) return 'Hourly';
    }
    return 'city to city';
  }

  Widget _buildDateAndTimeRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppTextFormFieldComponent(
              controller: _dateController,
              readOnly: true,
              onTap: () => _pickDate(context),
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
              controller: _timeController,
              readOnly: true,
              onTap: () => _pickTime(context),
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

  Widget _buildReturnDateAndTimeRow(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppTextFormFieldComponent(
              controller: _returnDateController,
              readOnly: true,
              onTap: () => _pickReturnDate(context),
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
              controller: _returnTimeController,
              readOnly: true,
              onTap: () => _pickReturnTime(context),
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

  Future<void> _pickReturnDate(BuildContext context) async {
    final pickup = _selectedPickupDateTime;
    final firstDate = DateTime(pickup.year, pickup.month, pickup.day);
    final lastDate = _returnDatePickerLastDate(firstDate);
    var initialDate =
        _returnDate.isBefore(firstDate) ? firstDate : _returnDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      setState(() {
        _returnDate = picked;
        _returnDateController.text = _dateFormat.format(_returnDate);
        if (!_availableReturnTimeSlots.any(
          (t) =>
              t.hour == _returnTime.hour && t.minute == _returnTime.minute,
        )) {
          final slots = _availableReturnTimeSlots;
          if (slots.isNotEmpty) {
            _returnTime = slots.first;
            _returnTimeController.text = _timeFormat.format(
              DateTime(2000, 1, 1, _returnTime.hour, _returnTime.minute),
            );
          }
        }
        _ensureReturnAfterPickup();
        _invalidateVehicleList();
      });
    }
  }

  Future<void> _pickReturnTime(BuildContext context) async {
    final slots = _availableReturnTimeSlots;
    if (slots.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose a return date after pickup first'),
          ),
        );
      }
      return;
    }
    final selected = _returnTime;
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
                    final label = _timeFormat.format(
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
                        setState(() {
                          _returnTime = slot;
                          _returnTimeController.text = _timeFormat.format(
                            DateTime(2000, 1, 1, slot.hour, slot.minute),
                          );
                          _invalidateVehicleList();
                        });
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

  Widget _buildFlightNameDropdown(BuildContext context) {
    return AppCustomDropdown<FlightNameModel>(
      title: '',
      items: _flightNames,
      selectedValue: _selectedFlightName,
      onChanged: (value) => setState(() => _selectedFlightName = value),
      itemAsString: (f) => f.displayName,
      hintText: _loadingFlightNames ? 'Loading...' : 'Select flight / airline',
      height: 56,
      selectedTextStyle: AppTextStyles.bodyMediumBold.copyWith(
        color: context.colors.primaryText,
      ),
      iconWidget: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: SvgIconWidget(
          name: 'Airport',
          width: 20.w,
          height: 20.w,
          color: context.colors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildFlightNumberField(BuildContext context) {
    return AppTextFormFieldComponent(
      controller: _flightNumberController,
      hintText: 'Flight number (optional)',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      focusedBorderSameAsEnabled: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSpaces.onSides,
        horizontal: AppSpaces.medium,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: AppSpaces.onSides),
        child: SvgIconWidget(
          name: 'Airport',
          width: 20.w,
          height: 20.w,
          color: context.colors.secondaryText,
        ),
      ),
    );
  }

  Widget _buildFlightDateField(BuildContext context) {
    return AppTextFormFieldComponent(
      controller: _flightDateController,
      readOnly: true,
      onTap: () => _pickFlightDate(context),
      hintText: 'Flight date and time',
      focusedBorderSameAsEnabled: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSpaces.onSides,
        horizontal: AppSpaces.medium,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: SvgIconWidget(
          name: 'Airport',
          width: 20.w,
          height: 20.w,
          color: context.colors.secondaryText,
        ),
      ),
    );
  }

  List<VehicleClassDisplayPrice> get _currencyOptions =>
      _vehicleClasses.isNotEmpty &&
              _vehicleClasses.first.displayPrices.isNotEmpty
          ? _vehicleClasses.first.displayPrices
          : const [];

  String get _selectedCurrencyCode {
    final options = _currencyOptions;
    if (options.isEmpty) return 'USD';
    final index = _selectedCurrencyIndex.clamp(0, options.length - 1);
    return options[index].currencyCode;
  }

  String _currencySymbol(String code) {
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

  double? _selectedVehicleTotalForCurrency() {
    if (_selectedVehicleClassIndex < 0 ||
        _selectedVehicleClassIndex >= _vehicleClasses.length) {
      return null;
    }
    return _vehicleTotalForCurrency(_selectedCurrencyCode);
  }

  double _vehicleTotalForCurrency(String currencyCode) {
    if (_selectedVehicleClassIndex >= 0 &&
        _selectedVehicleClassIndex < _vehicleClasses.length) {
      final vehicle = _vehicleClasses[_selectedVehicleClassIndex];
      final displayPrice = vehicle.priceForCurrency(currencyCode);
      if (displayPrice != null) return displayPrice.total;
      return vehicle.total;
    }
    if (_vehicleClasses.isNotEmpty) {
      final displayPrice =
          _vehicleClasses.first.priceForCurrency(currencyCode);
      if (displayPrice != null) return displayPrice.total;
      return _vehicleClasses.first.total;
    }
    return 0;
  }

  void _showCurrencyPicker(BuildContext context) {
    final options = _currencyOptions;
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
                final selected = i == _selectedCurrencyIndex;
                final total = _vehicleTotalForCurrency(item.currencyCode);
                return ListTile(
                  title: TextWidget(
                    '${item.currencyCode} - ${_currencySymbol(item.currencyCode)}${total.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: selected
                          ? context.colors.primary
                          : context.colors.primaryText,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedCurrencyIndex = i);
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

  Widget _buildCurrencySelector(BuildContext context) {
    final options = _currencyOptions;
    if (options.isEmpty) return const SizedBox.shrink();

    final selected = options[_selectedCurrencyIndex.clamp(0, options.length - 1)];
    final selectedTotal = _selectedVehicleTotalForCurrency();

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showCurrencyPicker(context),
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
                      ? '${_currencySymbol(selected.currencyCode)}${selectedTotal.toStringAsFixed(2)}'
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

  String _formattedVehiclePrice(VehicleClassPriceModel vehicle) {
    final displayPrice = vehicle.priceForCurrency(_selectedCurrencyCode);
    if (displayPrice != null) {
      return '${_currencySymbol(displayPrice.currencyCode)}${displayPrice.total.toStringAsFixed(2)}';
    }
    return '\$${vehicle.total.toStringAsFixed(2)}';
  }

  Widget _buildChooseVehicleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_currencyOptions.isNotEmpty) ...[
          _buildCurrencySelector(context),
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
        if (_vehicleClasses.isEmpty && !_loadingVehicleClasses)
          AppButton.primary(
            onPressed: _loadVehicleClasses,
            text: 'LOAD VEHICLE OPTIONS',
          )
        else if (_loadingVehicleClasses)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          )
        else
          SizedBox(
            height: 150.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _vehicleClasses.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final v = _vehicleClasses[index];
                final option = VehicleOption(
                  name: v.name,
                  price: _formattedVehiclePrice(v),
                  eta: '',
                  passengers: v.passengersNo,
                  bags: v.suitcasesNo,
                  imagePath: v.image ?? '',
                );
                final isSelected = _selectedVehicleClassIndex == index;
                return ServiceOptionCard(
                  option: option,
                  isSelected: isSelected,
                  onTap: () =>
                      setState(() => _selectedVehicleClassIndex = index),
                );
              },
            ),
          ),
      ],
    );
  }
}
