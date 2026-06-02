import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:avis_package/src/core/_core.dart' show AppSpaces, BackArrowWidget, sl;
import 'package:avis_package/src/features/map/provider/map_provider.dart';
import 'package:avis_package/src/features/map/view/widgets/_widgets.dart';

class MapPage extends StatefulWidget {
  final int tripId;
  final bool showBackArrow;
  final bool showInfoCard;
  final bool isStaticMap;
  final MapProvider? mapProvider;

  const MapPage({
    super.key,
    required this.tripId,
    this.showBackArrow = true,
    this.showInfoCard = true,
    this.isStaticMap = false,
    this.mapProvider,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapProvider? _mapProvider;
  MapProvider get _provider => widget.mapProvider ?? _mapProvider!;

  @override
  void initState() {
    super.initState();
    if (widget.mapProvider == null) {
      _mapProvider = sl<MapProvider>();
      _initTrip();
    }
  }

  Future<void> _initTrip() async {
    await _mapProvider?.fetchTrip(
      widget.tripId,
      startTracking: !widget.isStaticMap,
    );
    if (!widget.isStaticMap) {
      await _mapProvider?.fetchPolyline();
      await _mapProvider?.fetchEtaToDropOff(force: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _provider.updateMapStyle(isDark: isDark);
  }

  @override
  void dispose() {
    _mapProvider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If a provider was passed in, we still wrap with value provider
    // just in case MapPage children rely on it. If they don't, it's harmless.
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MapProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            body: Stack(
              children: [
                if (provider.mapState == MapState.loading)
                  const Center(child: CircularProgressIndicator())
                else
                  GoogleMap(
                    style: provider.mapStyle,
                    initialCameraPosition: CameraPosition(
                      target: provider.startLocation,
                      zoom: 14.5,
                    ),
                    padding: EdgeInsets.only(
                      bottom: widget.showInfoCard ? 350 : 0,
                    ),
                    polylines: provider.polylines,
                    markers: provider.markers,
                    liteModeEnabled: widget.isStaticMap,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    onMapCreated: provider.setMapController,
                  ),
                if (widget.showBackArrow)
                  const PositionedDirectional(
                    start: AppSpaces.medium,
                    top: AppSpaces.xSmall,
                    child: SafeArea(child: BackArrowWidget()),
                  ),
                if (widget.showInfoCard && provider.tripInfo != null)
                  InfoCard(tripInfo: provider.tripInfo!),
              ],
            ),
          );
        },
      ),
    );
  }
}
