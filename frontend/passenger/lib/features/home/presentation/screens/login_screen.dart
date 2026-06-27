import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/home_screen.dart';
import 'package:tricygo_passenger/features/home/presentation/screens/signup_screen.dart';
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // ==================== LOAD SAVED CREDENTIALS ====================
  
  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('savedEmail');
      final remember = prefs.getBool('rememberMe') ?? false;
      
      if (remember && email != null) {
        setState(() {
          _emailController.text = email;
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  // ==================== VALIDATION ====================
  
  bool _validateInputs() {
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
      _showSnackBar('Please enter your password');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // ==================== SIGN IN LOGIC ====================
  
  Future<void> _handleSignIn() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Send OTP to email (using email as phoneNumber)
      final otpResponse = await _apiClient.post(
        ApiConstants.sendOtp,
        body: {
          'phoneNumber': _emailController.text.trim(),
        },
      );

      if (otpResponse['success'] != true) {
        throw Exception(otpResponse['message'] ?? 'Failed to send OTP');
      }

      // Step 2: Verify OTP (using 123456 for demo)
      // In production, you'd show an OTP verification screen
      final verifyResponse = await _apiClient.post(
        ApiConstants.verifyOtp,
        body: {
          'phoneNumber': _emailController.text.trim(),
          'code': '123456', // In production, get this from user input
          'fullName': 'User', // The backend might not need this for login
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
        
        // Save credentials if "Remember me" is checked
        if (_rememberMe) {
          await prefs.setString('savedEmail', _emailController.text.trim());
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('savedEmail');
          await prefs.setBool('rememberMe', false);
        }

        _showSnackBar(
          'Login successful! 🎉',
          isSuccess: true,
        );

        // Navigate to home after delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PassengerHomeScreen(),
              ),
            );
          }
        });
      } else {
        throw Exception(verifyResponse['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _showSnackBar('Login failed: ${e.toString()}');
    }
  }

  // ==================== FORGOT PASSWORD ====================
  
  Future<void> _handleForgotPassword() async {
    // Show dialog or navigate to forgot password screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Password reset link sent to your email');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
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
                title: 'Welcome Back!',
                subtitle: 'Sign in to continue your journey',
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
                hintText: 'Enter your password',
                obscureText: !_isPasswordVisible,
                isPassword: true,
                onToggleVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),

              // Error Message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
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

              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomCheckbox(
                    value: _rememberMe,
                    label: 'Remember me',
                    onChanged: () {
                      setState(() {
                        _rememberMe = !_rememberMe;
                      });
                    },
                  ),
                  TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign In Button - ✅ NOW WITH onPressed
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
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
                          'Sign In',
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
              const CustomDivider(text: 'or continue with'),
              const SizedBox(height: 16),

              // Social Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Google',
                      onPressed: () {
                        _showSnackBar('Google sign in coming soon!');
                      },
                      isOutlined: true,
                      icon: Icons.g_mobiledata,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Facebook',
                      onPressed: () {
                        _showSnackBar('Facebook sign in coming soon!');
                      },
                      isOutlined: true,
                      icon: Icons.facebook,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign Up Link
              AuthLink(
                question: "Don't have an account? ",
                actionText: 'Sign Up',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
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