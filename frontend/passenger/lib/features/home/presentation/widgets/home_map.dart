import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tricygo_passenger/core/theme.dart';

class HomeMap extends StatelessWidget {
  final MapController mapController;
  final LatLng initialLocation;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final VoidCallback onMapReady;

  const HomeMap({
    super.key,
    required this.mapController,
    required this.initialLocation,
    required this.markers,
    required this.polylines,
    required this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialLocation,
        initialZoom: 15.0,
        onMapReady: onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tricygo_passenger',
          tileProvider:  NetworkTileProvider(),
        ),
        MarkerLayer(markers: markers),
        PolylineLayer(polylines: polylines),
      ],
    );
  }
}