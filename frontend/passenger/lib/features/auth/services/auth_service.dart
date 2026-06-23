// lib/features/auth/services/auth_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/exceptions/api_exception.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _apiClient.post(
        ApiConstants.sendOTP,
        body: {'phoneNumber': phoneNumber},
      );
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String code,
    String? fullName,
    String? email,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOTP,
        body: {
          'phoneNumber': phoneNumber,
          'code': code,
          'fullName': fullName,
          'email': email,
        },
      );

      final token = response['data']['token'];
      final user = response['data']['user'];
      
      // Save token and user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userToken', token);
      await prefs.setString('userData', user.toString());
      
      _apiClient.setToken(token);
      
      return {
        'token': token,
        'user': user,
      };
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token != null) {
        _apiClient.setToken(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _apiClient.clearToken();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}