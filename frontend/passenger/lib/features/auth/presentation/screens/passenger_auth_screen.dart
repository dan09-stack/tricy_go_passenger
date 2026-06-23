import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:tricygo_passenger/core/theme.dart";
import "package:tricygo_passenger/features/auth/presentation/state/auth_state.dart";
import "package:tricygo_passenger/features/auth/presentation/widgets/auth_otp_verification_body.dart";
import "package:tricygo_passenger/features/auth/presentation/widgets/auth_phone_input_body.dart";
import "package:tricygo_passenger/features/auth/presentation/widgets/auth_welcome_body.dart";
import "package:tricygo_passenger/features/home/home_screen.dart";
import ../providers/auth_providers.dart;
import ../state/auth_state.dart;
import ../widgets/auth_welcome_body.dart;
import ../widgets/auth_phone_input_body.dart;
import ../widgets/auth_otp_verification_body.dart;
import ../widgets/auth_registration_body.dart;
import ../../../../core/theme.dart;

class PassengerAuthScreen extends ConsumerStatefulWidget {
  const PassengerAuthScreen({super.key});

  @override
  ConsumerState<PassengerAuthScreen> createState() => _PassengerAuthScreenState();
}

class _PassengerAuthScreenState extends ConsumerState<PassengerAuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _checkAuthentication();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final isAuthenticated = await authNotifier.checkAuthentication();
    
    if (isAuthenticated && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PassengerHomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: _buildAuthContent(authState),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthContent(AuthState authState) {
    switch (authState.currentState) {
      case AuthScreenState.welcome:
        return const AuthWelcomeBody();
      case AuthScreenState.phoneInput:
        return const AuthPhoneInputBody();
      case AuthScreenState.otpVerification:
        return const AuthOtpVerificationBody();
      case AuthScreenState.signUpRegistration:
        return const AuthRegistrationBody();
    }
  }
}
