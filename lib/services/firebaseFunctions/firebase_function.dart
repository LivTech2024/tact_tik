import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/services/auth/auth.dart';

class FireStoreService {
  final Auth auth = Auth();
  final LocalStorage storage = LocalStorage('currentUserEmail');

  //Read LoggedIN User Information
  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection("Employees");
  final CollectionReference shifts =
      FirebaseFirestore.instance.collection("Shifts");
  final CollectionReference patrols =
      FirebaseFirestore.instance.collection("Patrols");
  //Get userinfo based on the useremailid
  Future<DocumentSnapshot?> getUserInfoByCurrentUserEmail() async {
    String? currentUser = storage.getItem("CurrentUser");

    if (currentUser == null || currentUser.isEmpty) {
      return null;
    }

    final currentUserEmail = currentUser;
    if (currentUserEmail.isEmpty) {
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
  Future<DocumentSnapshot?> getShiftByEmployeeIdFromUserInfo(
      String EmpId) async {
    if (EmpId.isEmpty) {
      return null;
    }

    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", isEqualTo: EmpId)
        .where("ShiftCurrentStatus",
            isEqualTo: "pending") // Filter by pending status
        .orderBy("ShiftDate", descending: false)
        .limit(1)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document with pending status
      print(querySnapshot.docs.first);
      return querySnapshot.docs.first;
    } else {
      print("No pending shift found for EmployeeId: $EmpId");
      return null;
    }
  }

  Future<DocumentSnapshot?> getPatrolsByEmployeeIdFromUserInfo(
      String EmpId) async {
    if (EmpId.isEmpty) {
      return null;
    }

    final querySnapshot = await patrols
        .where("PatrolAssignedGuardId", isEqualTo: EmpId)
        .where("PatrolCurrentStatus",
            isEqualTo: "pending") // Filter by pending status
        .orderBy("PatrolTime", descending: false)
        .limit(1)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document with pending status
      print(querySnapshot.docs.first);
      return querySnapshot.docs.first;
    } else {
      print("No pending shift found for EmployeeId: $EmpId");
      return null;
    }
  }

  Future<List<DocumentSnapshot>> getAllPatrolsByEmployeeIdFromUserInfo(
      String EmpId) async {
    if (EmpId.isEmpty) {
      return [];
    }

    final querySnapshot = await patrols
        .where("PatrolAssignedGuardId", isEqualTo: EmpId)
        .where("PatrolCurrentStatus", isEqualTo: "pending")
        .orderBy("PatrolTime", descending: false)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    return querySnapshot.docs;
  }

  Stream<QuerySnapshot> getPatrols(String EmpId) {
    final patrolStream = patrols
        .where("PatrolAssignedGuardId", isEqualTo: EmpId)
        .where("PatrolCurrentStatus", isEqualTo: "pending")
        .orderBy("PatrolTime", descending: false)
        .snapshots();
    return patrolStream;
  }

  Future<void> updatePatrolsStatus(
      String EmpId, String PatrolId, String CheckPointId) async {
    if (EmpId.isEmpty || PatrolId.isEmpty || CheckPointId.isEmpty) {
      return;
    }

    final querySnapshot = await patrols
        .where("PatrolAssignedGuardId", isEqualTo: EmpId)
        .where("PatrolCurrentStatus", isEqualTo: "pending")
        .orderBy("PatrolTime", descending: false)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    for (var doc in querySnapshot.docs) {
      var checkpoints = doc.get('PatrolCheckPoints');
      for (var checkpoint in checkpoints) {
        if (checkpoint['CheckPointId'] == CheckPointId) {
          // Update the CheckPointStatus to "checked"
          checkpoint['CheckPointStatus'] = 'checked';
          checkpoint['CheckPointCheckedTime'] =
              Timestamp.now(); //Update the timestamp
        }
      }

      // Update the document in Firestore
      await doc.reference.update({'PatrolCheckPoints': checkpoints});
    }
  }

  Future<void> updatePatrolsReport(
      String EmpId, String PatrolId, String CheckPointId) async {
    if (EmpId.isEmpty || PatrolId.isEmpty || CheckPointId.isEmpty) {
      return;
    }

    final querySnapshot = await patrols
        .where("PatrolAssignedGuardId", isEqualTo: EmpId)
        .where("PatrolCurrentStatus", isEqualTo: "pending")
        .orderBy("PatrolTime", descending: false)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    for (var doc in querySnapshot.docs) {
      var checkpoints = doc.get('PatrolCheckPoints');
      for (var checkpoint in checkpoints) {
        if (checkpoint['CheckPointId'] == CheckPointId) {
          // Update the CheckPointStatus to "checked"
          checkpoint['CheckPointFailureReason'] = 'Qr-code missing';
          // checkpoint['CheckPointCheckedTime'] =
          //     Timestamp.now(); //Update the timestamp
        }
      }

      // Update the document in Firestore
      await doc.reference.update({'PatrolCheckPoints': checkpoints});
    }
  }

//Update the User Shift Status
  Future<void> startShiftLog(String employeeId, String shiftId) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('Employees')
          .doc(employeeId)
          .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      await userRef.doc("ShiftStart").set({
        'type': 'ShiftStart',
        'time': currentTime,
      });
      final updateShiftStatus =
          await shifts.where('ShiftId', isEqualTo: shiftId).get();
      if (updateShiftStatus.docs.isNotEmpty) {
        final documentId = updateShiftStatus.docs.first.id;
        await shifts.doc(documentId).update(
            {'ShiftAcknowledged': true, 'ShiftCurrentStatus': "started"});
      } else {
        throw Exception('Shift with id $shiftId not found.');
      }
      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
      // Handle the error as needed
    }
  }

  Future<void> INShiftLog(String employeeId) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('Employees')
          .doc(employeeId)
          .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      await userRef.doc("ShiftIn").set({
        'type': 'ShiftIn',
        'time': currentTime,
      });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

  Future<void> BreakShiftLog(String employeeId) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('Employees')
          .doc(employeeId)
          .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      await userRef.doc("ShiftBreak").set({
        'type': 'ShiftBreak',
        'time': currentTime,
      });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

  Future<void> ResumeShiftLog(String employeeId) async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('Employees')
          .doc(employeeId)
          .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      await userRef.doc("ResumeShift").set({
        'type': 'ResumeShift',
        'time': currentTime,
      });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

  Future<void> EndShiftLog(
      String employeeId, String Stopwatch, String? shiftId) async {
    try {
      if (shiftId == null || shiftId.isEmpty) {
        throw ArgumentError('Invalid shiftId: $shiftId');
      }

      final userRef = FirebaseFirestore.instance
          .collection('Employees')
          .doc(employeeId)
          .collection('Log');

      // Update the shift status in Firestore
      final updateShiftStatus =
          await shifts.where('ShiftId', isEqualTo: shiftId).get();
      if (updateShiftStatus.docs.isNotEmpty) {
        final documentId = updateShiftStatus.docs.first.id;
        await shifts.doc(documentId).update({
          'ShiftCurrentStatus': 'done',
        });
      } else {
        throw Exception('Shift with id $shiftId not found.');
      }

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      await userRef.doc('ShiftEnd').set({
        'type': 'ShiftEnd',
        'time': currentTime,
        'totalTime': Stopwatch,
      });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

//Start Shift
//Break
//Stop push the timer also change the shiftStatus as done
//get Gaurds for Supervisor Screen
  String CompanyId = "aSvLtwII6Cjs7uCISBRR"; //sample Company Id
  Future<List<DocumentSnapshot>> getGuardForSupervisor(String CompanyId) async {
    if (CompanyId.isEmpty) {
      return [];
    }

    final querySnapshot = await userInfo
        .where("EmployeeCompanyId", isEqualTo: CompanyId)
        .orderBy("EmployeeModifiedAt", descending: false)
        .get();
    // Log all retrieved documents
    return querySnapshot.docs;
  }
}
