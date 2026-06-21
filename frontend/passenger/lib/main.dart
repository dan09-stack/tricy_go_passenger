import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TricyGoPassengerApp(),
    ),
  );
}

class TricyGoPassengerApp extends StatelessWidget {
  const TricyGoPassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TricyGo Passenger',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const PassengerAuthScreen(),
    );
  }
}
