import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart';
import 'package:avis_package/src/features/chat/_chat.dart';
import 'package:avis_package/src/features/my_trips/_my_trips.dart';
import 'package:avis_package/src/features/services/_services.dart' show ServicesPage;

class NavigatorHandlerProvider extends ChangeNotifier {
  NavigatorHandlerProvider() {
    selectedWidget = _homeWidget;
  }

  int selectedIndex = 1;
  late Widget selectedWidget;

  static const ChatPageArgs _chatArgs = ChatPageArgs(
    tripId: '574',
    contactDisplayName: 'Driver',
    driverDisplayName: 'Driver',
    contactPhone: null,
  );

  Widget get _homeWidget => const ServicesPage();

  Widget get _chatWidget => ChangeNotifierProvider(
    create: (_) => sl<ChatProvider>(),
    child: const ChatPage(args: _chatArgs),
  );

  void changeSelectedIndexValue(int newValue) {
    selectedIndex = newValue;
    switch (selectedIndex) {
      case 1:
        selectedWidget = _homeWidget;
        break;
      case 2:
        selectedWidget = ChangeNotifierProvider(
          create: (_) => sl<MyTripsProvider>(),
          child: const MyTripsPage(),
        );
        break;
      case 3:
        selectedWidget = _chatWidget;
        break;
      case 4:
        selectedWidget = const Scaffold();
        break;
      default:
        selectedWidget = _homeWidget;
    }
    notifyListeners();
  }
}
