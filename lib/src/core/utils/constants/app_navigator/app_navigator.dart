import 'package:flutter/material.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>(debugLabel: "Navigation Key");

  static BuildContext? get context => navigatorKey.currentContext;
}
