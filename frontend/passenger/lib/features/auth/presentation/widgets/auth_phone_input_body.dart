import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/auth/presentation/providers/auth_providers.dart';
import 'package:tricygo_passenger/features/auth/presentation/state/auth_state.dart';
import 'auth_button.dart';

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
          'Enter your mobile number',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\'ll send a secure single-use verification code via SMS text.',
          style: TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.darkGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Text(
                '🇵🇭 +63',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const VerticalDivider(color: Colors.white24, thickness: 1),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: '917 123 4567',
                    hintStyle: TextStyle(
                      color: Colors.white24,
                      letterSpacing: 1.0,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        AuthButton(
          label: 'Send Verification Code',
          isLoading: authState.isLoading,
          onPressed: () async {
            final phone = _phoneController.text.trim();
            if (phone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid phone number.')),
              );
              return;
            }
            try {
              await authNotifier.sendOtp(phone);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}