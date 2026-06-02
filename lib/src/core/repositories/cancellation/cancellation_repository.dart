import 'package:avis_package/src/core/_core.dart';

abstract class CancellationRepository {
  Future<Result<int?, NetworkException>> cancelRideRequest(int id);
}
