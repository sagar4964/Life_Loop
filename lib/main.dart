
import 'package:flutter/material.dart';

// LifeLoop Screens
import 'view/authentication /forget_password_screen.dart';
import 'view/profile/profile_screen.dart';

void main() {
  runApp(const LifeLoopApp());
}

class LifeLoopApp extends StatelessWidget {
  const LifeLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'LifeLoop',

      // Application Theme
      theme: ThemeData(
        primaryColor: const Color(0xFF075D35),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF075D35),
        ),
        useMaterial3: true,
      ),

      // Starting Screen
      home: const ProfileScreen(),

      // Application Routes
      routes: {
        '/forget-password': (context) =>
        const ForgotPasswordScreen(),

        '/profile': (context) =>
        const ProfileScreen(),
      },
    );
  }
}
