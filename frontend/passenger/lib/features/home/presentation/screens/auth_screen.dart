import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
import 'package:tricygo_passenger/features/home/presentation/screens/login_screen.dart';
import 'package:tricygo_passenger/features/home/presentation/screens/signup_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;

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
                controller: _tabController, // ✅ Must be connected
                indicator: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppTheme.darkGray, // Color when selected
                unselectedLabelColor: Colors.grey, // Color when not selected
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
                controller: _tabController, // ✅ Must use same controller
                children: const [
                  SignInScreen(),
                  SignUpScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}