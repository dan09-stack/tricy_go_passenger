import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricygo_passenger/features/auth/presentation/screens/passenger_auth_screen.dart';
import 'package:tricygo_passenger/features/home/models/ride_model.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/core/network/api_socket.dart';
import 'package:tricygo_passenger/features/home/presentation/providers/home_providers.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/destination_select_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/driver_tracking_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/fare_select_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/home_app_bar.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/home_map.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/matching_radar_sheet.dart';
import 'package:tricygo_passenger/features/home/presentation/widgets/trip_completed_sheet.dart';

class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen>
    with TickerProviderStateMixin {
  // Controllers
  late MapController _mapController;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  // Location
  LatLng _currentLocation = const LatLng(14.5995, 120.9842);
  LatLng _pickupLocation = const LatLng(14.5995, 120.9842);
  LatLng _dropoffLocation = const LatLng(14.6005, 120.9852);
  
  // Map
  bool _isMapReady = false;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  
  // Animation
  late final AnimationController _vehicleController;
  double _driverProgress = 0.0;
  
  // User
  String _userInitial = 'U';
  
  // Nearby drivers
  final List<LatLng> _nearbyDrivers = [];
  
  // Constants
  static const double _defaultZoom = 15.0;
  static const int _maxNearbyDrivers = 4;
  static const int _matchingDelaySeconds = 3;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserInfo();
    _getCurrentLocation();
    _generateNearbyDrivers();
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ==================== INITIALIZATION ====================
  
  void _initializeControllers() {
    _mapController = MapController();
    _vehicleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onVehicleAnimationTick);
  }

  void _disposeControllers() {
    _mapController.dispose();
    _vehicleController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
  }

  // ==================== ANIMATION ====================
  
  void _onVehicleAnimationTick() {
    if (!mounted) return;
    
    setState(() {
      if (ref.read(homeProvider) == HomeState.driverEnRoute) {
        _driverProgress = _vehicleController.value;
        if (_driverProgress >= 1.0) {
          _handleRideCompleted();
        }
        _updateMapOverlays();
      }
    });
  }

  // ==================== SOCKET LISTENERS ====================
  
  void _setupSocketListeners() {
    apiSocket.onRideStatusChange(_handleRideStatusChange);
    apiSocket.onDriverLocationUpdate(_handleDriverLocationUpdate);
  }

  void _handleRideStatusChange(dynamic data) {
    final rideId = data['rideId'] as String?;
    final status = data['status'] as String?;
    
    final currentRide = ref.read(currentRideProvider);
    if (rideId != currentRide?.id || status == null) return;

    switch (status) {
      case 'matched':
        _onRideMatched();
        break;
      case 'completed':
        _handleRideCompleted();
        break;
      case 'cancelled':
        _onRideCancelled();
        break;
      default:
        break;
    }
  }

  void _handleDriverLocationUpdate(dynamic data) {
    final location = data['location'] as Map<String, dynamic>?;
    if (location != null && ref.read(homeProvider) == HomeState.driverEnRoute) {
      setState(() {
        _driverProgress = 0.5;
        _updateMapOverlays();
      });
    }
  }

  void _onRideMatched() {
    ref.read(homeProvider.notifier).setState(HomeState.driverEnRoute);
    _vehicleController.forward(from: 0.0);
  }

  void _onRideCancelled() {
    ref.read(homeProvider.notifier).setState(HomeState.destinationSelect);
    _resetRideState();
  }

  // ==================== USER INFO ====================
  
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('fullName') ?? 'User';
      if (mounted) {
        setState(() {
          _userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  // ==================== LOGOUT ====================
  
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PassengerAuthScreen()),
          );
        }
      } catch (e) {
        debugPrint('Logout error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to logout. Please try again.')),
          );
        }
      }
    }
  }

  // ==================== LOCATION ====================
  
  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) return;
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (!mounted) return;
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _updateMapOverlays();
      });
      
      if (_isMapReady) {
        _mapController.move(_pickupLocation, _defaultZoom);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showSnackBar('Failed to get location. Using default location.');
    }
  }

  // ==================== DRIVERS ====================
  
  void _generateNearbyDrivers() {
    final random = Random();
    _nearbyDrivers.clear();
    for (int i = 0; i < _maxNearbyDrivers; i++) {
      _nearbyDrivers.add(
        LatLng(
          _currentLocation.latitude + random.nextDouble() * 0.01 - 0.005,
          _currentLocation.longitude + random.nextDouble() * 0.01 - 0.005,
        ),
      );
    }
    _updateMapOverlays();
  }

  // ==================== MAP OVERLAYS ====================
  
  void _updateMapOverlays() {
    if (!mounted) return;
    
    setState(() {
      _markers.clear();
      _polylines.clear();
      
      _addPickupMarker();
      _addDropoffMarker();
      _addNearbyDriverMarkers();
      _addRoutePolyline();
      _addDriverMarker();
    });
  }

  void _addPickupMarker() {
    _markers.add(Marker(
      point: _pickupLocation,
      width: 40,
      height: 40,
      child: const Icon(Icons.location_on_rounded, color: Colors.green, size: 40),
    ));
  }

  void _addDropoffMarker() {
    if (ref.read(homeProvider) != HomeState.destinationSelect) {
      _markers.add(Marker(
        point: _dropoffLocation,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
      ));
    }
  }

  void _addNearbyDriverMarkers() {
    for (final driver in _nearbyDrivers) {
      _markers.add(Marker(
        point: driver,
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.electric_bike, color: Colors.white, size: 18),
        ),
      ));
    }
  }

  void _addRoutePolyline() {
    if (ref.read(homeProvider) != HomeState.destinationSelect) {
      _polylines.add(Polyline(
        points: [_pickupLocation, _dropoffLocation],
        color: AppTheme.primaryYellow,
        strokeWidth: 5.0,
      ));
    }
  }

  void _addDriverMarker() {
    if (ref.read(homeProvider) == HomeState.driverEnRoute) {
      final driverLat = _pickupLocation.latitude + 
          (_dropoffLocation.latitude - _pickupLocation.latitude) * _driverProgress;
      final driverLng = _pickupLocation.longitude + 
          (_dropoffLocation.longitude - _pickupLocation.longitude) * _driverProgress;
      
      _markers.add(Marker(
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
                color: AppTheme.primaryYellow.withAlpha(128),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.directions_bike, color: Colors.white, size: 24),
        ),
      ));
    }
  }

  // ==================== RIDE ACTIONS ====================
  
  Future<void> _handleRequestRide() async {
    final notifier = ref.read(homeProvider.notifier);
    
    try {
      await notifier.requestRide(
        pickupLocation: LocationModel(
          lat: _pickupLocation.latitude,
          lng: _pickupLocation.longitude,
          address: _pickupController.text.isNotEmpty ? _pickupController.text : 'Current Location',
        ),
        dropoffLocation: LocationModel(
          lat: _dropoffLocation.latitude,
          lng: _dropoffLocation.longitude,
          address: _destinationController.text.isNotEmpty ? _destinationController.text : 'Destination',
        ),
        passengerCount: 2,
        paymentMethod: 'cash',
      );
      
      final ride = ref.read(currentRideProvider);
      if (ride?.id != null) {
        apiSocket.joinRide(ride!.id!);
      }
      
      Future.delayed(const Duration(seconds: _matchingDelaySeconds), () {
        if (mounted && ref.read(homeProvider) == HomeState.matching) {
          ref.read(homeProvider.notifier).setState(HomeState.driverEnRoute);
          _vehicleController.forward(from: 0.0);
        }
      });
    } catch (e) {
      _showSnackBar('Failed to request ride: $e');
    }
  }

  Future<void> _handleCancelRide() async {
    try {
      await ref.read(homeProvider.notifier).cancelRide();
      final ride = ref.read(currentRideProvider);
      if (ride?.id != null) {
        apiSocket.leaveRide(ride!.id!);
      }
      _resetRideState();
      _showSnackBar('Ride cancelled successfully');
    } catch (e) {
      _showSnackBar('Failed to cancel ride: $e');
    }
  }

  Future<void> _handleRideCompleted() async {
    await ref.read(homeProvider.notifier).completeRide();
    final ride = ref.read(currentRideProvider);
    if (ride?.id != null) {
      apiSocket.leaveRide(ride!.id!);
    }
    _resetRideState();
  }

  void _resetRideState() {
    setState(() {
      _vehicleController.reset();
      _driverProgress = 0.0;
      _updateMapOverlays();
    });
  }

  // ==================== NAVIGATION ====================
  
  void _handleGoBack() {
    if (ref.read(homeProvider) == HomeState.matching) {
      _handleCancelRide();
    } else {
      ref.read(homeProvider.notifier).setState(HomeState.destinationSelect);
      _resetRideState();
    }
  }

  void _handleBookAgain() {
    ref.read(homeProvider.notifier).setState(HomeState.destinationSelect);
    _resetRideState();
  }

  // ==================== HELPERS ====================
  
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==================== BUILD ====================
  
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final currentRide = ref.watch(currentRideProvider);

    return Scaffold(
      appBar: HomeAppBar(
        userInitial: _userInitial,
        onLogout: _logout,
        onNotification: () {
          _showSnackBar('No new notifications');
        },
      ),
      body: Stack(
        children: [
          // Map (full screen)
          HomeMap(
            mapController: _mapController,
            initialLocation: _currentLocation,
            markers: _markers,
            polylines: _polylines,
            onMapReady: _onMapReady,
          ),
          
          // Back Button (on top of map)
          if (homeState != HomeState.destinationSelect)
            _buildBackButton(),

          // Loading Overlay
          if (isLoading)
            _buildLoadingOverlay(),

          // Bottom Sheet - Properly positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(homeState, isLoading, currentRide),
          ),
        ],
      ),
    );
  }

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _isMapReady = true);
    _mapController.move(_pickupLocation, _defaultZoom);
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: CircleAvatar(
        backgroundColor: AppTheme.darkGray.withAlpha(200),
        foregroundColor: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleGoBack,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return const Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryYellow),
      ),
    );
  }

  Widget _buildBottomSheet(HomeState state, bool isLoading, RideModel? ride) {
    Widget sheetContent;
    
    switch (state) {
      case HomeState.destinationSelect:
        sheetContent = DestinationSelectSheet(
          pickupController: _pickupController,
          destinationController: _destinationController,
          passengerCount: 2,
          onPassengerCountChanged: () {},
          onConfirm: () {
            ref.read(homeProvider.notifier).setState(HomeState.fareSelect);
            _updateMapOverlays();
          },
        );
        break;
      case HomeState.fareSelect:
        sheetContent = FareSelectSheet(
          isLoading: isLoading,
          onRequestRide: _handleRequestRide,
        );
        break;
      case HomeState.matching:
        sheetContent = MatchingRadarSheet(
          onCancel: _handleCancelRide,
        );
        break;
      case HomeState.driverEnRoute:
        sheetContent = DriverTrackingSheet(
          driverProgress: _driverProgress,
        );
        break;
      case HomeState.tripCompleted:
        sheetContent = TripCompletedSheet(
          onBookAgain: _handleBookAgain,
        );
        break;
      default:
        sheetContent = const SizedBox.shrink();
    }

    // Wrap with container to ensure it stays at bottom
    return Align(
      alignment: Alignment.bottomCenter,
      child: sheetContent,
    );
  }
}