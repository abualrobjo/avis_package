import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart' show SettingsLocalService;

class ThemeModeProvider extends ChangeNotifier {
  final SettingsLocalService _settingsLocalService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeModeProvider(this._settingsLocalService) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = _settingsLocalService.getThemeMode();
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _settingsLocalService.saveThemeMode(mode.toString());
  }
}
