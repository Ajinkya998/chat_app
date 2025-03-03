import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth_cubit.dart';
import 'package:chat_app/presentation/screens/auth/login_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await getIt<AuthCubit>().signOutUser();
                getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text("User is Authenticated"),
      ),
    );
  }
}
