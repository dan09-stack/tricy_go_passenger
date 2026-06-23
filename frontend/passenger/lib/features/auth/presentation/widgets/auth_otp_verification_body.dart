import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/features/auth/auth_screen.dart';


class AuthOtpVerificationBody extends ConsumerStatefulWidget {
  const AuthOtpVerificationBody({super.key});

  @override
  ConsumerState<AuthOtpVerificationBody> createState() => _AuthOtpVerificationBodyState();
}

class _AuthOtpVerificationBodyState extends ConsumerState<AuthOtpVerificationBody> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => authNotifier.transitionTo(AuthScreenState.phoneInput),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify code token',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sent to +63 ${authState.phoneNumber ?? ""}. Mock automated code bypass is [123456].',
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 12.0,
            color: AppTheme.primaryYellow,
          ),
          maxLength: 6,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppTheme.darkGray,
            hintText: '000000',
            hintStyle: const TextStyle(color: Colors.white12, letterSpacing: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white10),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OTP resent successfully!')),
              );
            },
            child: const Text(
              'Didn't
