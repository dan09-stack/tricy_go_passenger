import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isAuthenticated') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userToken');
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAuthentication({
    required String phoneNumber,
    required String fullName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userToken', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString('userPhone', phoneNumber);
    await prefs.setString('userName', fullName);
    await prefs.setString('userEmail', email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
