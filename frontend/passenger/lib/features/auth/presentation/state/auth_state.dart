// lib/features/auth/presentation/state/auth_state.dart
enum AuthScreenState {
  welcome,           // Add this
  phoneInput,
  otpVerification,
  signUpRegistration,
  authenticated,
}

class AuthState {
  final AuthScreenState currentState;
  final bool isLoading;
  final String? phoneNumber;
  final String? otpCode;
  final String? fullName;
  final String? email;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? devOtp;

  const AuthState({
    this.currentState = AuthScreenState.welcome, // Set default to welcome
    this.isLoading = false,
    this.phoneNumber,
    this.otpCode,
    this.fullName,
    this.email,
    this.errorMessage,
    this.isAuthenticated = false,
    this.devOtp,
  });

  AuthState copyWith({
    AuthScreenState? currentState,
    bool? isLoading,
    String? phoneNumber,
    String? otpCode,
    String? fullName,
    String? email,
    String? errorMessage,
    bool? isAuthenticated,
    String? devOtp,
  }) {
    return AuthState(
      currentState: currentState ?? this.currentState,
      isLoading: isLoading ?? this.isLoading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      devOtp: devOtp ?? this.devOtp,
    );
  }

  bool get isWelcome => currentState == AuthScreenState.welcome;
  bool get isPhoneInput => currentState == AuthScreenState.phoneInput;
  bool get isOtpVerification => currentState == AuthScreenState.otpVerification;
  bool get isSignUpRegistration => currentState == AuthScreenState.signUpRegistration;
  bool get isAuthenticatedState => currentState == AuthScreenState.authenticated;
}