import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:avis_package/src/core/_core.dart'
    show
        BackArrowWidget,
        AppContextExtension,
        AppTextStyles,
        AppRoutes,
        AvisNavigation,
        TextWidget,
        SvgIconWidget;

import 'package:provider/provider.dart';

import 'package:avis_package/src/core/data/models/customer_saved_place_model.dart';
import '../provider/saved_locations_provider.dart';
import 'package:avis_package/src/core/utils/app_geocoding.dart';

import 'widgets/_widgets.dart';

class AddNewPlacePage extends StatefulWidget {
  const AddNewPlacePage({super.key});

  @override
  State<AddNewPlacePage> createState() => _AddNewPlacePageState();
}

class _AddNewPlacePageState extends State<AddNewPlacePage> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerSavedPlaceModel> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialSuggestions();
      _fetchDistances();
    });
  }

  void _loadInitialSuggestions() {
    final provider = context.read<SavedLocationsProvider>();
    setState(() {
      _suggestions = provider.locations.toList();
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
          if (_searchController.text.isEmpty) {
            _loadInitialSuggestions();
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        _searchPlaces(query);
      } else {
        _loadInitialSuggestions();
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() => _isSearching = true);

    final provider = context.read<SavedLocationsProvider>();
    final localMatches = provider.locations.where((loc) {
      final nameMatch = (loc.placePrimaryName ?? '').toLowerCase().contains(
        query.toLowerCase(),
      );
      final addressMatch = (loc.placeSecondaryName ?? '')
          .toLowerCase()
          .contains(query.toLowerCase());
      return nameMatch || addressMatch;
    }).toList();

    // TODO: In the future, append Google Places API results here

    if (mounted && _searchController.text == query) {
      setState(() {
        _suggestions = localMatches;
        _isSearching = false;
      });
    }
  }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    try {
      final provider = context.read<SavedLocationsProvider>();
      final localMatch = provider.locations
          .where(
            (loc) =>
                (loc.placePrimaryName ?? '').toLowerCase() ==
                    query.toLowerCase() ||
                (loc.placeSecondaryName ?? '').toLowerCase() ==
                    query.toLowerCase(),
          )
          .firstOrNull;

      double? lat;
      double? lng;

      if (localMatch != null &&
          localMatch.latitude != null &&
          localMatch.longtitude != null) {
        lat = double.tryParse(localMatch.latitude!);
        lng = double.tryParse(localMatch.longtitude!);
      } else {
        final coords = await AppGeocoding.getCoordinatesFromAddress(query);
        if (coords != null) {
          lat = coords.latitude;
          lng = coords.longitude;
        }
      }

      if (!mounted) return;
      setState(() => _isSearching = false);

      if (lat != null && lng != null) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final type = args?['type'] as String? ?? 'custom';
        AvisNavigation.push(
          context,
          AppRoutes.locationPicker,
          arguments: {
            'type': type,
            'latitude': lat,
            'longitude': lng,
            'provider': context.read<SavedLocationsProvider>(),
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address not found. Trying picking from the map.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error finding address.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: const BackArrowWidget(),
        title: TextWidget(
          'Add New Place',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colors.divider.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(
                    Icons.search,
                    color: context.colors.secondaryText,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmitted,
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.primaryText,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter an address',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_suggestions.isNotEmpty || _isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextWidget(
                'Search Suggestion',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.primaryText,
                ),
              ),
            ),
          if (_isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final place = _suggestions[index];
                  return SuggestionTile(
                    title: (place.placePrimaryName?.isNotEmpty == true)
                        ? place.placePrimaryName!
                        : 'Saved Place',
                    subtitle: place.placeSecondaryName ?? '',
                    distance: place.distanceInKm != null
                        ? '${place.distanceInKm!.toStringAsFixed(1)} km'
                        : null,
                    onTap: () {
                      final provider = context.read<SavedLocationsProvider>();
                      provider.setSelectedLocation(place);

                      final args =
                          ModalRoute.of(context)?.settings.arguments
                              as Map<String, dynamic>?;
                      final type = args?['type'] as String? ?? 'custom';
                      AvisNavigation.push(
                        context,
                        AppRoutes.locationPicker,
                        arguments: {
                          'type': type,
                          'latitude': double.tryParse(place.latitude ?? ''),
                          'longitude': double.tryParse(place.longtitude ?? ''),
                          'provider': context.read<SavedLocationsProvider>(),
                        },
                      );
                    },
                  );
                },
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>?;
                  final type = args?['type'] as String? ?? 'custom';
                  AvisNavigation.push(
                    context,
                    AppRoutes.locationPicker,
                    arguments: {
                      'type': type,
                      'provider': context.read<SavedLocationsProvider>(),
                    },
                  );
                },
                child: Container(
                  height: 48,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.colors.divider.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: context.colors.border,
                          shape: BoxShape.circle,
                        ),
                        child: const SvgIconWidget(name: 'location-08'),
                      ),
                      const SizedBox(width: 12),
                      TextWidget(
                        'Set location on map',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}
