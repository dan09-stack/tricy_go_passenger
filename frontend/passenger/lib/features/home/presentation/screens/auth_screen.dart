import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/home_screen.dart';
import 'package:tricygo_passenger/features/home/presentation/screens/login_screen.dart';
import 'package:tricygo_passenger/features/home/presentation/screens/signup_screen.dart';
import 'package:tricygo_passenger/core/network/api_client.dart';
import 'package:tricygo_passenger/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isDevLoginLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to rebuild when tab changes
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==================== DEV LOGIN ====================
  
  Future<void> _handleDevLogin() async {
    setState(() {
      _isDevLoginLoading = true;
    });

    try {
      final apiClient = ApiClient();
      
      // Call dev login endpoint
      final response = await apiClient.post(
        ApiConstants.devLogin,
        body: {
          'phoneNumber': '09123456789',
          'fullName': 'Dev User',
        },
      );

      if (response['success'] == true) {
        // Save token and user data
        final token = response['data']['token'] as String;
        final user = response['data']['user'] as Map<String, dynamic>;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userToken', token);
        await prefs.setString('userData', jsonEncode(user));
        await prefs.setString('fullName', 'Dev User');
        
        // Navigate to home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PassengerHomeScreen(),
            ),
          );
        }
      } else {
        _showSnackBar('Dev login failed: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showSnackBar('Dev login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDevLoginLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
        child: Column(
          children: [
            // App Logo/Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TricyGo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryYellow,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Text(
                    'Ride smarter, travel safer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppTheme.darkGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.darkGray,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Sign In'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController, 
                children: const [
                  SignInScreen(),
                  SignUpScreen(),
                ],
              ),
            ),
            
            // Dev Login Button at Bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.developer_mode,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Dev Login',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _isDevLoginLoading ? null : _handleDevLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryYellow,
                          foregroundColor: AppTheme.darkGray,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: _isDevLoginLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.darkGray,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}