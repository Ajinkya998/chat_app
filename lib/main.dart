import 'package:chat_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'presentation/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Application',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
