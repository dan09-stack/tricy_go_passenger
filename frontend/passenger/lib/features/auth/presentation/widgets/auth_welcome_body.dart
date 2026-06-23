import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/auth/presentation/providers/auth_providers.dart';
import 'package:tricygo_passenger/features/auth/presentation/state/auth_state.dart';
import 'package:tricygo_passenger/features/auth/presentation/widgets/auth_button.dart';
import 'package:tricygo_passenger/features/home/home_screen.dart';

class AuthWelcomeBody extends ConsumerWidget {
  const AuthWelcomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authStateProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryYellow.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 4,
              )
            ],
          ),
          child: const Icon(
            Icons.electric_bike_rounded,
            size: 80,
            color: AppTheme.darkGray,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'TricyGo',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryYellow,
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          'Your Local Ride, Simplified.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white54,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Spacer(),
        AuthButton(
          label: 'Get Started',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => authNotifier.transitionTo(AuthScreenState.phoneInput),
        ),
        const SizedBox(height: 16),
        const Text(
          'By continuing, you agree to our Terms of Service & Privacy Policy.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.white24),
        ),
        // Development skip button (remove in production)
        if (true)
          TextButton(
            onPressed: () async {
              try {
                // Set test user data
                authNotifier.setPhoneNumber('9171234567');
                authNotifier.setFullName('Test User');
                authNotifier.setEmail('test@example.com');
                
                // Complete registration
                await authNotifier.completeRegistration();
                
                // Navigate to home screen
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PassengerHomeScreen(),
                    ),
                  );
                }
              } catch (e) {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Skip auth failed: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text(
              'Skip Auth (Dev Only)',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
      ],
    );
  }
}