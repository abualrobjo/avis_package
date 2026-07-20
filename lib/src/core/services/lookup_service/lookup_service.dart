import 'package:avis_package/src/core/_core.dart';

abstract class LookupService {
  Future<Result<List<LookupModel>, NetworkException>> getLookupByCategoryId({
    required String language,
    required int categoryId,
  });
}
