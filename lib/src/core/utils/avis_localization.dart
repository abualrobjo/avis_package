import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:avis_package/src/generated/codegen_loader.g.dart';

/// Resolves a localization key using the host [EasyLocalization] setup when
/// available, otherwise falls back to [CodegenLoader] bundled in avis_package.
String avisTr(String key, {BuildContext? context}) {
  final fromHost = key.tr();
  if (fromHost != key) return fromHost;

  final languageCode = _languageCode(context);
  final localeMap = CodegenLoader.mapLocales[languageCode];
  if (localeMap == null) return key;

  final value = _nestedLookup(localeMap, key.split('.'));
  return value ?? key;
}

String _languageCode(BuildContext? context) {
  if (context != null) {
    try {
      return context.locale.languageCode;
    } catch (_) {
      return Localizations.localeOf(context).languageCode;
    }
  }
  return 'en';
}

String? _nestedLookup(Map<String, dynamic> map, List<String> parts) {
  dynamic current = map;
  for (final part in parts) {
    if (current is! Map<String, dynamic>) return null;
    current = current[part];
  }
  return current is String ? current : null;
}
