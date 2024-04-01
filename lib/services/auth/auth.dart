import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/riverpod/auth_provider.dart';

class CustomUser {
  final String email;

  CustomUser({required this.email});
}

final LocalStorage storage = LocalStorage('UserCred.json');

class Auth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection('Employees')
          .where('EmployeeEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // User found, verify password
        DocumentSnapshot<Map<String, dynamic>> userDoc = query.docs.first;
        String storedPassword = userDoc['EmployeePassword'];
        String EmployeID = userDoc['EmployeeId'];
        String role = userDoc['EmployeeRole'];
        // Verify password
        if (storedPassword == password) {
          // Passwords match, set the current user
          storage.setItem("CurrentUser", email);
          storage.setItem("CurrentEmployeeId", EmployeID);
          storage.setItem("Role", role);
          await FirebaseAuth.instance.authStateChanges();
        } else {
          // Password incorrect
          throw 'Password incorrect';
        }
      } else {
        // User not found
        throw 'User not found';
      }
    } catch (e) {
      print('Error signing in: $e');
      throw e; // Rethrow the error for external handling if needed
    }
  }

  //Add the userCred to the employee collection
  Future<void> signOut(context, screen) async {
    await _firebaseAuth.signOut();
    storage.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => (screen)));
  }
}
