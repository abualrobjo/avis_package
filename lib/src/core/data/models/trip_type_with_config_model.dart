/// One trip type from GetTripsTypeWithConfig API [responseDetails] (tree via [children]).
class TripTypeWithConfigModel {
  final int id;
  final String? primaryName;
  final String? secondaryName;
  final int sortOrder;
  final int? minHoursBeforeReservation;
  final bool isBookable;
  final bool isVisible;
  final int? parentTripTypeId;
  final bool allowPickup;
  final bool allowDropOff;
  final bool requiresFlightNumber;
  final bool requiresFlightName;
  final bool requiresFlightDate;
  final bool showMeetAndGreet;
  final bool showOnCurb;
  final bool showWiFi;
  final bool requiresHourDuration;
  final bool requiresDaysDuration;
  final bool displayCheckBoxIsRoundTrip;
  final bool displayCheckBox2WayTrip;
  final bool displayCheckBoxIsByDay;
  final bool displayCheckBoxIsHalfDay;
  final int returnDateRule;
  final bool requiresReturnDate;
  /// Time slot interval in minutes (e.g. 30 for slots every 30 mins).
  final int? timeSlotByMin;
  final String? iconKey;
  /// From GetTripsTypeWithConfig; may describe hour limits for this trip type.
  final String? availableNumberOfHours;
  /// Max duration (hours) allowed for return date when booking by hour.
  final int maxDurationForReturnDateByHour;
  final List<TripTypeWithConfigModel> children;

  const TripTypeWithConfigModel({
    required this.id,
    this.primaryName,
    this.secondaryName,
    required this.sortOrder,
    this.minHoursBeforeReservation,
    required this.isBookable,
    this.isVisible = true,
    this.parentTripTypeId,
    required this.allowPickup,
    required this.allowDropOff,
    required this.requiresFlightNumber,
    required this.requiresFlightName,
    required this.requiresFlightDate,
    required this.showMeetAndGreet,
    required this.showOnCurb,
    required this.showWiFi,
    required this.requiresHourDuration,
    required this.requiresDaysDuration,
    this.displayCheckBoxIsRoundTrip = false,
    this.displayCheckBox2WayTrip = false,
    required this.displayCheckBoxIsByDay,
    required this.displayCheckBoxIsHalfDay,
    this.returnDateRule = 0,
    this.requiresReturnDate = false,
    this.timeSlotByMin,
    this.iconKey,
    this.availableNumberOfHours,
    this.maxDurationForReturnDateByHour = 0,
    this.children = const [],
  });

  String get displayName => primaryName ?? secondaryName ?? '';

  /// This node followed by all descendants (pre-order).
  List<TripTypeWithConfigModel> get preorderNodes => [
        this,
        for (final c in children) ...c.preorderNodes,
      ];

  factory TripTypeWithConfigModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return TripTypeWithConfigModel(
      id: (json['id'] as num).toInt(),
      primaryName: json['primaryName'] as String?,
      secondaryName: json['secondaryName'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      minHoursBeforeReservation:
          (json['minHoursBeforeReservation'] as num?)?.toInt(),
      isBookable: json['isBookable'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      displayCheckBoxIsRoundTrip:
          json['displayCheckBoxIsRoundTrip'] as bool? ?? false,
      displayCheckBox2WayTrip:
          json['displayCheckBox2WayTrip'] as bool? ?? false,
      displayCheckBoxIsByDay: json['displayCheckBoxIsByDay'] as bool? ?? false,
      displayCheckBoxIsHalfDay:
          json['displayCheckBoxIsHalfDay'] as bool? ?? false,
      returnDateRule: (json['returnDateRule'] as num?)?.toInt() ?? 0,
      requiresReturnDate: json['requiresReturnDate'] as bool? ?? false,
      parentTripTypeId: (json['parentTripTypeId'] as num?)?.toInt(),
      allowPickup: json['allowPickup'] as bool? ?? true,
      allowDropOff: json['allowDropOff'] as bool? ?? true,
      requiresFlightNumber: json['requiresFlightNumber'] as bool? ?? false,
      requiresFlightName: json['requiresFlightName'] as bool? ?? false,
      requiresFlightDate: json['requiresFlightDate'] as bool? ?? false,
      showMeetAndGreet: json['showMeetAndGreet'] as bool? ?? false,
      showOnCurb: json['showOnCurb'] as bool? ?? false,
      showWiFi: json['showWiFi'] as bool? ?? false,
      requiresHourDuration: json['requiresHourDuration'] as bool? ?? false,
      requiresDaysDuration: json['requiresDaysDuration'] as bool? ?? false,
      timeSlotByMin: (json['timeSlotByMin'] as num?)?.toInt(),
      iconKey: json['iconKey'] as String?,
      availableNumberOfHours: _stringFromJson(json['availableNumberOfHours']),
      maxDurationForReturnDateByHour:
          (json['maxDurationForReturnDateByHour'] as num?)?.toInt() ?? 0,
      children: rawChildren is List
          ? rawChildren
              .map(
                (e) => TripTypeWithConfigModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
          : const [],
    );
  }

  static String? _stringFromJson(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}
