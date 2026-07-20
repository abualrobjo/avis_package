import 'package:avis_package/src/core/_core.dart';

abstract class LookupRepository {
  Future<Result<List<LookupModel>, NetworkException>> getLookupByCategoryId({
    required String language,
    required int categoryId,
  });
}
