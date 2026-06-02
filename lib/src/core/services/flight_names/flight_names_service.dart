import 'package:avis_package/src/core/_core.dart';

abstract class FlightNamesService {
  Future<ApiResponseModel<List<FlightNameModel>>> getFlightNames(
    String language,
  );
}
