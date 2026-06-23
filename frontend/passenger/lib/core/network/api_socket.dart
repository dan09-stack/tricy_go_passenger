// lib/core/network/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');

      _socket = IO.io('http://localhost:3000', {
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': {
          'Authorization': 'Bearer $token',
        },
      });

      _socket?.connect();

      _socket?.on('connect', (_) {
        _isConnected = true;
        print('🔌 WebSocket connected');
      });

      _socket?.on('disconnect', (_) {
        _isConnected = false;
        print('🔌 WebSocket disconnected');
      });

      _socket?.on('error', (error) {
        print('⚠️ WebSocket error: $error');
      });

      _socket?.on('ride-status-updated', (data) {
        // Handle ride status update
        print('🚗 Ride status updated: $data');
      });

      _socket?.on('driver-location-update', (data) {
        // Handle driver location update
        print('📍 Driver location updated: $data');
      });

      _socket?.on('notification', (data) {
        // Handle push notification
        print('🔔 Notification received: $data');
      });
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
    }
  }

  void disconnect() {
    if (_socket != null && _isConnected) {
      _socket?.disconnect();
      _socket?.dispose();
      _isConnected = false;
    }
  }

  void joinRide(String rideId) {
    if (_isConnected) {
      _socket?.emit('join-ride', rideId);
    }
  }

  void leaveRide(String rideId) {
    if (_isConnected) {
      _socket?.emit('leave-ride', rideId);
    }
  }

  void sendDriverLocation(Map<String, dynamic> data) {
    if (_isConnected) {
      _socket?.emit('driver-location', data);
    }
  }

  bool get isConnected => _isConnected;
}