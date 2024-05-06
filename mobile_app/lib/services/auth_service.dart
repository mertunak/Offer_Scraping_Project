import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/product/navigation/navigation_constants.dart';
import 'package:mobile_app/services/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Named constructor, only accessible within this class
  AuthService._internal();

  // Factory constructor to return the instance
  factory AuthService() {
    return _instance;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await SharedManager.setIsFirstTime(false);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getFirebaseUser() async {
    return _auth.currentUser;
  }

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await SharedManager.setIsFirstTime(true);
    // ignore: use_build_context_synchronously
    await Navigator.of(context).pushNamed(NavigationConstants.LOGIN_VIEW);
  }
}

final AuthService authService = AuthService();
