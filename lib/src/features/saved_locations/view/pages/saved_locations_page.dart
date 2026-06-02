import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:geolocator/geolocator.dart';

import 'package:avis_package/src/core/_core.dart'
    show BackArrowWidget, AppContextExtension, AppTextStyles, TextWidget;
import 'package:avis_package/src/features/_features.dart'
    show SavedLocationsProvider, EmptySavedLocations, SavedLocationsOptions;

class SavedLocationsPage extends StatefulWidget {
  const SavedLocationsPage({super.key});

  @override
  State<SavedLocationsPage> createState() => _SavedLocationsPageState();
}

class _SavedLocationsPageState extends State<SavedLocationsPage> {
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SavedLocationsProvider>()
          .getCustomerSavedPlaces()
          .then((_) {
            _fetchDistances();
          });
    });
  }

  Future<void> _fetchDistances() async {
    try {
      if (await Geolocator.isLocationServiceEnabled() &&
          (await Geolocator.checkPermission() ==
                  LocationPermission.whileInUse ||
              await Geolocator.checkPermission() ==
                  LocationPermission.always)) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          final provider = context.read<SavedLocationsProvider>();
          provider.calculateDistances(pos.latitude, pos.longitude);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        leading: const BackArrowWidget(),
        title: TextWidget(
          'Saved Locations',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SavedLocationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.locations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final hasLocations = provider.locations.isNotEmpty;
          final shouldShowOptions = hasLocations || _showOptions;

          return SizedBox(
            width: width,
            child: shouldShowOptions
                ? const SavedLocationsOptions()
                : EmptySavedLocations(
                    onAddPressed: () {
                      setState(() {
                        _showOptions = true;
                      });
                    },
                  ),
          );
        },
      ),
    );
  }
}
