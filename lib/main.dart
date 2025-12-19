import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChowafaApp());
}

class ChowafaApp extends StatelessWidget {
  const ChowafaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChowafaGpt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6B3FA0),
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF9B59B6),
          secondary: const Color(0xFFE74C3C),
          surface: const Color(0xFF1A1A2E),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
