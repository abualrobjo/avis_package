import 'package:avis_package/src/core/_core.dart';

class ChauffeurRequestServiceImpl implements ChauffeurRequestService {
  ChauffeurRequestServiceImpl(this._client);

  final DioClient _client;

  @override
  Future<ApiResponseModel<BookChauffeurRequestDetails>> bookChauffeurRequest(
    BookChauffeurRequestBody body,
  ) async {
    final result = await _client
        .post<ApiResponseModel<BookChauffeurRequestDetails>>(
      endpoint: ApiEndpoints.bookChauffeurRequest,
      body: body.toJson(),
      parser: (data) => ApiResponseModel.fromJson(
        data as Map<String, dynamic>,
        (raw) => raw == null
            ? const BookChauffeurRequestDetails(id: 0)
            : BookChauffeurRequestDetails.fromJson(
                Map<String, dynamic>.from(raw as Map)),
      ),
    );
    return result.when(
      success: (api) => api,
      failure: (e) => ApiResponseModel(
        errorCode: -1,
        errorMessage: e.message,
        isSuccess: false,
        data: const BookChauffeurRequestDetails(id: 0),
      ),
    );
  }
}
