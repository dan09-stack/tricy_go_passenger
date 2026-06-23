// lib/features/home/services/ride_service.dart
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/features/home/models/ride.dart';
import 'package:tricygo_passenger/features/home/models/fare_tier.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';

class RideService {
  final ApiClient _apiClient = ApiClient();

  Future<Ride> requestRide({
    required Map<String, dynamic> pickupLocation,
    required Map<String, dynamic> dropoffLocation,
    required int passengerCount,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.requestRide,
        body: {
          'pickupLocation': pickupLocation,
          'dropoffLocation': dropoffLocation,
          'passengerCount': passengerCount,
          'paymentMethod': paymentMethod,
        },
      );

      return Ride.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to request ride: $e');
    }
  }

  Future<Ride> getRideDetails(String rideId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.getRide}$rideId',
      );
      return Ride.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to get ride details: $e');
    }
  }

  Future<List<Ride>> getRideHistory() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.rideHistory,
      );
      final List<dynamic> ridesData = response['data'];
      return ridesData.map((json) => Ride.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get ride history: $e');
    }
  }

  Future<void> cancelRide(String rideId, {String? reason}) async {
    try {
      await _apiClient.post(
        '${ApiConstants.cancelRide}/$rideId/cancel',
        body: {'reason': reason},
      );
    } catch (e) {
      throw Exception('Failed to cancel ride: $e');
    }
  }

  Future<void> rateRide({
    required String rideId,
    required int rating,
    String? review,
  }) async {
    try {
      await _apiClient.post(
        '${ApiConstants.rateRide}/$rideId/rate',
        body: {
          'rating': rating,
          'review': review,
        },
      );
    } catch (e) {
      throw Exception('Failed to rate ride: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyDrivers({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.nearbyDrivers}?lat=$lat&lng=$lng',
      );
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      throw Exception('Failed to get nearby drivers: $e');
    }
  }

  List<FareTier> getFareTiers() {
    // This could also come from the backend
    return const [
      FareTier(
        id: "eco_share",
        name: "TricyGo EcoShare",
        price: 45.00,
        eta: "2 mins away",
        icon: "people_outline",
        isSelected: true,
      ),
      FareTier(
        id: "express",
        name: "TricyGo Express",
        price: 70.00,
        eta: "Immediate pickup",
        icon: "flash_on",
        isSelected: false,
      ),
      FareTier(
        id: "comfort_xl",
        name: "TricyGo ComfortXL",
        price: 110.00,
        eta: "Heavy load / Luggage",
        icon: "bento_outlined",
        isSelected: false,
      ),
    ];
  }
}