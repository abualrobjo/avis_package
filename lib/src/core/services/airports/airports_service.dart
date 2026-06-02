import 'package:avis_package/src/core/_core.dart';

abstract class AirportsService {
  Future<ApiResponseModel<List<AirportModel>>> getAirports();
}
