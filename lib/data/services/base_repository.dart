import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseRepository {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;
  String get uid => currentUser?.uid ?? "";
  bool get isUserAuthenticated => currentUser != null;
}
