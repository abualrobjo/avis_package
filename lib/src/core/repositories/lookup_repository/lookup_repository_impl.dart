import 'package:avis_package/src/core/_core.dart';

class LookupRepositoryImpl implements LookupRepository {
  final LookupService _lookupService;

  LookupRepositoryImpl(this._lookupService);

  @override
  Future<Result<List<LookupModel>, NetworkException>> getLookupByCategoryId({
    required String language,
    required int categoryId,
  }) {
    return _lookupService.getLookupByCategoryId(
      language: language,
      categoryId: categoryId,
    );
  }
}
