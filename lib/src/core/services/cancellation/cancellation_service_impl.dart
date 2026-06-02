import 'package:avis_package/src/core/_core.dart';

class CancellationServiceImpl implements CancellationService {
  @override
  Future<Result<int?, NetworkException>> cancelRideRequest(int id) async {
    final validateResult = await dioClient.post<int?>(
      endpoint: ApiEndpoints.cancelRideRequest,
      queryParameters: {'id': id},
      parser: (json) {
        final response = ApiResponseModel.fromJson(json, (Object? raw) {
          return raw as int?;
        });
        return response.data;
      },
    );

    return await validateResult.when(
      success: (responseDetails) async {
        // When validate returns 1, call CancelChauffeurServiceRequest.
        if (responseDetails == 1) {
          final cancelResult = await dioClient.get<bool>(
            endpoint: ApiEndpoints.cancelChauffeurServiceRequest,
            queryParameters: {'id': id, 'CreatedBy': 0},
            parser: (json) {
              final response = ApiResponseModel.fromJson(json, (Object? raw) {
                if (raw == null) return false;
                if (raw is bool) return raw;
                return raw == 1;
              });
              return response.data;
            },
          );
          return cancelResult.when(
            success: (_) => Success<int?, NetworkException>(responseDetails),
            failure: (e) => Failure<int?, NetworkException>(e),
          );
        }
        return Success<int?, NetworkException>(responseDetails);
      },
      failure: (e) async => Failure<int?, NetworkException>(e),
    );
  }
}
