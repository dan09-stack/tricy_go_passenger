// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';
import 'package:tricygo_passenger/core/exceptions/api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  void setToken(String token) {
    _token = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _headers.remove('Authorization');
  }

  Future<Map<String, String>> _getHeaders() async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('userToken');
      if (token != null) {
        setToken(token);
      }
    }
    return _headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final dynamic jsonResponse = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonResponse;
    } else {
      final message = jsonResponse['message'] ?? 'Unknown error occurred';
      final errors = jsonResponse['errors'];
      
      throw ApiException(
        message,
        statusCode: response.statusCode,
        errors: errors,
      );
    }
  }
}