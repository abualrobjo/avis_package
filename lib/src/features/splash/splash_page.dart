import 'package:flutter/material.dart';

import 'package:avis_package/src/core/_core.dart'
    show AvisNavigation, AppRoutes, ImageWidget;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      AvisNavigation.pushReplacement(context, AppRoutes.servicePage);
      // AvisNavigation.pushReplacement(context, AppRoutes.myTrips);
      // AvisNavigation.pushReplacement(context, AppRoutes.savedLocations);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 375,
          height: 95,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 26, horizontal: 42),
            child: ImageWidget(name: 'logo'),
          ),
        ),
      ),
    );
  }
}
