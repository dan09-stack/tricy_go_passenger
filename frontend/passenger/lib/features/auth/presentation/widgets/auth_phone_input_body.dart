import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/features/auth/auth_screen.dart';


class AuthPhoneInputBody extends ConsumerStatefulWidget {
  const AuthPhoneInputBody({super.key});

  @override
  ConsumerState<AuthPhoneInputBody> createState() => _AuthPhoneInputBodyState();
}

class _AuthPhoneInputBodyState extends ConsumerState<AuthPhoneInputBody> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
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
          onPressed: () => authNotifier.transitionTo(AuthScreenState.welcome),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enter your mobile number\,
          style: TextStyle(
            fontFamily: 'Poppins\,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\ll
