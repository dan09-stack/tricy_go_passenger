// lib/core/network/api_socket.dart
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiSocket {
  static final ApiSocket _instance = ApiSocket._internal();
  factory ApiSocket() => _instance;
  ApiSocket._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;

  String get socketUrl {
    return const String.fromEnvironment(
      'SOCKET_URL',
      defaultValue: 'http://localhost:3000',
    );
  }

  void connect() {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;

    try {
      // Configure socket options
      final options = {
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'forceNew': true,
        'extraHeaders': {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Credentials': 'true',
        },
      };

      // Create socket instance
      _socket = io.io(socketUrl, options);

      // Set up event listeners
      _setupListeners();

      // Connect
      _socket!.connect();
      
      debugPrint('🔌 Attempting to connect to WebSocket...');
    } catch (e) {
      debugPrint('❌ Error connecting to socket: $e');
      _isConnecting = false;
    }
  }

  void _setupListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      debugPrint('✅ Socket connected!');
      _authenticateSocket();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _isConnecting = false;
      debugPrint('❌ Socket disconnected');
    });

    _socket!.onConnectError((data) {
      _isConnecting = false;
      debugPrint('⚠️ Socket connection error: $data');
    });

    _socket!.onError((data) {
      debugPrint('⚠️ Socket error: $data');
    });

    _socket!.onReconnect((_) {
      debugPrint('🔄 Socket reconnected');
      _isConnected = true;
      _authenticateSocket();
    });

    _socket!.onReconnectError((data) {
      debugPrint('⚠️ Socket reconnect error: $data');
    });

    _socket!.onReconnectFailed((_) {
      debugPrint('❌ Socket reconnection failed');
      _isConnected = false;
      _isConnecting = false;
    });
  }

  void _authenticateSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      
      if (token != null && token.isNotEmpty && _socket != null && _isConnected) {
        _socket!.emit('authenticate', {'token': token});
        debugPrint('🔐 Socket authenticated');
      }
    } catch (e) {
      debugPrint('❌ Failed to authenticate socket: $e');
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      debugPrint('Socket disconnected and disposed');
    }
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
      debugPrint('📤 Event emitted: $event');
    } else {
      debugPrint('⚠️ Cannot emit event: socket not connected');
    }
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
    }
  }

  void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
    }
  }

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  // Ride events
  void joinRide(String rideId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join-ride', rideId);
      debugPrint('📡 Joined ride: $rideId');
    }
  }

  void leaveRide(String rideId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave-ride', rideId);
      debugPrint('📡 Left ride: $rideId');
    }
  }

  void requestRideUpdate(String rideId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('request-ride-update', rideId);
    }
  }

  // Listeners for ride updates
  void onRideUpdate(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('ride-update', callback);
    }
  }

  void onDriverLocationUpdate(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('driver-location', callback);
    }
  }

  void onDriverAssigned(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('driver-assigned', callback);
    }
  }

  void onRideStatusChange(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('ride-status-change', callback);
    }
  }

  // Remove event listeners
  void offRideUpdate() {
    if (_socket != null) {
      _socket!.off('ride-update');
    }
  }

  void offDriverLocationUpdate() {
    if (_socket != null) {
      _socket!.off('driver-location');
    }
  }

  void offDriverAssigned() {
    if (_socket != null) {
      _socket!.off('driver-assigned');
    }
  }

  void offRideStatusChange() {
    if (_socket != null) {
      _socket!.off('ride-status-change');
    }
  }
}

// Singleton instance
final apiSocket = ApiSocket();