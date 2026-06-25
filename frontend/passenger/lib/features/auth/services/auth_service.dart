// lib/features/auth/services/auth_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/network/api_socket.dart';
import 'package:tricygo_passenger/core/exceptions/api_exception.dart';

class AuthService {
  static const String _tokenKey = 'userToken';
  static const String _userKey = 'userData';
  final ApiClient _apiClient = ApiClient();

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get user token
  Future<String?> getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return Map<String, dynamic>.from(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _apiClient.post('/auth/send-otp', body: {
        'phoneNumber': phoneNumber,
      });
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String code,
    String? fullName,
    String? email,
  }) async {
    try {
      final response = await _apiClient.post('/auth/verify-otp', body: {
        'phoneNumber': phoneNumber,
        'code': code,
        'fullName': fullName,
        'email': email,
      });
      
      // Save authentication data
      if (response['success'] == true) {
        final data = response['data'];
        final token = data['token'];
        final user = data['user'];
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user));
        
        // Set token in API client
        _apiClient.setToken(token);
        
        // Connect socket after authentication
        apiSocket.connect();
        
        return response;
      } else {
        throw Exception(response['message'] ?? 'Authentication failed');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Save authentication (login/register) - for backward compatibility
  Future<void> saveAuthentication({
    required String phoneNumber,
    required String fullName,
    String? email,
  }) async {
    try {
      // This is a placeholder - in a real app, you'd call verifyOtp
      // with the actual OTP code
      final response = await _apiClient.post('/auth/verify-otp', body: {
        'phoneNumber': phoneNumber,
        'code': '123456', // In real app, use actual OTP from user
        'fullName': fullName,
        'email': email,
      });
      
      if (response['success'] == true) {
        final data = response['data'];
        final token = data['token'];
        final user = data['user'];
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user));
        
        // Set token in API client
        _apiClient.setToken(token);
        
        // Connect socket after authentication
        apiSocket.connect();
      } else {
        throw Exception(response['message'] ?? 'Authentication failed');
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to save authentication: $e');
    }
  }

  // Complete registration
  Future<void> completeRegistration({
    required String fullName,
    String? email,
  }) async {
    try {
      // If you have a separate registration endpoint
      // final response = await _apiClient.post('/auth/register', body: {
      //   'fullName': fullName,
      //   'email': email,
      // });
      
      // For now, just update user data in local storage
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final user = Map<String, dynamic>.from(jsonDecode(userJson));
        user['fullName'] = fullName;
        if (email != null) user['email'] = email;
        await prefs.setString(_userKey, jsonEncode(user));
      }
    } catch (e) {
      throw Exception('Failed to complete registration: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint if needed
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Even if API call fails, clear local data
    } finally {
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      // Clear token in API client
      _apiClient.clearToken();
      
      // Disconnect socket
      apiSocket.disconnect();
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final response = await _apiClient.put('/users/profile', body: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
      });
      
      if (response['success'] == true) {
        final updatedUser = response['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(updatedUser));
      }
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}