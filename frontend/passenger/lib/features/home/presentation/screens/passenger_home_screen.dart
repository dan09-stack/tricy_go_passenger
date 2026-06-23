
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/auth/presentation/screens/passenger_auth_screen.dart';
import 'package:tricygo_passenger/features/home/presentation/providers/home_providers.dart';
import 'package:tricygo_passenger/features/home/presentation/state/home_state.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/home_app_bar.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/destination_select_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/fare_select_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/matching_radar_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/driver_tracking_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/trip_completed_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/map_overlay.dart';
import 'package:tricygo_passenger/features/home/services/location_service.dart';

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> 
    with TickerProviderStateMixin {
  late MapController _mapController;
  bool _isMapReady = false;
  
  // Locations
  LatLng _pickupLocation = const LatLng(14.5995, 120.9842);
  final LatLng _dropoffLocation = const LatLng(14.6005, 120.9852);
  
  // Map Overlays
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  
  // Animation Controllers
  late final AnimationController _rippleController;
  late final AnimationController _vehicleController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _vehicleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        final progress = _vehicleController.value;
        ref.read(homeStateProvider.notifier).updateDriverProgress(progress);
        _updateMapOverlays();
      });

    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _rippleController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocation();
      setState(() {
        _pickupLocation = location;
        _updateMapOverlays();
      });
      if (_isMapReady) {
        _mapController.move(location, 15.0);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _updateMapOverlays() {
    final state = ref.read(homeStateProvider);
    setState(() {
      _markers.clear();
      _polylines.clear();
      
      // Add pickup marker
      _markers.add(
        Marker(
          point: _pickupLocation,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on_rounded,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
      
      // Add dropoff marker
      if (state.currentState != AppState.destinationSelect) {
        _markers.add(
          Marker(
            point: _dropoffLocation,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      }
      
      // Draw route
      if (state.currentState != AppState.destinationSelect) {
        _polylines.add(
          Polyline(
            points: [_pickupLocation, _dropoffLocation],
            color: AppTheme.primaryYellow,
            strokeWidth: 5.0,
          ),
        );
      }
      
      // Add driver marker when en route
      if (state.currentState == AppState.driverEnRoute) {
        final driverLat = _pickupLocation.latitude + 
            (_dropoffLocation.latitude - _pickupLocation.latitude) * state.driverProgress;
        final driverLng = _pickupLocation.longitude + 
            (_dropoffLocation.longitude - _pickupLocation.longitude) * state.driverProgress;
        
        _markers.add(
          Marker(
            point: LatLng(driverLat, driverLng),
            width: 44,
            height: 44,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryYellow, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bike,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    
    return Scaffold(
      appBar: HomeAppBar(
        onLogout: _handleLogout,
        onNotifications: _handleNotifications,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickupLocation,
              initialZoom: 15.0,
              onMapReady: () {
                setState(() {
                  _isMapReady = true;
                });
                _mapController.move(_pickupLocation, 15.0);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tricygo_passenger',
                tileProvider:  NetworkTileProvider(),
              ),
              MarkerLayer(markers: _markers),
              PolylineLayer(polylines: _polylines),
            ],
          ),
          
          // Back Button
          if (homeState.currentState != AppState.destinationSelect)
            Positioned(
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: AppTheme.darkGray.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleBackPressed,
                ),
              ),
            ),

          // Bottom Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomInterfacePanel(homeState),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInterfacePanel(HomeState state) {
    switch (state.currentState) {
      case AppState.destinationSelect:
        return DestinationSelectSheet(
          pickupLocation: state.pickupLocation,
          destinationLocation: state.destinationLocation,
          passengerCount: state.passengerCount,
          onPassengerCountChanged: (count) {
            ref.read(homeStateProvider.notifier).setPassengerCount(count);
          },
          onConfirm: () {
            ref.read(homeStateProvider.notifier).setState(AppState.fareSelect);
            _updateMapOverlays();
          },
        );
      case AppState.fareSelect:
        return FareSelectSheet(
          onRequestRide: () async {
            try {
              final notifier = ref.read(homeStateProvider.notifier);
              await notifier.requestRide();
              _vehicleController.forward(from: 0.0);
              _updateMapOverlays();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        );
      case AppState.matching:
        return MatchingRadarSheet(
          onCancel: _handleCancelRide,
        );
      case AppState.driverEnRoute:
        return DriverTrackingSheet(
          driverName: 'Speedy Tricycler',
          driverRating: 4.9,
          driverVehicle: 'Yellow Bajaj RE 4S',
          driverPlate: 'TRI-7788',
          eta: (3 * (1.0 - state.driverProgress)).toStringAsFixed(1),
          onMessage: () {},
          onCall: () {},
        );
      case AppState.tripCompleted:
        return TripCompletedSheet(
          fare: 45.00,
          onBookAgain: _handleBookAgain,
        );
    }
  }

  void _handleLogout() async {
    // Implement logout logic
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PassengerAuthScreen()),
      );
    }
  }

  void _handleNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No new notifications')),
    );
  }

  void _handleBackPressed() {
    final notifier = ref.read(homeStateProvider.notifier);
    notifier.resetToDestinationSelect();
    _vehicleController.reset();
    _updateMapOverlays();
  }

  void _handleCancelRide() async {
    try {
      final notifier = ref.read(homeStateProvider.notifier);
      await notifier.cancelRide();
      _vehicleController.reset();
      _updateMapOverlays();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _handleBookAgain() {
    final notifier = ref.read(homeStateProvider.notifier);
    notifier.resetToDestinationSelect();
    _vehicleController.reset();
    _updateMapOverlays();
  }
}

