import 'package:avis_package/src/core/_core.dart';

class CancellationRepositoryImpl implements CancellationRepository {
  final CancellationService _cancellationService;

  const CancellationRepositoryImpl(this._cancellationService);

  @override
  Future<Result<int?, NetworkException>> cancelRideRequest(int id) async {
    return await _cancellationService.cancelRideRequest(id);
  }
}
