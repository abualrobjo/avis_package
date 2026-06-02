import 'package:avis_package/src/core/_core.dart' show
    VehicleClassPriceModel,
    TripTypeWithConfigModel,
    LatLng;
import 'review_trip_ui_model.dart';

/// Arguments passed from service page after calling GetVehicleClassesPriceByTripType.
class ReviewTripPageArgs {
  const ReviewTripPageArgs({
    required this.vehicles,
    required this.fromPlaceName,
    required this.dropOffPlaceName,
    required this.date,
    required this.time,
    this.tripTypeConfig,
    this.pickupLatLng,
    this.dropOffLatLng,
    this.tripTypeId = 7,
    this.branchId = 1,
    this.durationHours = 3,
    this.fromZoneId = 31,
    this.toZoneId = 31,
    required this.tripDateTimeApiString,
    this.hasFlightInfo = false,
    this.isByDay = false,
    this.isDropoffAirport = false,
    this.isHalfDay = false,
    this.isRoundTrip = false,
    this.returnDate,
    this.returnTime,
    this.returnTripDateTimeApiString,
    this.totalLoyalityPoints = 0,
    this.maxRedeemablePoints = 0,
    this.minimumPointsValueForTransfer = 0,
    this.currencyCode = 'USD',
  });

  final List<VehicleClassPriceModel> vehicles;
  final String fromPlaceName;
  final String dropOffPlaceName;
  final String date;
  final String time;
  /// API format: "2026-03-05T14:30:00"
  final String tripDateTimeApiString;
  /// Trip type config for option visibility (showMeetAndGreet, showOnCurb, showWiFi).
  final TripTypeWithConfigModel? tripTypeConfig;
  final LatLng? pickupLatLng;
  final LatLng? dropOffLatLng;
  final int tripTypeId;
  final int branchId;
  final int durationHours;
  final int fromZoneId;
  final int toZoneId;
  /// True when user filled flight/airline on service page; required to allow selecting Meet & Assist.
  final bool hasFlightInfo;
  /// True when duration slider is in "By day" mode (value is days); false when in hours.
  final bool isByDay;
  /// True when drop-off is at airport.
  final bool isDropoffAirport;
  /// Half-day trip (from Najeeb).
  final bool isHalfDay;
  /// Round trip (from Najeeb).
  final bool isRoundTrip;
  /// Return leg date label when [isRoundTrip] (service page).
  final String? returnDate;
  /// Return leg time label when [isRoundTrip] (service page).
  final String? returnTime;
  /// Return leg API datetime "yyyy-MM-ddTHH:mm:ss" when [isRoundTrip].
  final String? returnTripDateTimeApiString;
  /// From GetCustomerInfo (service page); used by loyalty points dialog to avoid refetch.
  final int totalLoyalityPoints;
  final int maxRedeemablePoints;
  final int minimumPointsValueForTransfer;
  final String currencyCode;

  /// Builds options list from trip type visibility: Meet & Assist, On Curb, WiFi.
  List<ReviewTripOptionUiModel> _buildOptions() {
    final t = tripTypeConfig;
    final options = <ReviewTripOptionUiModel>[];
    if (t?.showMeetAndGreet ?? false) {
      options.add(ReviewTripOptionUiModel(
        iconName: 'profile',
        title: 'Meet with a Sign',
        isEnabled: false,
        onChanged: (_) {},
      ));
    }
    if (t?.showOnCurb ?? false) {
      options.add(ReviewTripOptionUiModel(
        iconName: 'pick-up',
        title: 'On Curb',
        isEnabled: false,
        onChanged: (_) {},
      ));
    }
    if (t?.showWiFi ?? false) {
      options.add(ReviewTripOptionUiModel(
        iconName: 'wifi',
        title: 'WiFi',
        isEnabled: false,
        onChanged: (_) {},
      ));
    }
    return options;
  }

  /// Builds [ReviewTripUiModel] using the first vehicle (or empty defaults if none).
  ReviewTripUiModel toReviewTripUiModel() {
    final vehicle = vehicles.isNotEmpty ? vehicles.first : null;
    return ReviewTripUiModel(
      isIndividual: true,
      date: date,
      time: time,
      route: ReviewTripRouteUiModel(
        pickupLabel: 'Pick up details',
        pickupTime: time,
        pickupLocation: fromPlaceName.isEmpty ? 'Pickup location' : fromPlaceName,
        dropOffLabel: 'Drop off details',
        dropOffLocation:
            dropOffPlaceName.isEmpty ? 'Drop-off location' : dropOffPlaceName,
      ),
      vehicle: ReviewTripVehicleUiModel(
        name: vehicle?.name ?? 'Vehicle',
        imageUrl: vehicle?.image ?? '',
        passengerCapacity: vehicle?.passengersNo ?? 0,
        luggageCapacity: vehicle?.suitcasesNo ?? 0,
      ),
      price: ReviewTripPriceUiModel(
        amount: vehicle?.total ?? 0.0,
        currency: currencyCode,
        label: 'Include taxes',
      ),
      options: _buildOptions(),
      actions: [
        ReviewTripActionUiModel(title: 'Promo Code', onTap: () {}),
        ReviewTripActionUiModel(title: 'Loyalty Points', onTap: () {}),
      ],
      confirmButtonText: 'Confirm Booking',
    );
  }
}
