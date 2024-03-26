import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tact_tik/services/auth/auth.dart';

class FireStoreService {
  final Auth auth = Auth();

  //Read LoggedIN User Information
  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection("Employees");
  final CollectionReference shifts =
      FirebaseFirestore.instance.collection("Shifts");
  //Get userinfo based on the useremailid
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

  //get the assigned shifts
  //Check the
  Future<DocumentSnapshot?> getShiftByEmployeeIdFromUserInfo() async {
    DocumentSnapshot? userInfoDoc = await getUserInfoByCurrentUserEmail();
    if (userInfoDoc == null) {
      return null;
    }

    final EmployeeId = userInfoDoc["EmployeeId"];
    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", isEqualTo: EmployeeId)
        .orderBy("ShiftDate",
            descending:
                false) // Order by date ascending also check if the shift status
        .limit(1) // Limit to only one document
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document found
      print(querySnapshot.docs.first);
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

//Update the User Shift Status
  Future<void> startShiftLog() async {
    DocumentSnapshot? userInfoDoc = await getUserInfoByCurrentUserEmail();
    if (userInfoDoc == null) {
      return;
    }

    final userRef = FirebaseFirestore.instance
        .collection('Employees')
        .doc(userInfoDoc.id)
        .collection('Log');

    // Get the current system time
    DateTime currentTime = DateTime.now();

    // Create a new document in the "Log" subcollection
    await userRef.add({
      'type': 'ShiftStart',
      'time': currentTime,
    });

    print('Shift start logged at $currentTime');
  }
//Start Shift
//Break
//Stop push the timer also change the shiftStatus as done
}
