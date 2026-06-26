// lib/features/auth/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/features/auth/presentation/state/auth_state.dart';
import 'package:tricygo_passenger/features/auth/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
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

  void setDevOtp(String otp) {
    state = state.copyWith(devOtp: otp);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
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
      state = state.copyWith(errorMessage: 'Error checking authentication');
      return false;
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Call the actual API
      await _authService.sendOtp(phoneNumber);
      
      state = state.copyWith(
        phoneNumber: phoneNumber,
        isLoading: false,
        currentState: AuthScreenState.otpVerification,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final response = await _authService.verifyOtp(
        phoneNumber: state.phoneNumber!,
        code: otp,
        fullName: state.fullName,
        email: state.email,
      );
      
      // Check if registration is needed
      if (response['data']['user']['isVerified'] == false) {
        state = state.copyWith(
          isLoading: false,
          currentState: AuthScreenState.signUpRegistration,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
        );
      }
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
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _authService.completeRegistration(
        fullName: state.fullName!,
        email: state.email,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Registration failed: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      // Even if logout fails, clear local state
      state = const AuthState();
    }
  }
}