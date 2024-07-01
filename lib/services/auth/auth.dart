import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/screens/client%20screens/client_home_screen.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
// import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

class CustomUser {
  final String email;

  CustomUser({required this.email});
}

// final LocalStorage storage = LocalStorage('currentUserEmail');

class Auth {
  // FireStoreService fireStoreService = FireStoreService();

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
  // Future<void> addToLoggedInUsers(
  //     String empId, bool isloggedin, String usertype, String FcmToken) async {
  //   try {
  //     _firestore.addLoggedInUser(
  //         loggedInUserId: empId,
  //         isLoggedIn: isloggedin,
  //         loggedInUserType: usertype,
  //         loggedInCreatedAt: Timestamp.now(),
  //         loggedInNotifyFcmToken: "",
  //         loggedInPlatform: "android");
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  //adding to loggedInUsers
  Future<void> addLoggedInUser({
    required String loggedInUserId,
    required bool isLoggedIn,
    required String loggedInUserType,
    required Timestamp loggedInCreatedAt,
    required String loggedInNotifyFcmToken,
    required String loggedInPlatform,
  }) async {
    try {
      CollectionReference loggedInCollection =
          FirebaseFirestore.instance.collection('LoggedInUsers');

      // Check if document with loggedInUserId exists
      QuerySnapshot querySnapshot = await loggedInCollection
          .where('LoggedInUserId', isEqualTo: loggedInUserId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document exists, update the IsLoggedIn field
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'IsLoggedIn': isLoggedIn,
        });
        print('User status updated successfully');
      } else {
        // Document does not exist, create a new one
        DocumentReference docRef = await loggedInCollection.add({
          'LoggedInUserId': loggedInUserId,
          'IsLoggedIn': isLoggedIn,
          'LoggedInUserType': loggedInUserType,
          'LoggedInCreatedAt': FieldValue.serverTimestamp(),
          'LoggedInNotifyFcmToken': loggedInNotifyFcmToken,
          'LoggedInPlatform': loggedInPlatform,
        });

        // Use the document ID as LoggedInId
        String loggedInId = docRef.id;
        await docRef.update({'LoggedInId': loggedInId});

        print('Data added successfully with LoggedInId: $loggedInId');
      }
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  //
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
        QuerySnapshot<Map<String, dynamic>> query = await _firestore
            .collection('Clients')
            .where('ClientEmail', isEqualTo: email)
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
        String employeeID = userData['ClientId'] ?? "";
        await storage.setItem("CurrentUser", email);
        await storage.setItem("Role", 'CLIENT');

        await addLoggedInUser(
            loggedInUserId: employeeID,
            isLoggedIn: true,
            loggedInUserType: 'client',
            loggedInCreatedAt: Timestamp.now(),
            loggedInNotifyFcmToken: '',
            loggedInPlatform: Platform.operatingSystem);
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
          await addLoggedInUser(
              loggedInUserId: employeeID,
              isLoggedIn: true,
              loggedInUserType: 'employee',
              loggedInCreatedAt: Timestamp.now(),
              loggedInNotifyFcmToken: '',
              loggedInPlatform: Platform.operatingSystem);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SHomeScreen()));
        } else
        //  if (role == "GUARD")
        {
          await addLoggedInUser(
              loggedInUserId: employeeID,
              isLoggedIn: true,
              loggedInUserType: 'employee',
              loggedInCreatedAt: Timestamp.now(),
              loggedInNotifyFcmToken: '',
              loggedInPlatform: Platform.operatingSystem);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } catch (e) {
      print('FirebaseAuthException Firestore: ${e}');
      showErrorToast(context, "Invalid Credentials");
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => (screen)),
      (Route<dynamic> route) =>
          route.isFirst, // Remove all routes until the first one
    );
  }
}
