import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/auth/auth_screen.dart';
import 'package:tricygo_passenger/features/auth/presentation/state/auth_state.dart';
import 'package:tricygo_passenger/features/auth/presentation/widgets/auth_button.dart';
import 'package:tricygo_passenger/features/auth/presentation/widgets/auth_form_field.dart';

class AuthRegistrationBody extends ConsumerStatefulWidget {
  const AuthRegistrationBody({super.key});

  @override
  ConsumerState<AuthRegistrationBody> createState() => _AuthRegistrationBodyState();
}

class _AuthRegistrationBodyState extends ConsumerState<AuthRegistrationBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Create your profile',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Just a few details to get your tricycle hailing account ready.',
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppTheme.darkGray,
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 38,
                    color: AppTheme.primaryYellow.withOpacity(0.8),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primaryYellow,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: AppTheme.darkGray,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          AuthFormField(
            label: 'Full Name',
            controller: _nameController,
            placeholder: 'John Doe',
            icon: Icons.person_outline,
            isRequired: true,
          ),
          const SizedBox(height: 18),
          AuthFormField(
            label: 'Email Address (Optional)',
            controller: _emailController,
            placeholder: 'john.doe@example.com',
            icon: Icons.mail_outline,
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 48),
          AuthButton(
            label: 'Complete Registration',
            isLoading: AuthState.isLoading,
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your full profile name.')),
                );
                return;
              }
              
              authNotifier.setFullName(name);
              authNotifier.setEmail(_emailController.text.trim());
              
              try {
                await authNotifier.completeRegistration();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const PassengerHomeScreen(),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
