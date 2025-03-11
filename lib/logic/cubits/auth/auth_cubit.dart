import 'dart:async';

import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:chat_app/logic/cubits/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: AuthStatus.initial));

    _authStateSubscription =
        _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final userData = await _authRepository.getUser(user.uid);
          emit(state.copyWith(
              status: AuthStatus.authenticated, user: userData, error: null));
        } catch (e) {
          emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    });
  }

  // Sign In User
  Future<void> signInUser(
      {required String email, required String password}) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user =
          await _authRepository.signInUser(email: email, password: password);
      emit(state.copyWith(
          status: AuthStatus.authenticated, user: user, error: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  // Sign Up User
  Future<void> signUpUser(
      {required String fullName,
      required String username,
      required String email,
      required String phoneNumber,
      required String password}) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signUpUser(
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  // Sign Out User
  Future<void> signOutUser() async {
    try {
      await _authRepository.signOutUser();
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }
}
