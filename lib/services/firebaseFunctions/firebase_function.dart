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
        .where("PatrolAssignedGuardsId", arrayContains: EmpId)
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
      String empId) async {
    if (empId.isEmpty) {
      return [];
    }

    final querySnapshot = await patrols
        .where("PatrolAssignedGuardsId", arrayContains: empId)
        .where("PatrolCurrentStatus", whereIn: ["pending", "started"])
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
        .where("PatrolCurrentStatus", whereIn: ["pending", "started"])
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
      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      // await generateReport(address, reportName, Empid, BranchId, Data, CompanyId, Status, EmpName)
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
      // final userRef = FirebaseFirestore.instance
      //     .collection('Employees')
      //     .doc(employeeId)
      //     .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      // await userRef.doc("ShiftIn").set({
      //   'type': 'ShiftIn',
      //   'time': currentTime,
      // });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

  Future<void> BreakShiftLog(String employeeId) async {
    try {
      // final userRef = FirebaseFirestore.instance
      //     .collection('Employees')
      //     .doc(employeeId)
      //     .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      // await userRef.doc("ShiftBreak").set({
      //   'type': 'ShiftBreak',
      //   'time': currentTime,
      // });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

  Future<void> ResumeShiftLog(String employeeId) async {
    try {
      // final userRef = FirebaseFirestore.instance
      //     .collection('Employees')
      //     .doc(employeeId)
      //     .collection('Log');

      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      // await userRef.doc("ResumeShift").set({
      //   'type': 'ResumeShift',
      //   'time': currentTime,
      // });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

  Future<void> EndShiftLog(
      String employeeId,
      String Stopwatch,
      String? shiftId,
      String LocationName,
      String BrachId,
      String CompyId,
      String EmpNames) async {
    try {
      if (shiftId == null || shiftId.isEmpty) {
        throw ArgumentError('Invalid shiftId: $shiftId');
      }

      // final userRef = FirebaseFirestore.instance
      //     .collection('Employees')
      //     .doc(employeeId)
      //     .collection('Log');

      // Update the shift status in Firestore
      final updateShiftStatus =
          await shifts.where('ShiftId', isEqualTo: shiftId).get();
      if (updateShiftStatus.docs.isNotEmpty) {
        final documentId = updateShiftStatus.docs.first.id;
        await shifts.doc(documentId).update({
          'ShiftCurrentStatus': 'completed',
        });
      } else {
        throw Exception('Shift with id $shiftId not found.');
      }
      String Title = "Shift Ended";
      String Data = "Shift Ended ";
      await generateReport(LocationName, Title, employeeId, BrachId, Data,
          CompyId, "other", EmpNames);
      // Get the current system time
      DateTime currentTime = DateTime.now();

      // Create a new document in the "Log" subcollection
      // await userRef.doc('ShiftEnd').set({
      //   'type': 'ShiftEnd',
      //   'time': currentTime,
      //   'totalTime': Stopwatch,
      // });

      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
    }
  }

//Start Shift
//Break
//Stop push the timer also change the shiftStatus as done
//get Gaurds for Supervisor Screen
  // String CompanyId = "aSvLtwII6Cjs7uCISBRR"; //sample Company Id
  Future<List<DocumentSnapshot>> getGuardForSupervisor(String CompanyId) async {
    if (CompanyId.isEmpty) {
      return [];
    }

    final querySnapshot = await userInfo
        .where("EmployeeCompanyId", isEqualTo: CompanyId)
        .where("EmployeeRole", isEqualTo: "GUARD")
        .orderBy("EmployeeModifiedAt", descending: false)
        .get();
    // Log all retrieved documents
    return querySnapshot.docs;
  }

  //Patrol is Started
  Future<void> startPatrol(String PatrolId) async {
    try {
      // Get the current system time
      DateTime currentTime = DateTime.now();
      String data = "Patroll Started";
      //Modify the PatrolModifiedAt
      final patrolRef = FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: PatrolId);

      final querySnapshot = await patrolRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Patrols')
            .doc(documentId)
            .update({
          'PatrolModifiedAt': Timestamp.now(),
          'PatrolCurrentStatus': "started"
        });
      }
      // PatrolModifiedAt
      print('Patrol start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
      // Handle the error as needed
    }
  }

  Future<void> UpdatePatrol(String PatrolId) async {
    try {
      // Get the current system time
      DateTime currentTime = DateTime.now();
      String data = "Patroll Started";
      //Modify the PatrolModifiedAt
      final patrolRef = FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: PatrolId);

      final querySnapshot = await patrolRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Patrols')
            .doc(documentId)
            .update({
          'PatrolModifiedAt': Timestamp.now(),
          'PatrolCurrentStatus': "started"
        });
      }
      // PatrolModifiedAt
      print('Patrol start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
      // Handle the error as needed
    }
  }

  Future<void> updatePatrolsCounter(String empId, String patrolId) async {
    if (empId.isEmpty || patrolId.isEmpty) {
      print("Error in UpdatePatrolCounter");
      return;
    }

    final querySnapshot = await patrols
        .where("PatrolAssignedGuardsId", arrayContains: empId)
        .where("PatrolCurrentStatus", isEqualTo: "started")
        .where("PatrolId", isEqualTo: patrolId)
        .orderBy("PatrolTime", descending: false)
        .get();

    print("Retrieved documents Update Docs:");
    print(querySnapshot.docs); // Log all retrieved documents

    for (var doc in querySnapshot.docs) {
      var checkpoints = doc.get('PatrolCheckPoints');
      for (var checkpoint in checkpoints) {
        // Set all other CheckPointStatus to "not_checked"
        checkpoint['CheckPointStatus'] = 'not_checked';
      }

      // Increment PatrolCompletedCount by 1
      int completedCount = doc.get('PatrolCompletedCount') + 1;

      // Update the document in Firestore
      await doc.reference.update({
        'PatrolCheckPoints': checkpoints,
        'PatrolCompletedCount': completedCount,
      });
    }
  }
//completed

  Future<void> EndPatrol(
      String patrolAssignedGuardId,
      String PatrolCompanyId,
      String PatrolName,
      String PatrolArea,
      String BId,
      String PatrolId,
      String EmpName) async {
    try {
      // Get the current system time
      DateTime currentTime = DateTime.now();
      String data = "Patrolling Ended";
      //Modify the PatrolModifiedAt
      final patrolRef = FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: PatrolId);

      final querySnapshot = await patrolRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Patrols')
            .doc(documentId)
            .update({
          'PatrolModifiedAt': Timestamp.now(),
          'PatrolCurrentStatus': "completed"
        });
      }
      String status = "completed";
      // Create a new document in the "Log" subcollection
      await generateReport(PatrolArea, data, patrolAssignedGuardId,
          PatrolCompanyId, data, PatrolCompanyId, status, EmpName);
      // PatrolModifiedAt
      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
      // Handle the error as needed
    }
  }

//Ks8HiOimtf2vfjdIIutG
//aSvLtwII6Cjs7uCISBRR
  Future<void> generateReport(
      String address,
      String reportName,
      String Empid,
      String BranchId,
      String Data,
      String CompanyId,
      String Status,
      String EmpName) async {
    final ReportRef = FirebaseFirestore.instance.collection("Reports");
    String combinationName = (reportName + address).replaceAll(' ', '');
// Limit the length
    int maxLength = 10;
    if (combinationName.length > maxLength) {
      combinationName = combinationName.substring(0, maxLength);
    }
    final newDocRef = await ReportRef.add({
      "ReportCompanyId": CompanyId,
      "ReportCompanyBranchId": BranchId,
      "ReportName":
          combinationName, //* combination of location and reports name
      "ReportCategory": "other",
      "ReportData": Data,
      "ReportStatus": Status,
      "ReportEmployeeName": EmpName,
      "ReportEmployeeId": Empid,
      "ReportCreatedAt": Timestamp.now(),
    });
    await newDocRef.update({"ReportId": newDocRef.id});
  }

  //Patrol is Completed
  Future<void> ScheduleShift(
    List guards,
    String Address,
    String CompanyBranchId,
    String CompanyId,
    String Date,
    String Time,
    String LocationCordinated,
    String LocationName,
  ) async {
    try {
      // Get the current system time
      DateTime currentTime = DateTime.now();
      String CreatedAt;
      String CurrentStatus = "pending";
      //TimeStamp
      // String Position;
      //Modify the PatrolModified At
      final shiftRef = shifts.doc().set({});

      String status = "completed";
      // Create a new document in the "Log" subcollection
      // PatrolModifiedAt
      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
      // Handle the error as needed
    }
  }
  //Get all the Schedules

  Future<List<DocumentSnapshot>> getAllSchedules(String empId) async {
    if (empId.isEmpty) {
      return [];
    }

    final querySnapshot = await shifts
        .where("ShiftCompanyId", arrayContains: empId)
        // .where("PatrolCurrentStatus", whereIn: ["pending", "started"])
        .orderBy("ShiftModifiedAt", descending: false)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    return querySnapshot.docs;
  }
}

// Schedule and assign
