import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/login_screen.dart';
import 'package:tact_tik/riverpod/auth_provider.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';

class CustomUser {
  final String email;

  CustomUser({required this.email});
}

final LocalStorage storage = LocalStorage('currentUserEmail');

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

  // SignIn
  Future<void> getRole(String email, String password) async {
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
          await _firestore.collection('Employees').doc(EmployeID).set({
            'EmployeeIsAvailable': 'available',
          }, SetOptions(merge: true));
          try {} catch (e) {
            print(e);
          }
        } else {
          // Password incorrect
          throw 'wrong-password';
        }
      } else {
        // User not found
        throw 'user-not-found';
      }
    } catch (e) {
      print('Error signing in: $e');
      throw e; // Rethrow the error for external handling if needed
    }
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, context) async {
    try {
      var data = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      print(data);

      final LocalStorage storage = LocalStorage('currentUserEmail');
      await storage.ready;

      QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection('Employees')
          .where('EmployeeEmail', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // User found
        DocumentSnapshot<Map<String, dynamic>> userDoc = query.docs.first;
        String storedPassword = userDoc['EmployeePassword'] ?? "";
        String employeeID = userDoc['EmployeeId'] ?? "";
        String role = userDoc['EmployeeRole'] ?? "";
        // Verify password
        if (storedPassword == password) {
          // Passwords match, set the current user
          await storage.setItem("CurrentUser", email);
          await storage.setItem("CurrentEmployeeId", employeeID);
          await storage.setItem("Role", role);
          // await _firestore.collection('Employees').doc(employeeID).set({
          //   'EmployeeIsAvailable': 'available',
          // }, SetOptions(merge: true));

          // Check role here and navigate accordingly
          print('Role $role');
          if (role == "SUPERVISOR") {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SHomeScreen()));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        } else {
          // Password incorrect
          throw 'wrong-password';
        }
      } else {
        // User not found
        throw 'user-not-found';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else if (e.code ==
          "The supplied auth credential is incorrect, malformed or has expired.") {}
    } catch (e) {
      print('Error signing in firestore: $e');
    }
  }

  //Add the userCred to the employee collection
  Future<void> signOut(context, screen, String EmployeId) async {
    await _firebaseAuth.signOut();
    // await _firestore.collection('Employees').doc(EmployeId).set({
    //   'EmployeeIsAvailable': 'out_of_reach',
    // }, SetOptions(merge: true));
    //change EmployeeIsAvailable
    storage.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => (screen)));
  }
}
