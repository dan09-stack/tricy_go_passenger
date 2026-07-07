// lib/core/constants/api_constants.dart
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://192.168.0.199:3000/api';
  static const String socketUrl = 'http://192.168.0.199:3000';
  
  // ==================== AUTH ENDPOINTS ====================
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String devLogin = '/auth/dev-login'; 
  
  // ==================== USER ENDPOINTS ====================
  static const String userProfile = '/users/profile';
  static const String userRides = '/users/rides';
  static const String userById = '/users';
  static const String updateProfile = '/users/profile';
  static const String driverProfile = '/users/driver-profile';
  static const String driverLocation = '/users/driver-location';
  
  // ==================== RIDE ENDPOINTS ====================
  static const String requestRide = '/rides/request';
  static const String getRide = '/rides';
  static const String cancelRide = '/rides/cancel';
  static const String rateRide = '/rides/rate';
  static const String rideHistory = '/rides/history';
  static const String nearbyDrivers = '/rides/nearby-drivers';
  static const String acceptRide = '/rides/accept';
  static const String startRide = '/rides/start';
  static const String completeRide = '/rides/complete';
  
  // ==================== HEALTH ENDPOINTS ====================
  static const String health = '/health';
  static const String detailedHealth = '/health/detailed';
  static const String readiness = '/health/readiness';
  static const String liveness = '/health/liveness';
}

// Helper extension for building URLs
extension ApiConstantsExtension on String {
  String get fullUrl => '${ApiConstants.baseUrl}$this';
}