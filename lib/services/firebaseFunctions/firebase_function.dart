import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tact_tik/services/auth/auth.dart';

class FireStoreService {
  final Auth auth = Auth();

  //Read LoggedIN User Information
  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection("Employees");

  Future<DocumentSnapshot?> getUserInfoByCurrentUserEmail() async {
    User? currentUser = auth.CurrentUser;
    if (currentUser == null) {
      return null;
    }

    final currentUserEmail = currentUser.email;
    if (currentUserEmail == null) {
      return null;
    }

    final querySnapshot = await userInfo
        .where("EmployeeEmail", isEqualTo: currentUserEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document found
      print(querySnapshot.docs.first);
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }
}
