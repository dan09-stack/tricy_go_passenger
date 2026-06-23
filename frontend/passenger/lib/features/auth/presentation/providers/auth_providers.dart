import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/features/auth/presentation/state/auth_state.dart';
import 'package:tricygo_passenger/features/auth/services/auth_service.dart';


final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  void transitionTo(AuthScreenState newState) {
    state = state.copyWith(currentState: newState);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setOtpCode(String otp) {
    state = state.copyWith(otpCode: otp);
  }

  void setFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  Future<bool> checkAuthentication() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      if (isAuthenticated) {
        final token = await _authService.getUserToken();
        if (token != null) {
          return true;
        }
      }
      return false;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Error checking authentication: ');
      return false;
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(milliseconds: 1200));
      state = state.copyWith(
        phoneNumber: phoneNumber,
        isLoading: false,
        currentState: AuthScreenState.otpVerification,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP',
      );
      rethrow;
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(milliseconds: 1200));
      
      if (otp != '123456') {
        throw Exception('Invalid OTP');
      }
      
      state = state.copyWith(
        isLoading: false,
        currentState: AuthScreenState.signUpRegistration,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid verification code',
      );
      rethrow;
    }
  }

  Future<void> completeRegistration() async {
    try {
      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(milliseconds: 1200));
      
      await _authService.saveAuthentication(
        phoneNumber: state.phoneNumber!,
        fullName: state.fullName!,
        email: state.email ?? '',
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }
}
