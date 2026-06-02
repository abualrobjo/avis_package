import 'package:avis_package/src/core/_core.dart';

class SettingsLocalService {
  final HiveService _hiveService;

  SettingsLocalService(this._hiveService);

  static const String _boxName = 'settings_box';
  static const String _rememberMeKey = 'remember_me';
  static const String _localeKey = 'locale';

  Future<void> saveRememberMe(bool value) async {
    await _hiveService.put(_boxName, _rememberMeKey, value);
  }

  bool getRememberMe() {
    return _hiveService.get<bool>(
          _boxName,
          _rememberMeKey,
          defaultValue: false,
        ) ??
        false;
  }

  Future<void> saveLocale(String languageCode) async {
    await _hiveService.put(_boxName, _localeKey, languageCode);
  }

  String? getLocale() {
    return _hiveService.get<String>(_boxName, _localeKey);
  }

  static const String _themeModeKey = 'theme_mode';

  Future<void> saveThemeMode(String themeMode) async {
    await _hiveService.put(_boxName, _themeModeKey, themeMode);
  }

  String? getThemeMode() {
    return _hiveService.get<String>(_boxName, _themeModeKey);
  }
}
