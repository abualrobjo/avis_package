import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart';

class LocalizationProvider extends ChangeNotifier {
  final SettingsLocalService _settingsLocalService;

  LocalizationProvider(this._settingsLocalService) {
    _loadLocale();
  }

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void _loadLocale() {
    final languageCode = _settingsLocalService.getLocale();
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> changeLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _settingsLocalService.saveLocale(locale.languageCode);
    notifyListeners();
  }

  bool get isArabic => _locale.languageCode == 'ar';
}
