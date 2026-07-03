import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/core/theme.dart';
// IMPORTANT: Make sure you're importing the correct auth screen
import 'package:tricygo_passenger/features/home/presentation/screens/auth_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TricyGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthScreen(), // ← This should be the correct AuthScreen
    );
  }
}