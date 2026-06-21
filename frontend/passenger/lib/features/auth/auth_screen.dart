import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../home/home_screen.dart';

enum AuthScreenState { welcome, phoneInput, otpVerification, signUpRegistration }

class PassengerAuthScreen extends StatefulWidget {
  const PassengerAuthScreen({super.key});

  @override
  State<PassengerAuthScreen> createState() => _PassengerAuthScreenState();
}

class _PassengerAuthScreenState extends State<PassengerAuthScreen> with SingleTickerProviderStateMixin {
  AuthScreenState _currentAuthState = AuthScreenState.welcome;
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _transitionTo(AuthScreenState newState) {
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentAuthState = newState;
          _fadeController.forward(from: 0.0);
        });
      }
    });
  }

  void _simulateNetworkAction(VoidCallback onDone) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isLoading = false);
        onDone();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: _buildAuthContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthContent() {
    switch (_currentAuthState) {
      case AuthScreenState.welcome:
        return _buildWelcomeBody();
      case AuthScreenState.phoneInput:
        return _buildPhoneInputBody();
      case AuthScreenState.otpVerification:
        return _buildOtpVerificationBody();
      case AuthScreenState.signUpRegistration:
        return _buildSignUpRegistrationBody();
    }
  }

  // SCREEN 1: SPLASH WELCOME ENTRY
  Widget _buildWelcomeBody() {
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
          child: const Icon(Icons.electric_bike_rounded, size: 80, color: AppTheme.darkGray),
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
          style: TextStyle(fontSize: 16, color: Colors.white54, fontStyle: FontStyle.italic),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: AppTheme.darkGray,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: () => _transitionTo(AuthScreenState.phoneInput),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'By continuing, you agree to our Terms of Service & Privacy Policy.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: Colors.white24),
        ),
      ],
    );
  }

  // SCREEN 2: PHONE INPUT
  Widget _buildPhoneInputBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => _transitionTo(AuthScreenState.welcome),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enter your mobile number',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\'ll send a secure single-use verification code code via SMS text.',
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const VerticalDivider(color: Colors.white24, thickness: 1),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  decoration: const InputDecoration(
                    hintText: '917 123 4567',
                    hintStyle: TextStyle(color: Colors.white24, letterSpacing: 1.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: AppTheme.darkGray,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    if (_phoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid phone number.')),
                      );
                      return;
                    }
                    _simulateNetworkAction(() {
                      _transitionTo(AuthScreenState.otpVerification);
                    });
                  },
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.darkGray, strokeWidth: 2))
                : const Text('Send Verification Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // SCREEN 3: OTP OTP CODE VERIFICATION
  Widget _buildOtpVerificationBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => _transitionTo(AuthScreenState.phoneInput),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify code token',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          'Sent to +63 ${_phoneController.text}. Mock automated code bypass is [123456].',
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 12.0, color: AppTheme.primaryYellow),
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
            onPressed: () {},
            child: const Text('Didn\'t receive SMS? Resend code', style: TextStyle(color: AppTheme.primaryYellow)),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    if (_otpController.text.trim() != '123456') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid code token template. Please enter 123456.')),
                      );
                      return;
                    }
                    _simulateNetworkAction(() {
                      _transitionTo(AuthScreenState.signUpRegistration);
                    });
                  },
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // SCREEN 4: PROFILE ACCOUNT SIGNUP REGISTRATION
  Widget _buildSignUpRegistrationBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Create your profile',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Just a few details to get your tricycle hailing account ready.',
            style: TextStyle(fontSize: 14, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          
          // Avatar Selection Slot View Box
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppTheme.darkGray,
                  child: Icon(Icons.person_add_alt_1_rounded, size: 38, color: AppTheme.primaryYellow.withOpacity(0.8)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primaryYellow,
                    child: const Icon(Icons.camera_alt, size: 14, color: AppTheme.darkGray),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Fields Form Grid
          _buildFormLabel('Full Name'),
          _buildFormTextField(_nameController, 'John Doe', Icons.person_outline),
          const SizedBox(height: 18),
          
          _buildFormLabel('Email Address (Optional)'),
          _buildFormTextField(_emailController, 'john.doe@example.com', Icons.mail_outline, inputType: TextInputType.emailAddress),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkGray,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your full profile name.')),
                        );
                        return;
                      }
                      _simulateNetworkAction(() {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
                        );
                      });
                    },
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.darkGray, strokeWidth: 2))
                  : const Text('Complete Registration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white60, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildFormTextField(TextEditingController controller, String placeholder, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white38, size: 20),
          hintText: placeholder,
          hintStyle: const TextStyle(color: Colors.white12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
