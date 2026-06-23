// lib/core/exceptions/api_exception.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(
    this.message, {
    this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'API Error ($statusCode): $message';
    }
    return 'API Error: $message';
  }
}