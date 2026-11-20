import 'package:flutter/material.dart';
import 'profile_page.dart';

void main() {
  runApp(const LifeLoopApp());
}

class LifeLoopApp extends StatelessWidget {
  const LifeLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLoop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F2),
      ),
      home: const ProfilePage(
        fullName: 'Ananya Sharma',
        username: '@ananya',
      ),
    );
  }
}
