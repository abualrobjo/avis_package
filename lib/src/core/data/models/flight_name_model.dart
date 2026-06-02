/// One airline/flight name from GetFlightNames API responseDetails.
class FlightNameModel {
  final int id;
  final String? airlineName;
  final String? airlinePrimaryName;
  final String? airlineSecondaryName;
  final String? iata;
  final String? icao;
  final String? callsign;
  final String? country;

  const FlightNameModel({
    required this.id,
    this.airlineName,
    this.airlinePrimaryName,
    this.airlineSecondaryName,
    this.iata,
    this.icao,
    this.callsign,
    this.country,
  });

  String get displayName =>
      airlinePrimaryName ?? airlineSecondaryName ?? airlineName ?? '';

  factory FlightNameModel.fromJson(Map<String, dynamic> json) {
    return FlightNameModel(
      id: (json['id'] as num).toInt(),
      airlineName: json['airlineName'] as String?,
      airlinePrimaryName: json['airlinePrimaryName'] as String?,
      airlineSecondaryName: json['airlineSecondaryName'] as String?,
      iata: json['iata'] as String?,
      icao: json['icao'] as String?,
      callsign: json['callsign'] as String?,
      country: json['country'] as String?,
    );
  }
}
