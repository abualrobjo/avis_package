import 'package:flutter/material.dart';

import 'package:avis_package/src/core/routes/avis_navigation.dart';

class AppNavigator {
  static GlobalKey<NavigatorState> get navigatorKey =>
      AvisNavigation.navigatorKey;

  static BuildContext? get context => AvisNavigation.context;
}
