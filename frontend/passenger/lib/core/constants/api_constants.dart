// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String socketUrl = 'http://localhost:3000';
  
  // Auth endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  
  // User endpoints
  static const String userProfile = '/users/profile';
  static const String userRides = '/users/rides';
  static const String userById = '/users';
  
  // Ride endpoints - ADD THESE
  static const String requestRide = '/rides/request';
  static const String getRide = '/rides';  // Will be used as /rides/{id}
  static const String cancelRide = '/rides/cancel';  // Will be used as /rides/{id}/cancel
  static const String rateRide = '/rides/rate';  // Will be used as /rides/{id}/rate
  static const String rideHistory = '/rides/history';
  static const String nearbyDrivers = '/rides/nearby-drivers';
}