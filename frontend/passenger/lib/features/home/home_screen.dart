import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme.dart';

enum AppState { destinationSelect, fareSelect, matching, driverEnRoute, tripCompleted }

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}


class _PassengerHomeScreenState extends State<PassengerHomeScreen> with TickerProviderStateMixin {
  AppState _currentAppState = AppState.destinationSelect;
  int passengerCount = 1;
  final TextEditingController _destinationController = TextEditingController(text: 'Central Terminal Market');
  final TextEditingController _pickupController = TextEditingController(text: 'My Current Location (7th Ave)');
  
  // Map Controllers
  late MapController _mapController;
  bool _isMapReady = false;
  
  // Locations
  final LatLng _currentLocation = const LatLng(14.5995, 120.9842); // Default Manila
  LatLng _pickupLocation = const LatLng(14.5995, 120.9842);
  final LatLng _dropoffLocation = const LatLng(14.6005, 120.9852);
  
  // Map Overlays
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  
  // Animation Controllers
  late final AnimationController _rippleController;
  late final AnimationController _vehicleController;
  double _driverProgress = 0.0;
  
  // Simulated nearby tricycles
  final List<LatLng> _nearbyTricycles = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize map controller
    _mapController = MapController();
    
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _vehicleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          if (_currentAppState == AppState.driverEnRoute) {
            _driverProgress = _vehicleController.value;
            if (_driverProgress >= 1.0) {
              _currentAppState = AppState.tripCompleted;
            }
            _updateMapOverlays();
          }
        });
      });

    // Get current location
    _getCurrentLocation();
    
    // Generate random nearby tricycles
    _generateNearbyTricycles();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _rippleController.dispose();
    _vehicleController.dispose();
    _destinationController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _updateMapOverlays();
      });
      
      // Move map to current location when ready
      if (_isMapReady) {
        _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
      }
      
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _generateNearbyTricycles() {
    final random = Random();
    _nearbyTricycles.clear();
    for (int i = 0; i < 4; i++) {
      _nearbyTricycles.add(
        LatLng(
          _currentLocation.latitude + random.nextDouble() * 0.01 - 0.005,
          _currentLocation.longitude + random.nextDouble() * 0.01 - 0.005,
        ),
      );
    }
    _updateMapOverlays();
  }

  void _updateMapOverlays() {
    setState(() {
      _markers.clear();
      _polylines.clear();
      
      // Pickup marker
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
      
      // Dropoff marker
      if (_currentAppState != AppState.destinationSelect) {
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
      
      // Nearby tricycles markers
      for (int i = 0; i < _nearbyTricycles.length; i++) {
        _markers.add(
          Marker(
            point: _nearbyTricycles[i],
            width: 30,
            height: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.electric_bike,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        );
      }
      
      // Draw route
      if (_currentAppState != AppState.destinationSelect) {
        _polylines.add(
          Polyline(
            points: [_pickupLocation, _dropoffLocation],
            color: AppTheme.primaryYellow,
            strokeWidth: 5.0,
          ),
        );
      }
      
      // Add driver marker when en route
      if (_currentAppState == AppState.driverEnRoute) {
        final driverLat = _pickupLocation.latitude + 
            (_dropoffLocation.latitude - _pickupLocation.latitude) * _driverProgress;
        final driverLng = _pickupLocation.longitude + 
            (_dropoffLocation.longitude - _pickupLocation.longitude) * _driverProgress;
        
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

  void _triggerDriverMatchSequence() {
    setState(() {
      _currentAppState = AppState.matching;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentAppState == AppState.matching) {
        setState(() {
          _currentAppState = AppState.driverEnRoute;
          _vehicleController.forward(from: 0.0);
          _updateMapOverlays();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.electric_bike, color: AppTheme.darkGray, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('TricyGo', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        backgroundColor: AppTheme.darkGray,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: AppTheme.primaryYellow),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryYellow,
              child: Text('JD', style: TextStyle(color: AppTheme.darkGray, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // REAL MAP - FlutterMap with OpenStreetMap
          FlutterMap(
            mapController: _mapController,  // Pass the controller directly
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.0,
              onMapReady: () {
                setState(() {
                  _isMapReady = true;
                });
                // Move to current location when map is ready
                _mapController.move(_pickupLocation, 15.0);
              },
              onTap: (tapPosition, point) {
                // Handle map tap if needed
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
          if (_currentAppState != AppState.destinationSelect)
            Positioned(
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: AppTheme.darkGray.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentAppState = AppState.destinationSelect;
                      _vehicleController.reset();
                      _driverProgress = 0.0;
                      _updateMapOverlays();
                    });
                  },
                ),
              ),
            ),

          // Bottom Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomInterfacePanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInterfacePanel() {
    switch (_currentAppState) {
      case AppState.destinationSelect:
        return _buildDestinationSelectSheet();
      case AppState.fareSelect:
        return _buildFareSelectSheet();
      case AppState.matching:
        return _buildMatchingRadarSheet();
      case AppState.driverEnRoute:
        return _buildDriverTrackingSheet();
      case AppState.tripCompleted:
        return _buildTripCompletedSheet();
    }
  }

  // PANEL STATE 1: Select Destination & Riders
  Widget _buildDestinationSelectSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0, -4))],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.adjust, color: AppTheme.secondaryGreen, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _pickupController,
                  decoration: const InputDecoration(hintText: 'Pickup Location', border: InputBorder.none),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryYellow, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(hintText: 'Where to?', border: InputBorder.none),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of Passengers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Container(
                decoration: BoxDecoration(color: AppTheme.backgroundDark, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (passengerCount > 1) setState(() => passengerCount--);
                      },
                    ),
                    Text('$passengerCount', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        if (passengerCount < 4) setState(() => passengerCount++);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkGray,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: () {
                setState(() {
                  _currentAppState = AppState.fareSelect;
                  _updateMapOverlays();
                });
              },
              child: const Text('Confirm Route & Pricing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  // PANEL STATE 2: Fare Selection
  Widget _buildFareSelectSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Tricycle Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow)),
          const SizedBox(height: 16),
          _buildFareTierItem('TricyGo EcoShare', '₱45.00', '2 mins away', Icons.people_outline, true),
          _buildFareTierItem('TricyGo Express', '₱70.00', 'Immediate pickup', Icons.flash_on, false),
          _buildFareTierItem('TricyGo ComfortXL', '₱110.00', 'Heavy load / Luggage', Icons.bento_outlined, false),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _triggerDriverMatchSequence,
              child: const Text('Request TricyGo Ride', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFareTierItem(String name, String price, String eta, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF383838) : AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppTheme.primaryYellow : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryYellow, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(eta, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow)),
        ],
      ),
    );
  }

  // PANEL STATE 3: Matching
  Widget _buildMatchingRadarSheet() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(color: AppTheme.primaryYellow, strokeWidth: 3.5),
          ),
          const SizedBox(height: 20),
          const Text(
            'Finding Your Closest Tricycle Driver...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Broadcasting booking request to nearby operators pool via WebSockets',
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentAppState = AppState.destinationSelect;
                _vehicleController.reset();
                _driverProgress = 0.0;
                _updateMapOverlays();
              });
            },
            child: const Text('Cancel Request', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  // PANEL STATE 4: Live Driver Tracking
  Widget _buildDriverTrackingSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryYellow,
                child: Icon(Icons.person, color: AppTheme.darkGray, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Speedy Tricycler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppTheme.primaryYellow, size: 16),
                        const SizedBox(width: 4),
                        const Text('4.9', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.backgroundDark, borderRadius: BorderRadius.circular(4)),
                          child: const Text('Verified Pro', style: TextStyle(fontSize: 10, color: AppTheme.secondaryGreen)),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(3 * (1.0 - _driverProgress)).toStringAsFixed(1)} mins',
                    style: const TextStyle(color: AppTheme.primaryYellow, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text('Arriving Soon', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.backgroundDark, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vehicle: Yellow Bajaj RE 4S', style: TextStyle(fontSize: 13, color: Colors.white70)),
                Text('Plate: TRI-7788', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF444444), foregroundColor: Colors.white),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call Driver'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryGreen, foregroundColor: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // PANEL STATE 5: Trip Completed
  Widget _buildTripCompletedSheet() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.secondaryGreen, size: 56),
          const SizedBox(height: 12),
          const Text('Arrived at Destination!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Thank you for riding with TricyGo', style: TextStyle(fontSize: 13, color: Colors.white54), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Fare Paid (Cash)', style: TextStyle(fontSize: 14)),
              Text('₱45.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow, foregroundColor: AppTheme.darkGray),
              onPressed: () {
                setState(() {
                  _currentAppState = AppState.destinationSelect;
                  _vehicleController.reset();
                  _driverProgress = 0.0;
                  _updateMapOverlays();
                });
              },
              child: const Text('Book Another Ride', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}