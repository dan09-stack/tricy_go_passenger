import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/presentation/screens/login_screen.dart';
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ==================== VALIDATION ====================
  
  bool _validateInputs() {
    // Validate full name
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your full name');
      return false;
    }
    if (_nameController.text.trim().length < 2) {
      _showSnackBar('Name must be at least 2 characters');
      return false;
    }

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email address');
      return false;
    }
    if (!_isValidEmail(_emailController.text)) {
      _showSnackBar('Please enter a valid email address');
      return false;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please create a password');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return false;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      _showSnackBar('Please confirm your password');
      return false;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      _showSnackBar('Passwords do not match');
      return false;
    }

    // Validate terms
    if (!_agreeToTerms) {
      _showSnackBar('Please agree to the Terms of Service and Privacy Policy');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ==================== SIGN UP LOGIC ====================
  
  Future<void> _handleSignUp() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Send OTP
      final otpResponse = await _apiClient.post(
        ApiConstants.sendOtp,
        body: {
          'phoneNumber': _emailController.text, // Using email as identifier
        },
      );

      if (otpResponse['success'] != true) {
        throw Exception(otpResponse['message'] ?? 'Failed to send OTP');
      }

      // Step 2: Verify OTP (using 123456 for demo)
      final verifyResponse = await _apiClient.post(
        ApiConstants.verifyOtp,
        body: {
          'phoneNumber': _emailController.text,
          'code': '123456', // In production, get this from user input
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
        },
      );

      if (verifyResponse['success'] == true) {
        // Save token and user data
        final token = verifyResponse['data']['token'] as String;
        final user = verifyResponse['data']['user'] as Map<String, dynamic>;
        
        // Save using SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', token);
        await prefs.setString('userData', jsonEncode(user));
        await prefs.setString('fullName', _nameController.text.trim());
        await prefs.setString('email', _emailController.text.trim());

        _showSnackBar(
          'Account created successfully! 🎉',
          isSuccess: true,
        );

        // Navigate to login after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInScreen(),
              ),
            );
          }
        });
      } else {
        throw Exception(verifyResponse['message'] ?? 'Registration failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showSnackBar('Registration failed: ${e.toString()}');
    }
  }

  // ==================== HELPERS ====================
  
  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==================== BUILD ====================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const AuthHeader(
                title: 'Create Account',
                subtitle: 'Join us and start your journey',
              ),

              // Full Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'John Doe',
              ),

              // Email Field
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Create a strong password',
                obscureText: !_isPasswordVisible,
                isPassword: true,
                onToggleVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),

              // Confirm Password Field
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hintText: 'Confirm your password',
                obscureText: !_isConfirmPasswordVisible,
                isPassword: true,
                onToggleVisibility: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),

              // Error Message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1), // ✅ Fixed: withValues instead of withOpacity
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3), // ✅ Fixed
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

              // Terms and Conditions
              CustomCheckbox(
                value: _agreeToTerms,
                label: '',
                isRichText: true,
                richTextSpans: const [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                onChanged: () {
                  setState(() {
                    _agreeToTerms = !_agreeToTerms;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Sign Up Button - ✅ Fixed: onPressed type mismatch
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleSignUp(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.darkGray,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // OR Divider
              const CustomDivider(text: 'or sign up with'),
              const SizedBox(height: 16),

              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Google',
                      onPressed: () {},
                      isOutlined: true,
                      icon: Icons.g_mobiledata,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Facebook',
                      onPressed: () {},
                      isOutlined: true,
                      icon: Icons.facebook,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In Link
              AuthLink(
                question: 'Already have an account? ',
                actionText: 'Sign In',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}