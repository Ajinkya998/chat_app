import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:flutter/material.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'router/app_router.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: getIt<AppRouter>().navigatorKey,
      title: 'Chat Application',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
