import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';
import 'package:tricygo_passenger/features/home/models/ride_model.dart';
import 'package:tricygo_passenger/core/exceptions/api_exception.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  Future<RideModel> requestRide({
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
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
        return RideModel.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to request ride');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to request ride: $e');
    }
  }

  Future<void> cancelRide(String rideId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.cancelRide}/$rideId',
        body: {},
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

  Future<void> rateRide({
    required String rideId,
    required double rating,
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

  Future<List<RideModel>> getRideHistory() async {
    try {
      final response = await _apiClient.get(ApiConstants.rideHistory);

      if (response['success'] == true) {
        final ridesData = response['data'] as List<dynamic>? ?? [];
        return ridesData.map((ride) => RideModel.fromJson(ride)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to get ride history');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to get ride history: $e');
    }
  }
}