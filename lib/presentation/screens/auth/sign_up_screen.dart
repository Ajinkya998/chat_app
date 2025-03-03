import 'package:chat_app/core/common/custom_button.dart';
import 'package:chat_app/core/common/custom_text_field.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth_cubit.dart';
import 'package:chat_app/logic/cubits/auth_state.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Focus Nodes
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Validation
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Full Name";
    }
    return null;
  }

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter Username";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid Email (e.g. example@gmail.com)";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Phone Number";
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Please enter a valid Phone Number";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your Password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  Future<void> handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signUpUser(
          fullName: nameController.text,
          username: userNameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    _nameFocusNode.dispose();
    _userNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        }
      },
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.error != current.error;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Account",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Please fill details to continue",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  CustomTextField(
                    controller: nameController,
                    focusNode: _nameFocusNode,
                    validator: _validateName,
                    hintText: "Enter your Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: userNameController,
                    focusNode: _userNameFocusNode,
                    validator: _validateUserName,
                    hintText: "Enter your Username",
                    prefixIcon: const Icon(Icons.alternate_email_outlined),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: emailController,
                    focusNode: _emailFocusNode,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Enter your Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: phoneController,
                    focusNode: _phoneFocusNode,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                    hintText: "Enter your Phone Number",
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    focusNode: _passwordFocusNode,
                    validator: _validatePassword,
                    hintText: "Enter your Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: Icon(!_isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility)),
                    obscureText: !_isPasswordVisible,
                  ),
                  const SizedBox(height: 30),
                  CustomElevatedButton(
                      onPressed: handleSignUp, text: "Create Account"),
                  const SizedBox(height: 15),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account?  ",
                        style: TextStyle(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => getIt<AppRouter>().pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
