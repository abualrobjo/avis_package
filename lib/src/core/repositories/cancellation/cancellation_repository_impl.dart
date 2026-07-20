import 'package:avis_package/src/core/_core.dart';

class CancellationRepositoryImpl implements CancellationRepository {
  final CancellationService _cancellationService;

  const CancellationRepositoryImpl(this._cancellationService);

  @override
  Future<Result<int?, NetworkException>> cancelRideRequest(
    int id, {
    required int cancelationReasonId,
  }) async {
    return await _cancellationService.cancelRideRequest(
      id,
      cancelationReasonId: cancelationReasonId,
    );
  }

  @override
  Future<Result<List<CancelationCategoryModel>, NetworkException>>
      getCancelationCategories({
    int categoryId = 77,
    bool all = false,
  }) async {
    return _cancellationService.getCancelationCategories(
      categoryId: categoryId,
      all: all,
    );
  }
}
