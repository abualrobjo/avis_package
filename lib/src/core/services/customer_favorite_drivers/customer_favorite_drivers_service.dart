import 'package:avis_package/src/core/_core.dart';

abstract class CustomerFavoriteDriversService {
  Future<ApiResponseModel<bool>> addFavoriteDriver(
    CustomerFavoriteDriversParams params,
  );
}
