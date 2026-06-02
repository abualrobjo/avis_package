/// One item from GetAirports API responseDetails list.
/// API uses "airportPimaryName" (typo).
class AirportModel {
  final int id;
  final String? airportPimaryName;
  final String? airportSecondaryName;
  final String? cityPrimaryName;
  final String? citySecondaryName;
  final String? latitude;
  final String? longitude;

  const AirportModel({
    required this.id,
    this.airportPimaryName,
    this.airportSecondaryName,
    this.cityPrimaryName,
    this.citySecondaryName,
    this.latitude,
    this.longitude,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) {
    return AirportModel(
      id: (json['id'] as num).toInt(),
      airportPimaryName: json['airportPimaryName'] as String?,
      airportSecondaryName: json['airportSecondaryName'] as String?,
      cityPrimaryName: json['cityPrimaryName'] as String?,
      citySecondaryName: json['citySecondaryName'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
    );
  }
}
