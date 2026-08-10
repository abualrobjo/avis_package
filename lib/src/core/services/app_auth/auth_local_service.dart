import 'package:avis_package/src/core/_core.dart' show AppConst, HiveService;
import 'package:avis_package/src/core/utils/route_customer_session.dart';

class AuthLocalService {
  final HiveService _hiveService;
  static const String _boxName = 'auth_box';
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _erpUserIdKey = 'erp_user_id';

  AuthLocalService(this._hiveService);

  Future<void> saveToken(String token) async {
    await _hiveService.put(_boxName, _tokenKey, token);
  }

  String? getToken() {
    return _hiveService.get<String>(_boxName, _tokenKey);
  }

  Future<void> clearToken() async {
    await _hiveService.delete(_boxName, _tokenKey);
    await clearUserId();
    await clearErpUserId();
  }

  // TODO: Save user id from response !
  Future<void> saveUserId(int userId) async {
    await _hiveService.put(_boxName, _userIdKey, userId);
  }

  int? getUserId() {
    final value = _hiveService.get<dynamic>(_boxName, _userIdKey);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Test: [AppConst.testCustomerId]. Live: `customerId` from host route args.
  int? getCustomerId() {
    if (AppConst.isTestEnvironment) return AppConst.testCustomerId;
    return RouteCustomerSession.currentCustomerId;
  }

  Future<void> clearUserId() async {
    await _hiveService.delete(_boxName, _userIdKey);
  }

  /// ERP user id from login response (erpUser_Id). Used e.g. for change password API.
  Future<void> saveErpUserId(int erpUserId) async {
    await _hiveService.put(_boxName, _erpUserIdKey, erpUserId);
  }

  int? getErpUserId() {
    final value = _hiveService.get<dynamic>(_boxName, _erpUserIdKey);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> clearErpUserId() async {
    await _hiveService.delete(_boxName, _erpUserIdKey);
  }
}
