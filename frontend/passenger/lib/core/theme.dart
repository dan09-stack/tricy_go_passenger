import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color secondaryGreen = Color(0xFF1DB954);
  static const Color darkGray = Color(0xFF2C2C2C);
  static const Color backgroundDark = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryYellow,
        secondary: Color(0xFF1DB954),
        surface: darkGray,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: primaryYellow),
        titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
    );
  }
}
