import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:avis_package/src/core/_core.dart' show sl;
import 'package:avis_package/src/features/_features.dart' show NavigatorHandlerProvider;
import 'bottom_navigation_bar_widget.dart';

class NavigatorHandlerPage extends StatelessWidget {
  const NavigatorHandlerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigatorHandlerProvider>(
      create: (_) => sl<NavigatorHandlerProvider>(),
      child: const _NavigatorHandlerPageView(),
    );
  }
}

class _NavigatorHandlerPageView extends StatefulWidget {
  const _NavigatorHandlerPageView();

  @override
  State<_NavigatorHandlerPageView> createState() =>
      _NavigatorHandlerPageViewState();
}

class _NavigatorHandlerPageViewState extends State<_NavigatorHandlerPageView> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NavigatorHandlerProvider>(
      context,
      listen: true,
    );

    return Scaffold(
      bottomNavigationBar: const BottomNavigationBarWidget(),
      body: provider.selectedWidget,
    );
  }
}
