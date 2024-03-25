import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get CurrentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool isUserLoggedIn() {
    if (_firebaseAuth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  //SignIn
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return null;
    } catch (e) {
      print(e);
    }
  }

  //SignUp
  Future<void> signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e == 'email-already-in-use') {
        print('Email already in use.');
      } else {
        print('Error: $e');
      }
    }
  }

  //Add the userCred to the employee collection
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
