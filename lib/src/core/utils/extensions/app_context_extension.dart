import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart' show AppColors, AppColorsExtension;

extension AppContextExtension on BuildContext {
  AppColorsExtension get colors => AppColors.of(this);
}
