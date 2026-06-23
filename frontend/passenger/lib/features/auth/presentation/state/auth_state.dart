enum AuthScreenState { welcome, phoneInput, otpVerification, signUpRegistration }

class AuthState {
  final AuthScreenState currentState;
  final bool isLoading;
  final String? phoneNumber;
  final String? otpCode;
  final String? fullName;
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.currentState = AuthScreenState.welcome,
    this.isLoading = false,
    this.phoneNumber,
    this.otpCode,
    this.fullName,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthScreenState? currentState,
    bool? isLoading,
    String? phoneNumber,
    String? otpCode,
    String? fullName,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      currentState: currentState ?? this.currentState,
      isLoading: isLoading ?? this.isLoading,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
