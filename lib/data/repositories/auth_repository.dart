import 'dart:developer';

import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository {
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Sign Up User
  Future<UserModel> signUpUser(
      {required String fullName,
      required String username,
      required String email,
      required String phoneNumber,
      required String password}) async {
    try {
      final formattedPhoneNumber =
          phoneNumber.replaceAll(RegExp(r'\s+'), "".trim());
      final userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user == null) {
        throw "Failed to create user";
      }

      final user = UserModel(
        uid: userCredential.user!.uid,
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: formattedPhoneNumber,
      );

      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Sign In User
  Future<UserModel> signInUser(
      {required String email, required String password}) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user == null) {
        throw "User not found";
      }

      final userData = await getUser(userCredential.user!.uid);
      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // Sign Out User
  Future<void> signOutUser() async {
    try {
      await auth.signOut();
    } catch (e) {
      throw "Failed to sign out user";
    }
  }

  // Save User to Database
  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw "Failed to save user data";
    }
  }

  // Get User from Database
  Future<UserModel> getUser(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw "User not found";
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw "Failed to get user data";
    }
  }
}
