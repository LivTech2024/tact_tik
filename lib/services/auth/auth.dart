import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/screens/client%20screens/client_home_screen.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';

class CustomUser {
  final String email;

  CustomUser({required this.email});
}

// final LocalStorage storage = LocalStorage('currentUserEmail');

class Auth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get CurrentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  //fetch all the patrol ids assigned to him using
  final LocalStorage storage;

  Auth() : storage = LocalStorage('currentUserEmail');

  bool isUserLoggedIn() {
    if (_firebaseAuth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  // SignIn
  Future<void> getRole(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
          // storage.setItem("CurrentUser", email);
          // storage.setItem("CurrentEmployeeId", EmployeID);
          // storage.setItem("Role", role);
          prefs.setString("CurrentUser", email);
          prefs.setString("CurrentEmployeeId", EmployeID);
          prefs.setString("Role", role);

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

  // Future<void> signInWithEmailAndPassword(
  //     String email, String password, context) async {
  //   try {
  //     var data = await _firebaseAuth.signInWithEmailAndPassword(
  //         email: email, password: password);
  //     var idtoken;
  //     var claims;
  //     var loginType;
  //     print(data);

  //     var user = data.user;
  //     if (user != null) {
  //       idtoken = await user.getIdTokenResult();
  //       print("IdToken: $idtoken");
  //       claims = idtoken.claims;
  //       loginType = claims['role'];
  //       print("claims: ${claims['role']}");
  //     }
  //     await storage.ready;
  //     if (loginType == 'client') {
  //       await storage.setItem("CurrentUser", email);
  //       // await storage.setItem("CurrentEmployeeId", );
  //       await storage.setItem("Role", 'CLIENT');
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (context) => ClientHomeScreen()));
  //       await storage.setItem("CurrentUser", email);
  //       await storage.setItem("Role", "CLIENT");
  //     } else {
  //       QuerySnapshot<Map<String, dynamic>> query = await _firestore
  //           .collection('Employees')
  //           .where('EmployeeEmail', isEqualTo: email)
  //           .limit(1)
  //           .get();

  //       if (query.docs.isNotEmpty) {
  //         // User found
  //         DocumentSnapshot<Map<String, dynamic>> userDoc = query.docs.first;
  //         String storedPassword = userDoc['EmployeePassword'] ?? "";
  //         String employeeID = userDoc['EmployeeId'] ?? "";
  //         String role = userDoc['EmployeeRole'] ?? "";
  //         // Verify password
  //         if (storedPassword == password) {
  //           // Passwords match, set the current user
  //           await storage.setItem("CurrentUser", email);
  //           await storage.setItem("CurrentEmployeeId", employeeID);
  //           await storage.setItem("Role", role);
  //           // await _firestore.collection('Employees').doc(employeeID).set({
  //           //   'EmployeeIsAvailable': 'available',
  //           // }, SetOptions(merge: true));

  //           // Check role here and navigate accordingly
  //           print('Role $role');
  //           if (role == "SUPERVISOR") {
  //             Navigator.pushReplacement(context,
  //                 MaterialPageRoute(builder: (context) => SHomeScreen()));
  //           } else {
  //             Navigator.pushReplacement(context,
  //                 MaterialPageRoute(builder: (context) => HomeScreen()));
  //           }
  //         } else {
  //           // Password incorrect
  //           throw 'wrong-password';
  //         }
  //       } else {
  //         // User not found
  //         throw 'user-not-found';
  //       }
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //     } else if (e.code ==
  //         "The supplied auth credential is incorrect, malformed or has expired.") {}
  //   } catch (e) {
  //     print('Error signing in firestore: $e');
  //   }
  // }
  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      // Attempt to sign in with the provided email and password
      var data = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      print("User data: $data");

      var user = data.user;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'user-not-found', message: 'No user found for that email.');
      }

      var idTokenResult = await user.getIdTokenResult();
      print("IdTokenResult: $idTokenResult");

      var claims = idTokenResult.claims;
      if (claims == null || !claims.containsKey('role')) {
        throw Exception('No role found in token claims');
      }

      var loginType = claims['role'];
      print("Login type: $loginType");

      await storage.ready;

      if (loginType == 'client') {
        await storage.setItem("CurrentUser", email);
        await storage.setItem("Role", 'CLIENT');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ClientHomeScreen()));
      } else {
        // Fetch employee details from Firestore
        QuerySnapshot<Map<String, dynamic>> query = await _firestore
            .collection('Employees')
            .where('EmployeeEmail', isEqualTo: email)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw FirebaseAuthException(
              code: 'user-not-found', message: 'No user found for that email.');
        }

        DocumentSnapshot<Map<String, dynamic>> userDoc = query.docs.first;
        Map<String, dynamic>? userData = userDoc.data();
        print("User data from Firestore: $userData");

        if (userData == null) {
          throw Exception('User data is null');
        }

        // Extract employee details from user data
        String storedPassword = userData['EmployeePassword'] ?? "";
        String employeeID = userData['EmployeeId'] ?? "";
        String role = userData['EmployeeRole'] ?? "";

        if (storedPassword.isEmpty) {
          throw Exception('Stored password is empty');
        }

        if (employeeID.isEmpty) {
          throw Exception('Employee ID is empty');
        }

        if (role.isEmpty) {
          throw Exception('Role is empty');
        }

        // Verify the password
        if (storedPassword != password) {
          throw FirebaseAuthException(
              code: 'wrong-password',
              message: 'Wrong password provided for that user.');
        }

        // Store user details in local storage
        await storage.setItem("CurrentUser", email);
        await storage.setItem("CurrentEmployeeId", employeeID);
        await storage.setItem("Role", role);

        print('Role: $role');
        if (role == "SUPERVISOR") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SHomeScreen()));
        } else if (role == "GUARD") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      // Handle specific FirebaseAuthException errors
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print('Error signing in: $e');
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
