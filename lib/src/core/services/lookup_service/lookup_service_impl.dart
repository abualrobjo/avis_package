import 'package:avis_package/src/core/_core.dart';

class LookupServiceImpl implements LookupService {
  @override
  Future<Result<List<LookupModel>, NetworkException>> getLookupByCategoryId({
    required String language,
    required int categoryId,
  }) {
    return dioClient.get<List<LookupModel>>(
      endpoint: ApiEndpoints.lookupByCategory,
      queryParameters: {
        'language': language,
        'categoryId': categoryId.toString(),
      },
      parser: (json) {
        final response = ApiResponseModel.fromJson(
          json as Map<String, dynamic>,
          (Object? raw) {
            if (raw is! List) return <LookupModel>[];
            return raw
                .map(
                  (e) => LookupModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .where((e) => !e.isDeleted)
                .toList();
          },
        );
        return response.data;
      },
    );
  }
}
