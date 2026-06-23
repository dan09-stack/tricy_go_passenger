// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Auth endpoints
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  
  // Ride endpoints
  static const String requestRide = '/rides/request';
  static const String getRide = '/rides/';
  static const String rideHistory = '/rides/history';
  static const String cancelRide = '/rides';
  static const String rateRide = '/rides';
  static const String nearbyDrivers = '/rides/nearby-drivers';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
}