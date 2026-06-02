import 'package:avis_package/src/core/_core.dart';

abstract class ChauffeurRequestService {
  Future<ApiResponseModel<BookChauffeurRequestDetails>> bookChauffeurRequest(
    BookChauffeurRequestBody body,
  );
}
