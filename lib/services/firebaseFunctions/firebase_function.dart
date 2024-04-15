import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/services/auth/auth.dart';

class FireStoreService {
  final Auth auth = Auth();
  final LocalStorage storage = LocalStorage('currentUserEmail');
  // FirebaseStorage firebaseStorage = FirebaseStorage.instance.ref();
  //Read LoggedIN User Information
  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection("Employees");
  final CollectionReference shifts =
      FirebaseFirestore.instance.collection("Shifts");
  final CollectionReference patrols =
      FirebaseFirestore.instance.collection("Patrols");
  final CollectionReference setting =
      FirebaseFirestore.instance.collection("Settings");
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

  Future<DocumentSnapshot?> getShiftByEmployeeIdFromUserInfo(
      String empId) async {
    if (empId.isEmpty) {
      return null;
    }

    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", arrayContains: empId)
        .orderBy("ShiftDate", descending: false)
        .get();

    print("Retrieved documents Shift for EmployeeId: $empId:");
    print(querySnapshot.docs); // Log all retrieved documents

    for (var doc in querySnapshot.docs) {
      final shiftData = doc.data() as Map<String, dynamic>;
      final shiftTasks = shiftData['ShiftCurrentStatus'] ?? [];

      if (shiftTasks.isEmpty) {
        print("ShiftCurrentStatus is empty for Document ID: ${doc.id}");
        return doc;
      }

      final statusDoc = shiftTasks.any((status) =>
          status['StatusReportedById'] == empId &&
          status['Status'] == 'pending');

      if (statusDoc) {
        print(
            "Found shift with status pending for EmployeeId: $empId in Document ID: ${doc.id}");
        return doc;
      }
    }

    print("No shift found for EmployeeId: $empId");
    return null;
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

  Future<List<DocumentSnapshot>> getAllPatrolsByShiftId(String shiftId) async {
    if (shiftId.isEmpty) {
      return [];
    }
    print("Shift Id");
    // Fetch the Shift document
    final shiftDoc = await shifts.doc(shiftId).get();
    if (!shiftDoc.exists) {
      print("Shift doc in Patrol is null");
      return [];
    }

    // Cast the result of shiftDoc.data() to a Map<String, dynamic>
    final shiftData = shiftDoc.data() as Map<String, dynamic>?;
    if (shiftData == null) {
      print("Shift data is null");
      return [];
    }

    // Print the shiftData for debugging
    print("Shift Data:");
    print(shiftData);
    // Extract the ShiftLinkedPatrolIds array from the Shift document
    final shiftLinkedPatrolIds =
        List<String>.from(shiftData["ShiftLinkedPatrolIds"] ?? []);

    print("Patrol Linked IDS fetched: ${shiftLinkedPatrolIds}");
    // Fetch the Patrols using the ShiftLinkedPatrolIds
    final querySnapshot =
        await patrols.where("PatrolId", whereIn: shiftLinkedPatrolIds).get();

    print("Retrieved documents Patrols:");
    print(
        "Get Patrol Info ${querySnapshot.docs}"); // Log all retrieved documents
    querySnapshot.docs.forEach((doc) {
      print("Patrols Fetched");
      print(doc.data());
    });
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
      String patrolId, String checkPointId, String Empid) async {
    if (patrolId.isEmpty || checkPointId.isEmpty) {
      print('Patrol ID is empthy');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: patrolId)
          // .where("PatrolCurrentStatus",
          //     whereIn: ["pending", "started", []])
          .get();

      print("Retrieved documents:");
      print(querySnapshot.docs); // Log all retrieved documents

      for (var doc in querySnapshot.docs) {
        var checkpoints = List.from(doc.get('PatrolCheckPoints'));

        // Find the checkpoint to update
        var checkpointToUpdate = checkpoints.firstWhere(
          (checkpoint) => checkpoint['CheckPointId'] == checkPointId,
          orElse: () => null,
        );

        if (checkpointToUpdate != null) {
          // Update the CheckPointStatus to "checked"
          checkpointToUpdate['CheckPointStatus'] = [
            {
              'Status': 'checked',
              'StatusReportedTime': Timestamp.now(),
              'StatusReportedById': Empid,
            }
          ];

          // Update the document in Firestore
          await doc.reference.update({'PatrolCheckPoints': checkpoints});
        }
        print("Updated Patrol Status");
      }
    } catch (e) {
      print("Error updating patrols status: $e");
      // Handle the error as needed
    }
  }

  Future<void> updatePatrolCurrentStatus(
    String docId,
    String status,
    String? statusReportedById,
    String? statusReportedByName,
  ) async {
    try {
      // Get a reference to the Firestore document
      DocumentReference<Map<String, dynamic>> patrolDocument =
          FirebaseFirestore.instance.collection('Patrols').doc(docId);

      // Fetch the current document data
      var documentSnapshot = await patrolDocument.get();
      var data = documentSnapshot.data();

      // Check if the status entry already exists
      List<Map<String, dynamic>> currentStatusList =
          List<Map<String, dynamic>>.from(data?['PatrolCurrentStatus'] ?? []);
      int existingIndex = currentStatusList.indexWhere(
          (entry) => entry['StatusReportedById'] == statusReportedById);

      if (existingIndex != -1) {
        // If the status entry exists, update it
        currentStatusList[existingIndex]['Status'] = status;
        currentStatusList[existingIndex]['StatusReportedByName'] =
            statusReportedByName;
        currentStatusList[existingIndex]['StatusReportedTime'] =
            Timestamp.now();
        // Optionally, increment the count
        // currentStatusList[existingIndex]['StatusCompletedCount'] =
        //     (currentStatusList[existingIndex]['StatusCompletedCount'] ?? 0) + 1;
      } else {
        // If the status entry doesn't exist, add a new entry
        currentStatusList.add({
          'Status': status,
          'StatusReportedById': statusReportedById,
          'StatusReportedByName': statusReportedByName,
          // 'StatusCompletedCount': 1, // Start count from 1 for new entry
          'StatusReportedTime': Timestamp.now(),
        });
      }

      // Update the document with the updated status array
      await patrolDocument.update({
        'PatrolCurrentStatus': currentStatusList,
      });

      print('Document updated successfully');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> EndPatrolupdatePatrolsStatus(String patrolId,
      String statusReportedById, String statusReportedByName) async {
    if (patrolId.isEmpty) {
      return;
    }
    DocumentReference<Map<String, dynamic>> patrolDocument =
        FirebaseFirestore.instance.collection('Patrols').doc(patrolId);

    // Fetch the current document data
    var documentSnapshot = await patrolDocument.get();
    var data = documentSnapshot.data();

    // Update the status entry for the given statusReportedById

    // Update checkpoint statuses to "not_checked"
    List<dynamic> checkpoints = List.from(data?['PatrolCheckPoints'] ?? []);
    checkpoints.forEach((checkpoint) {
      List<dynamic> status = List.from(checkpoint['CheckPointStatus']);
      status.forEach((entry) {
        entry['Status'] = 'not_checked';
        entry['StatusReportedTime'] = Timestamp.now();
      });
    });
    List<Map<String, dynamic>> currentStatusList =
        List<Map<String, dynamic>>.from(data?['PatrolCurrentStatus'] ?? []);
    int existingIndex = currentStatusList.indexWhere(
        (entry) => entry['StatusReportedById'] == statusReportedById);

    if (existingIndex != -1) {
      // If the status entry exists, update it
      currentStatusList[existingIndex]['Status'] = "completed";
      currentStatusList[existingIndex]['StatusReportedByName'] =
          statusReportedByName;
      currentStatusList[existingIndex]['StatusReportedTime'] = Timestamp.now();
      currentStatusList[existingIndex]['StatusCompletedCount'] =
          (currentStatusList[existingIndex]['StatusCompletedCount'] ?? 0) + 1;
    } else {
      // If the status entry doesn't exist, add a new entry
      currentStatusList.add({
        'Status': "completed",
        'StatusReportedById': statusReportedById,
        'StatusReportedByName': statusReportedByName,
        'StatusCompletedCount': 1,
        'StatusReportedTime': Timestamp.now(),
      });
    }
    await patrolDocument.update({
      'PatrolCheckPoints': checkpoints,
      'PatrolCurrentStatus': currentStatusList,
    });
    // Update the PatrolCheckPoints and PatrolCurrentStatus to "completed"

    print("Patrol and checkpoint statuses updated successfully");
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

      // Update the shift status in Firestore
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> currentArray =
          List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);
      final statusData = {
        'Status': 'completed',
        'StatusReportedById': employeeId,
        'StatusReportedByName': EmpNames,
        'StatusReportedTime': DateTime.now().toString(),
      };
      int index = currentArray.indexWhere((element) =>
          element['StatusReportedById'] == employeeId &&
          element['Status'] == 'completed');
      if (index != -1) {
        // If the map already exists in the array, update it
        currentArray[index] = statusData;
      } else {
        // If the map doesn't exist, add it to the array
        currentArray.add(statusData);
      }
      await documentReference.update({'ShiftCurrentStatus': currentArray});

      // Generate report
      String Title = "Shift Ended";
      String Data = "Shift Ended ";
      await generateReport(LocationName, Title, employeeId, BrachId, Data,
          CompyId, "other", EmpNames);

      // Get the current system time
      DateTime currentTime = DateTime.now();
      print('Shift end logged at $currentTime');
    } catch (e) {
      print('Error logging shift end: $e');
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
    String EmpName,
  ) async {
    try {
      print('Ending patrol...');
      // Get the current system time
      DateTime currentTime = DateTime.now();
      String data = "Patrolling Ended";
      // Modify the PatrolModifiedAt
      final patrolRef = FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: PatrolId);
      await generateReport(
        PatrolArea,
        PatrolName,
        patrolAssignedGuardId,
        BId,
        data,
        PatrolCompanyId,
        "completed",
        EmpName,
      );

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
      // PatrolModifiedAt
      print('Shift start logged at $currentTime');
      print('Patrol ended successfully');
    } catch (e) {
      print('Error ending patrol: $e');
      // Handle the error as needed
    }
  }

  Future<void> generateReport(
    String address,
    String reportName,
    String Empid,
    String BranchId,
    String Data,
    String CompanyId,
    String Status,
    String EmpName,
  ) async {
    try {
      print('Generating report...');
      final ReportCategoryRef =
          FirebaseFirestore.instance.collection("ReportCategories");
      final newCategoryDocRef = await ReportCategoryRef.add({
        "ReportCategoryName": "Patrol",
        "ReportCategoryCreatedAt": DateTime.now(),
        // Add other fields if needed
      });
      //report Categories fetch the id according to the
      await newCategoryDocRef
          .update({'ReportCategoryId': newCategoryDocRef.id});
      String ReportCategoryId = newCategoryDocRef.id;
      print('ReportCategoryId: $ReportCategoryId');
      final ReportRef = FirebaseFirestore.instance.collection("Reports");
      String combinationName = (reportName + address).replaceAll(' ', '');
      print('Combination Name: $combinationName');
      // Limit the length
      int maxLength = 10;
      if (combinationName.length > maxLength) {
        combinationName = combinationName.substring(0, maxLength);
      }
      print('Report Name: $combinationName');
      final newDocRef = await ReportRef.add({
        "ReportCompanyId": CompanyId,
        "ReportCompanyBranchId": BranchId,
        "ReportName": combinationName,
        "ReportCategoryName": "Shift",
        "ReportData": Data,
        "ReportStatus": Status,
        "ReportEmployeeName": EmpName,
        "ReportEmployeeId": Empid,
        "ReportCreatedAt": Timestamp.now(),
      });
      print('Report generated successfully');
      await newDocRef.update({"ReportCategoryId": newDocRef.id});
    } catch (e) {
      print('Error generating report: $e');
      // Handle the error as needed
    }
  }

  //Patrol is Completed
  Future<void> ScheduleShift(
    List guards,
    String Address,
    String CompanyBranchId,
    String CompanyId,
    String Date,
    List<TimeOfDay> Time,
    double Latitude,
    double Longitude,
    String LocationName,
  ) async {
    try {
      // Get the current system time
      DateTime currentTime = DateTime.now();
      List<String> convertToStringArray(List list) {
        List<String> stringArray = [];
        for (var element in list) {
          stringArray.add(element.toString());
        }
        return stringArray;
      }

      List<String> guardUserIds = convertToStringArray(guards);
      List<String> selectedGuardIds =
          guards.map((guard) => guard['GuardId'] as String).toList();

      final DateTime date = DateTime.parse(Date);
      final DateFormat timeFormatter = DateFormat('HH:mm');
      final List<String> formattedTimeRanges = Time.map((timeOfDay) =>
          timeFormatter.format(
              DateTime(0, 0, 0, timeOfDay.hour, timeOfDay.minute))).toList();

      final newDocRef = await shifts.add({
        'ShiftName': Address.split(' ')[0],
        'ShiftPosition': 'GUARD',
        'ShiftDate': date,
        'ShiftStartTime': formattedTimeRanges[0],
        'ShiftEndTime': formattedTimeRanges[1],
        'ShiftLocation': GeoPoint(Latitude, Longitude),
        'ShiftLocationName': Address.split(' ')[0],
        'ShiftAddress': Address,
        'ShiftDescription': '',
        'ShiftAssignedUserId': selectedGuardIds,
        'ShiftClientId': '',
        'ShiftCompanyId': CompanyId,
        'ShiftRequiredEmp': selectedGuardIds.length,
        'ShiftCompanyBranchId': CompanyBranchId,
        'ShiftCurrentStatus': 'pending',
        'ShiftCreatedAt': Timestamp.now(),
        'ShiftModifiedAt': Timestamp.now(),
      });
      await newDocRef.update({"ShiftId": newDocRef.id});
      // Log the shift start time
      print('Shift start logged at $currentTime');
    } catch (e) {
      print('Error logging shift start: $e');
      // Handle the error as needed
    }
  }

  //Get all the Schedules for Guards

  Future<List<DocumentSnapshot>> getAllSchedules(String empId) async {
    if (empId.isEmpty) {
      return [];
    }
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);
    DateTime endDate = startDate.add(Duration(days: 7));
    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", arrayContains: empId)
        // .where("PatrolCurrentStatus", whereIn: ["pending", "started"])
        .where("ShiftModifiedAt", isLessThan: endDate)
        .orderBy("ShiftModifiedAt", descending: false)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    return querySnapshot.docs;
  }

  //Get all Schedules of Supervisor
  Future<List<DocumentSnapshot>> getAllSchedulesSupervisor(String empId) async {
    if (empId.isEmpty) {
      return [];
    }
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day);
    DateTime endDate = startDate.add(Duration(days: 7));
    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", arrayContains: empId)
        // .where("PatrolCurrentStatus", whereIn: ["pending", "started"])
        .where("ShiftModifiedAt", isLessThan: endDate)
        .orderBy("ShiftModifiedAt", descending: false)
        .get();

    print("Retrieved documents:");
    print(querySnapshot.docs); // Log all retrieved documents

    return querySnapshot.docs;
  }

  Future<int> wellnessFetch(String companyId) async {
    try {
      FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      User? currentUser = _firebaseAuth.currentUser;
      String companyID = "";
      String EmpId = "";
      if (currentUser != null) {
        print(" Current User: ${currentUser.email}");
        String userEmail = currentUser.email.toString();
        QuerySnapshot companyIdSnapshot =
            await userInfo.where('EmployeeEmail', isEqualTo: userEmail).get();
        if (companyIdSnapshot.docs.isNotEmpty) {
          companyID = companyIdSnapshot.docs.first['EmployeeCompanyId'];
          EmpId = companyIdSnapshot.docs.first['EmployeeId'];
        }
      }
      if (companyID.isEmpty) {
        return 0;
      }
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Settings')
          .where('SettingCompanyId', isEqualTo: companyID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print(
            "Timer : ${querySnapshot.docs.first['SettingEmpWellnessIntervalInMins']}");
        return querySnapshot.docs.first['SettingEmpWellnessIntervalInMins'];
      } else {
        // Handle case where document is not found
        return 0; // or any default value
      }
    } catch (e) {
      print('Error fetching wellness interval: $e');
      // Handle the error as needed
      return 0; // or any default value
    }
  }

  //Add the images to storage and add its link to firestore collection
  Future<List<Map<String, dynamic>>> addImageToStorage(File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      Reference uploadRef =
          storageRef.child("employees/wellness/$uniqueName.jpg");
      // Compress the image
      Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 50, // Adjust the quality as needed
      );

      // Upload the compressed image to Firebase Storage
      await uploadRef.putData(Uint8List.fromList(compressedImage!));

      // Get the download URL of the uploaded image
      String downloadURL = await uploadRef.getDownloadURL();
      print("Download URL: $downloadURL");

      // Return the download URL in a list
      return [
        {'downloadURL': downloadURL}
      ];
    } catch (e) {
      print(e);
      throw e;
    }
  }

  //add wellness to the collection
  Future<void> addImagesToShiftGuardWellnessReport(
      List<Map<String, dynamic>> uploads, String comment) async {
    try {
      // final LocalStorage Userstorage = LocalStorage('currentUserEmail');
      final LocalStorage storage = LocalStorage('ShiftDetails');
      String shiftId = storage.getItem('shiftId');
      String empId = storage.getItem('EmpId') ?? "";
      final querySnapshot =
          await shifts.where("ShiftId", isEqualTo: shiftId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        List<Map<String, dynamic>> wellnessReports =
            List.from(doc["ShiftGuardWellnessReport"]);
        List<Map<String, dynamic>> imgUrls = [];
        for (var upload in uploads) {
          if (upload['type'] == 'image') {
            File file = upload['file'];

            // Upload the image file and get the download URL
            List<Map<String, dynamic>> downloadURL =
                await addImageToStorage(file);
            // Add the wellness report entry to the list
            for (var url in downloadURL) {
              imgUrls.add(url as Map<String, dynamic>);
            }
          }
        }
        wellnessReports.add({
          "WellnessEmployeeID": empId,
          "timestamp": DateTime.now(),
          "comment": comment,
          "imageURL": imgUrls,
        });
        // Update the Firestore document with the new wellness reports
        await doc.reference.update({
          "ShiftGuardWellnessReport": wellnessReports,
        });
      } else {
        print("No document found with shiftId: $shiftId");
      }
    } catch (e) {
      print('Error adding images to ShiftGuardWellnessReport: $e');
      throw e;
    }
  }

  //validate if the shift task are completef
  Future<bool?> checkShiftTaskStatus(String empId, String shiftID) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Shifts")
          .doc(shiftID)
          .get();

      if (documentSnapshot.exists) {
        print('SHift Task exists');
        final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
        if (shiftTasks.isNotEmpty) {
          print("Shift Task is not empty");
          for (var shiftTask in shiftTasks) {
            final taskStatusList =
                shiftTask['ShiftTaskStatus'] as List<dynamic>;
            if (taskStatusList.isNotEmpty) {
              print("ShiftTaskStatus is not empty");
              for (var shiftTaskStatus in taskStatusList) {
                if (shiftTaskStatus['TaskCompletedById'] == empId &&
                    (shiftTaskStatus['TaskStatus'] == "pending" ||
                        shiftTaskStatus['TaskStatus'] == null)) {
                  return false; // If any task matches the condition, return false
                }
              }
            } else {
              return false;
            }
          }
        } else {
          return true; // If ShiftTaskStatus array is empty, return true
        }
      } else {
        return false; // If document doesn't exist, return false
      }
      return true; // If no task matches the condition, return true
    } catch (e) {
      print("Error checking shift task status: $e");
      return null; // Return null in case of error
    }
  }

  //Check Shift Return Task
  Future<bool?> checkShiftReturnTaskStatus(String empId, String shiftID) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Shifts")
          .doc(shiftID)
          .get();

      if (documentSnapshot.exists) {
        final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
        for (var shiftTask in shiftTasks) {
          if (shiftTask['ShiftTaskReturnReq'] == true) {
            final taskStatusList =
                shiftTask['ShiftTaskStatus'] as List<dynamic>;
            for (var shiftTaskStatus in taskStatusList) {
              if (shiftTaskStatus['ShiftTaskReturnStatus'] == false ||
                  shiftTaskStatus['ShiftTaskReturnStatus'] == null) {
                return true; // If ShiftTaskReturnStatus is true, return true
              }
            }
          }
        }
        return false; // If no task has both ShiftTaskReturnReq and ShiftTaskReturnStatus as true, return false
      } else {
        return false; // If document doesn't exist, return false
      }
    } catch (e) {
      print("Error checking shift task status: $e");
      return null; // Return null in case of error
    }
  }

  //Fetch shift task
  Future<List<Map<String, dynamic>>?> fetchShiftTask(String shiftID) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Shifts")
          .doc(shiftID)
          .get();

      if (documentSnapshot.exists) {
        final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
        if (shiftTasks.isNotEmpty) {
          return List<Map<String, dynamic>>.from(shiftTasks);
        }
      }
      return null; // Return null if no tasks or document doesn't exist
    } catch (e) {
      print("Error fetching shift tasks: $e");
      return null; // Return null in case of error
    }
  }

  // fetch return shift tasks
  Future<List<Map<String, dynamic>>?> fetchreturnShiftTasks(
      String shiftID) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Shifts")
          .doc(shiftID)
          .get();

      if (documentSnapshot.exists) {
        print("Document return shift exists");
        final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
        if (shiftTasks.isNotEmpty) {
          final tasks = List<Map<String, dynamic>>.from(shiftTasks)
              .where((task) => task['ShiftTaskReturnReq'] == true)
              .toList();
          print("Document return shift exists");
          print("Tasks ${tasks}");
          return tasks.isNotEmpty ? tasks : null;
        }
      }
      return null; // Return null if no tasks or document doesn't exist
    } catch (e) {
      print("Error fetching shift tasks: $e");
      return null; // Return null in case of error
    }
  }

  Future<Map<String, dynamic>> fetchShiftTasks(String shiftID) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Shifts")
          .doc(shiftID)
          .get();

      if (documentSnapshot.exists) {
        final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
        if (shiftTasks.isNotEmpty) {
          List<Map<String, dynamic>> tasks = List.from(shiftTasks);

          // Extract TaskStatus for each task
          List<Map<String, dynamic>> taskStatusList = [];
          for (var task in tasks) {
            final taskStatus = task['ShiftTaskStatus'] as List<dynamic>;
            taskStatusList.add(taskStatus.isNotEmpty ? taskStatus[0] : {});
          }

          return {
            'tasks': tasks,
            'taskStatusList': taskStatusList,
          };
        }
      }
      return {
        'tasks': [],
        'taskStatusList': [],
      }; // Return empty if no tasks or document doesn't exist
    } catch (e) {
      print("Error fetching shift tasks: $e");
      return {
        'tasks': [],
        'taskStatusList': [],
      }; // Return empty in case of error
    }
  }

  Future<List<Map<String, dynamic>>> addImageToStorageShiftTask(
      File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      Reference uploadRef =
          storageRef.child("employees/shifttask/$uniqueName.jpg");

      Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 50, // Adjust the quality as needed
      );

      // Upload the compressed image to Firebase Storage
      await uploadRef.putData(Uint8List.fromList(compressedImage!));
      // Upload the image file and get the download URL
      // await uploadRef.putFile(file);

      // Get the download URL of the uploaded image
      String downloadURL = await uploadRef.getDownloadURL();

      // Return the download URL in a list
      print({'downloadURL': downloadURL});
      return [
        {'downloadURL': downloadURL}
      ];
    } catch (e) {
      print(e);
      throw e;
    }
  }

  //add wellness to the collection
  Future<void> addImagesToShiftTasks(
      List<Map<String, dynamic>> uploads,
      String ShiftTaskId,
      String ShiftId,
      String EmpId,
      bool shiftTaskReturnStatus) async {
    try {
      print("Uploads from FIrebase: $uploads");
      print("Shift Task ID from FIrebase: $ShiftTaskId");

      if (ShiftId.isEmpty) {
        print("Shift ID from FIrebase: $ShiftId");
      } else {
        print("Shift ID is empty");
      }

      // String empId = storage.getItem('EmpId') ?? "";
      if (ShiftId.isEmpty) {
        print("LocalStorage shiftId is null or empty");
      }
      final DocumentReference shiftDocRef =
          FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
      final DocumentSnapshot shiftDoc = await shiftDocRef.get();
      print(DocumentSnapshot);
      if (shiftDoc.exists) {
        List<dynamic> shiftTasks = shiftDoc['ShiftTask'];
        print("Shift Doc exists");
        print(shiftTasks.length);
        for (int i = 0; i < shiftTasks.length; i++) {
          print("Success: $ShiftTaskId");
          List<String> imgUrls = [];
          for (var upload in uploads) {
            if (upload['type'] == 'image') {
              File file = upload['file'];
              print(file);
              // Upload the image file and get the download URL
              List<Map<String, dynamic>> downloadURLs =
                  await addImageToStorageShiftTask(file);
              // Add the image URLs to the list
              for (var urlMap in downloadURLs) {
                if (urlMap.containsKey('downloadURL')) {
                  imgUrls.add(urlMap['downloadURL'] as String);
                }
              }
            }
          }

          if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
            // Create ShiftTaskStatus object with image URLs
            Map<String, dynamic> shiftTaskStatus = {
              "TaskStatus": "completed",
              "TaskCompletedById": EmpId ?? "",
              "TaskCompletedByName": "",
              "TaskCompletionTime": DateTime.now(),
              "TaskPhotos": imgUrls,
              // "ShiftTaskReturnStatus": true,
            };
            if (shiftTaskReturnStatus) {
              shiftTaskStatus["ShiftTaskReturnStatus"] = true;
            }
            // Update the ShiftTaskStatus array with the new object
            shiftTasks[i]['ShiftTaskStatus'] = [shiftTaskStatus];

            // Update the Firestore document with the new ShiftTaskStatus
            await shiftDocRef.update({'ShiftTask': shiftTasks});
            break; // Exit loop after updating
          }
        }
      } else {
        print("Shift document not found");
      }
    } catch (e) {
      print('Error adding images to ShiftTaskPhotos: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> addImageToStoragePatrol(File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      Reference uploadRef =
          storageRef.child("employees/patrol/$uniqueName.jpg");

      // Upload the image file and get the download URL
      // await uploadRef.putFile(file);

      // Get the download URL of the uploaded image
      Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 50, // Adjust the quality as needed
      );

      // Upload the compressed image to Firebase Storage
      await uploadRef.putData(Uint8List.fromList(compressedImage!));
      String downloadURL = await uploadRef.getDownloadURL();
      // Return the download URL in a list
      print({'downloadURL': downloadURL});
      return [
        {'downloadURL': downloadURL}
      ];
    } catch (e) {
      print(e);
      throw e;
    }
  }

  // Add images and comment
  Future<void> addImagesToPatrol(
      List<Map<String, dynamic>> uploads,
      String comment,
      String PatrolID,
      String EmpId,
      String PatrolCheckPointId) async {
    try {
      final querySnapshot = await patrols.doc(PatrolID).get();

      if (querySnapshot.exists) {
        final doc = querySnapshot.data() as Map<String, dynamic>;

        List<Map<String, dynamic>> wellnessReports =
            List.from(doc["PatrolReport"] ?? []);

        // Check if PatrolCheckPoints is null or not properly initialized
        List<dynamic> patrolCheckPoints = doc["PatrolCheckPoints"] ?? [];

        // Find the specific CheckPoint within PatrolCheckPoints
        var checkPoint = patrolCheckPoints.firstWhere(
            (cp) => cp["CheckPointId"] == PatrolCheckPointId,
            orElse: () => null);

        if (checkPoint != null) {
          // Ensure that CheckPointStatus is correctly initialized and cast to List<dynamic>
          List<dynamic> checkPointStatus = checkPoint["CheckPointStatus"] ?? [];

          // Find the specific status within CheckPointStatus where StatusReportedById matches EmpId
          var status = checkPointStatus.firstWhere(
              (s) => s["StatusReportedById"] == EmpId,
              orElse: () => null);

          if (status != null) {
            List<Map<String, dynamic>> imgUrls = [];
            for (var upload in uploads) {
              if (upload['type'] == 'image') {
                File file = upload['file'];

                // Upload the image file and get the download URL
                List<Map<String, dynamic>> downloadURL =
                    await addImageToStoragePatrol(file);

                // Add the download URLs to the imgUrls list
                for (var url in downloadURL) {
                  imgUrls.add(url);
                }
              }
            }

            // Add the new image and comment map to the status
            status["StatusImage"] =
                imgUrls.map((url) => url['downloadURL']).toList();
            status["StatusComment"] = comment;

            // Update the Firestore document with the new wellness reports
            await patrols.doc(PatrolID).update({
              "PatrolReport": wellnessReports,
              "PatrolCheckPoints": patrolCheckPoints,
            });
          } else {
            print("No status found for EmpId: $EmpId");
          }
        } else {
          print("No CheckPoint found with CheckPointId: $PatrolCheckPointId");
        }
      } else {
        print("No document found with PatrolID: $PatrolID");
      }
    } catch (e) {
      print('Error adding images to PatrolReport: $e');
      throw e;
    }
  }

  //Update the shift status when the qr is scanned correctly
  Future<void> updateShiftTaskStatus(
      String ShiftTaskId, String EmpID, String EmpName) async {
    try {
      final LocalStorage storage = LocalStorage('ShiftDetails');
      String shiftId = storage.getItem('shiftId');
      String empId = storage.getItem('EmpId') ?? "";

      final DocumentReference shiftDocRef =
          FirebaseFirestore.instance.collection("Shifts").doc(shiftId);
      final DocumentSnapshot shiftDoc = await shiftDocRef.get();

      if (shiftDoc.exists) {
        List<dynamic> shiftTasks = shiftDoc['ShiftTask'];

        for (int i = 0; i < shiftTasks.length; i++) {
          if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
            // Create ShiftTaskStatus object without images
            Map<String, dynamic> shiftTaskStatus = {
              "TaskStatus": "completed",
              "TaskCompletedById": EmpID,
              "TaskCompletedByName": EmpName,
              "TaskCompletionTime": DateTime.now(),
            };

            // Update the ShiftTaskStatus array with the new object
            shiftTasks[i]['ShiftTaskStatus'] = [shiftTaskStatus];

            // Update the Firestore document with the new ShiftTaskStatus
            await shiftDocRef.update({'ShiftTask': shiftTasks});
            break; // Exit loop after updating
          }
        }
        print('Updated Status');
      } else {
        print("Shift document not found");
      }
    } catch (e) {
      print('Error updating ShiftTaskStatus: $e');
      throw e;
    }
  }

  //Fetch mails
  Future<String?> getClientEmail(String clientId) async {
    try {
      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(clientId)
          .get();

      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        String clientEmail = clientData['ClientEmail'];
        print('Client Email: $clientEmail');
        return clientEmail;
      } else {
        print('Client not found');
        return null; // Return null if client is not found
      }
    } catch (e) {
      print('Error fetching client: $e');
      return null; // Return null in case of error
    }
  }

  Future<String?> getAdminEmail(String companyId) async {
    try {
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Admins')
          .where('AdminCompanyId', isEqualTo: companyId)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        String adminEmail = adminSnapshot.docs.first['AdminEmail'];
        print('Admin Email: $adminEmail');
        return adminEmail;
      } else {
        print('Admin not found');
        return null; // Return null if admin is not found
      }
    } catch (e) {
      print('Error fetching admin: $e');
      return null; // Return null in case of error
    }
  }

  void getClientID(String clientId) async {
    try {
      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(clientId)
          .get();

      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        String? clientEmail = clientData['ClientEmail'];
        print('Client Email: $clientEmail');
      } else {
        print('Client not found');
      }
    } catch (e) {
      print('Error fetching client: $e');
    }
  }
  //PatrolClientId
}

// Schedule and assign
