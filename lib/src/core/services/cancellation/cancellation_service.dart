import 'package:avis_package/src/core/_core.dart';

abstract class CancellationService {
  Future<Result<int?, NetworkException>> cancelRideRequest(
    int id, {
    required int cancelationReasonId,
  });

  Future<Result<List<CancelationCategoryModel>, NetworkException>>
      getCancelationCategories({
    int categoryId = 77,
    bool all = false,
  });
}
