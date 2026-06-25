// lib/features/auth/services/ride_service.dart (or move to lib/features/ride/services/ride_service.dart)
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';
import 'package:tricygo_passenger/features/ride/models/ride.dart';
import 'package:tricygo_passenger/core/exceptions/api_exception.dart';

class RideService {
  final ApiClient _apiClient = ApiClient();

  // Request a ride
  Future<Ride> requestRide({
    required Location pickupLocation,
    required Location dropoffLocation,
    required int passengerCount,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.requestRide,
        body: {
          'pickupLocation': pickupLocation.toJson(),
          'dropoffLocation': dropoffLocation.toJson(),
          'passengerCount': passengerCount,
          'paymentMethod': paymentMethod,
        },
      );

      if (response['success'] == true) {
        final rideData = response['data'];
        return Ride.fromJson(rideData);
      } else {
        throw Exception(response['message'] ?? 'Failed to request ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to request ride: $e');
    }
  }

  // Get ride details by ID
  Future<Ride> getRide(String rideId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.getRide}/$rideId',
      );

      if (response['success'] == true) {
        final rideData = response['data'];
        return Ride.fromJson(rideData);
      } else {
        throw Exception(response['message'] ?? 'Failed to get ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to get ride: $e');
    }
  }

  // Get ride history for current user
  Future<List<Ride>> getRideHistory() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.rideHistory,
      );

      if (response['success'] == true) {
        final ridesData = response['data'] as List<dynamic>? ?? [];
        return ridesData.map((ride) => Ride.fromJson(ride)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to get ride history');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to get ride history: $e');
    }
  }

  // Cancel a ride
  Future<void> cancelRide(String rideId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.cancelRide}/$rideId',
        body: {}, // Empty body for POST request
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to cancel ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to cancel ride: $e');
    }
  }

  // Rate a ride
  Future<void> rateRide({
    required String rideId,
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.rateRide}/$rideId',
        body: {
          'rating': rating,
          'review': review,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to rate ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to rate ride: $e');
    }
  }

  // Get nearby drivers
  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required double lat,
    required double lng,
    double radius = 5.0, // in kilometers
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.nearbyDrivers}?lat=$lat&lng=$lng&radius=$radius',
      );

      if (response['success'] == true) {
        final driversData = response['data'] as List<dynamic>? ?? [];
        return driversData.map((driver) => Map<String, dynamic>.from(driver)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to get nearby drivers');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to get nearby drivers: $e');
    }
  }

  // Accept a ride (for drivers - if needed in passenger app)
  // Usually this is for driver app, but you might need it for status updates
  Future<void> acceptRide(String rideId) async {
    try {
      final response = await _apiClient.post(
        '/rides/$rideId/accept',
        body: {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to accept ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to accept ride: $e');
    }
  }

  // Start a ride (for drivers)
  Future<void> startRide(String rideId) async {
    try {
      final response = await _apiClient.post(
        '/rides/$rideId/start',
        body: {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to start ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to start ride: $e');
    }
  }

  // Complete a ride (for drivers)
  Future<void> completeRide(String rideId) async {
    try {
      final response = await _apiClient.post(
        '/rides/$rideId/complete',
        body: {},
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to complete ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to complete ride: $e');
    }
  }
}

// Singleton instance
final rideService = RideService();