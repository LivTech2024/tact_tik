import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/supervisor%20screens/patrol_logs.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/auth/auth.dart';

class FireStoreService {
  final Auth auth = Auth();
  final LocalStorage storage = LocalStorage('currentUserEmail');
  // FirebaseStorage firebaseStorage = FirebaseStorage.instance.ref();
  //Read LoggedIN User Information
  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection("Employees");
  final CollectionReference clientInfo =
      FirebaseFirestore.instance.collection("Clients");
  final CollectionReference shifts =
      FirebaseFirestore.instance.collection("Shifts");
  final CollectionReference patrols =
      FirebaseFirestore.instance.collection("Patrols");
  final CollectionReference setting =
      FirebaseFirestore.instance.collection("Settings");
  final CollectionReference log =
      FirebaseFirestore.instance.collection("LogBook");
  //Get userinfo based on the useremailid
  Future<DocumentSnapshot?> getUserInfoByCurrentUserEmail() async {
    String? currentUser = storage.getItem("CurrentUser");

    if (currentUser == null || currentUser.isEmpty) {
      print("CurrentUSer is empty");
      return null;
    }

    final currentUserEmail = currentUser;
    if (currentUserEmail.isEmpty) {
      print("CurrentUSerEmail is empty");
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

  Future<DocumentSnapshot?> getUserInfoByCurrentUserEmail2() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No current user logged in");
      return null;
    }

    final currentUserEmail = currentUser.email;
    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      print("CurrentUserEmail is empty");
      return null;
    }
    print("CurrentUserEmail ${currentUserEmail}");
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

  Future<bool> checkShiftsForEmployee(DateTime date, String empId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the start and end of the specified date
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay =
        DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    try {
      // Query the Shifts collection where ShiftDate is between start and end of the specified date
      QuerySnapshot querySnapshot = await firestore
          .collection('Shifts')
          .where('ShiftDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('ShiftDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Loop through the documents to check ShiftAssignedUserId
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        List<dynamic> assignedUsers = doc['ShiftAssignedUserId'];
        if (assignedUsers.contains(empId)) {
          return true; // Return true if any document contains the employee ID
        }
      }
      return false; // Return false if no document contains the employee ID
    } catch (e) {
      print('Error checking shifts for employee: $e');
      return false; // Return false in case of an error
    }
  }

  Future<DocumentSnapshot?> getUserInfoByCurrentUserEmpId(String Empid) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // if (Empid == null) {
    //   print("No current user logged in");
    //   return null;
    // }

    // final currentUserEmail = currentUser.email;
    if (Empid == null || Empid.isEmpty) {
      print("CurrentUserEmail is empty");
      return null;
    }

    final querySnapshot =
        await userInfo.where("EmployeeId", isEqualTo: Empid).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Return the first document found
      print(querySnapshot.docs.first);
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  Future<DocumentSnapshot?> getClientInfoByCurrentUserEmail() async {
    String? currentUser = storage.getItem("CurrentUser");
    print("Curretn User ${currentUser}");

    if (currentUser == null || currentUser.isEmpty) {
      return null;
    }

    final currentUserEmail = currentUser;
    if (currentUserEmail.isEmpty) {
      return null;
    }

    final querySnapshot = await clientInfo
        .where("ClientEmail", isEqualTo: currentUserEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      print("Fetched CLient data ${querySnapshot.docs.first}");
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  //add to loggedinUsers
// export interface ILoggedInUsersCollection {
//   LoggedInId: string;
//   LoggedInUserId: string;
//   IsLoggedIn: boolean; //!Not required for user app
//   LoggedInUserType: IUserType;
//   LoggedInCreatedAt: Timestamp | FieldValue;
//   LoggedInNotifyFcmToken: string;
//   LoggedInPlatform: 'web' | 'android' | 'ios';
// }
// LoggedInUsers
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

  Future<void> updateLoggedInNotifyFcmToken({
    required String loggedInUserId,
    required String newNotifyFcmToken,
  }) async {
    try {
      CollectionReference loggedInCollection =
          FirebaseFirestore.instance.collection('LoggedInUsers');

      // Check if document with loggedInUserId exists
      QuerySnapshot querySnapshot = await loggedInCollection
          .where('LoggedInUserId', isEqualTo: loggedInUserId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Document exists, update the LoggedInNotifyFcmToken field
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'LoggedInNotifyFcmToken': newNotifyFcmToken,
        });
        print('FCM token updated successfully');
      } else {
        print('No user found with LoggedInUserId: $loggedInUserId');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<DocumentSnapshot?> getShiftByEmployeeIdFromUserInfo(
    String empId,
  ) async {
    if (empId.isEmpty) {
      return null;
    }

    final currentDate = DateTime.now();
    final oneDayBefore =
        DateTime(currentDate.year, currentDate.month, currentDate.day - 1);
    final oneDayAfter =
        DateTime(currentDate.year, currentDate.month, currentDate.day + 1);

    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", arrayContains: empId)
        .where("ShiftDate", isGreaterThanOrEqualTo: oneDayBefore)
        .where("ShiftDate", isLessThanOrEqualTo: oneDayAfter)
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

      final statusDoc = shiftTasks.isEmpty ||
          shiftTasks.any((status) =>
              status['StatusReportedById'] == empId &&
              (status['Status'] == 'pending' || status['Status'] == 'started'));
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

  Future<List<Map<String, dynamic>>> getPatrolsByClientId(
      String clientId) async {
    List<Map<String, dynamic>> patrolsList = [];

    try {
      // Query the Patrols collection where PatrolClientId equals the provided clientId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .where('PatrolClientId', isEqualTo: clientId)
          .get();

      // Iterate over the query results and add them to the list
      for (var doc in querySnapshot.docs) {
        patrolsList.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching patrols: $e');
    }

    return patrolsList;
  }

  //Fetching the patrolLogs Data
  // Future<List<Map<String, dynamic>>> getPatrolsLogs(String PatrolID) async {
  //   List<Map<String, dynamic>> patrolsList = [];

  //   try {
  //     // Query the Patrols collection where PatrolClientId equals the provided clientId
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('PatrolLogs')
  //         .where('PatrolId', isEqualTo: PatrolID)
  //         .get();

  //     // Iterate over the query results and add them to the list
  //     for (var doc in querySnapshot.docs) {
  //       patrolsList.add(doc.data() as Map<String, dynamic>);
  //     }
  //   } catch (e) {
  //     print('Error fetching patrols: $e');
  //   }

  //   return patrolsList;
  // }

  Future<List<Map<String, dynamic>>> getPatrolsLogs(String patrolId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('PatrolLogs')
          .where('PatrolId', isEqualTo: patrolId)
          .get();

      // Convert documents to a list of maps
      List<Map<String, dynamic>> patrolLogs = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Group by date and order by PatrolLogPatrolCount
      Map<String, List<Map<String, dynamic>>> groupedByDate = {};
      for (var log in patrolLogs) {
        String dateKey = DateFormat('yyyy-MM-dd').format(
          DateTime.fromMillisecondsSinceEpoch(
            log['PatrolLogStartedAt'].millisecondsSinceEpoch,
          ),
        );

        if (groupedByDate[dateKey] == null) {
          groupedByDate[dateKey] = [];
        }
        groupedByDate[dateKey]!.add(log);
      }

      // Sort each group by PatrolLogPatrolCount
      for (var dateKey in groupedByDate.keys) {
        groupedByDate[dateKey]!.sort((a, b) {
          return b['PatrolLogPatrolCount'].compareTo(a['PatrolLogPatrolCount']);
        });
      }

      // Flatten the list of grouped logs
      List<Map<String, dynamic>> sortedPatrolLogs = [];
      groupedByDate.forEach((dateKey, logs) {
        sortedPatrolLogs.addAll(logs);
      });

      return sortedPatrolLogs;
    } catch (e) {
      print('Error getting patrol logs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllPatrolsByShiftId(
      String shiftId) async {
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

    // Extract the ShiftLinkedPatrols array from the Shift document
    final shiftLinkedPatrols =
        List<Map<String, dynamic>>.from(shiftData["ShiftLinkedPatrols"] ?? []);

    // Extract Patrol IDs
    final patrolIds = shiftLinkedPatrols
        .map((patrol) => patrol["LinkedPatrolId"] as String)
        .toList();

    print("Patrol Linked IDS fetched: ${patrolIds}");

    // Fetch the Patrols using the Patrol IDs
    final querySnapshot =
        await patrols.where("PatrolId", whereIn: patrolIds).get();
    print("Retrieved documents Patrols:");

    querySnapshot.docs.forEach((doc) {
      print("Patrols Fetched");
      print(doc.data());
    });

    // Create a list to hold the patrol data along with required hit count
    List<Map<String, dynamic>> patrolData = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Find the corresponding ShiftLinkedPatrol data
      var linkedPatrol = shiftLinkedPatrols.firstWhere(
        (patrol) => patrol["LinkedPatrolId"] == data["PatrolId"],
        orElse: () => {},
      );

      if (linkedPatrol.isNotEmpty) {
        data["LinkedPatrolReqHitCount"] =
            linkedPatrol["LinkedPatrolReqHitCount"];
        data["LinkedPatrolReqHitCount"] =
            linkedPatrol["LinkedPatrolReqHitCount"];
        patrolData.add(data);
      }
    }

    return patrolData;
  }

  Future<List<Map<String, dynamic>>> getAllPatrolsByPatrolId(
      String shiftId, String patrolId) async {
    // Fetch the Patrols using the Patrol IDs
    final querySnapshot =
        await patrols.where("PatrolId", isEqualTo: patrolId).get();
    List<Map<String, dynamic>> patrolData = [];

    print("Retrieved documents Patrols:");
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> patrolsData = doc.data() as Map<String, dynamic>;
      patrolData.add(patrolsData);
      print("Patrols Fetched");
      print(patrolsData);
    });

    return patrolData;
  }

  Stream<QuerySnapshot> getPatrols(String EmpId) {
    final patrolStream = patrols
        .where("PatrolAssignedGuardId", isEqualTo: EmpId)
        .where("PatrolCurrentStatus", isEqualTo: "pending")
        .orderBy("PatrolTime", descending: false)
        .snapshots();
    return patrolStream;
  }

  Future<void> updatePatrolsStatus(String patrolId, String checkPointId,
      String empId, String shiftId) async {
    if (patrolId.isEmpty || checkPointId.isEmpty) {
      print('Patrol ID is empty');
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: patrolId)
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
          // Get existing CheckPointStatus or initialize if null
          var existingStatuses =
              List.from(checkpointToUpdate['CheckPointStatus'] ?? []);

          // Find the status to update or create a new one
          var statusToUpdate = existingStatuses.firstWhere(
            (status) =>
                status['StatusReportedById'] == empId &&
                status['StatusShiftId'] == shiftId,
            orElse: () => null,
          );

          if (statusToUpdate != null) {
            // Update the existing status
            statusToUpdate['Status'] = 'checked';
            statusToUpdate['StatusReportedTime'] = Timestamp.now();
          } else {
            // Add a new status entry
            existingStatuses.add({
              'Status': 'checked',
              'StatusReportedTime': Timestamp.now(),
              'StatusReportedById': empId,
              'StatusShiftId': shiftId
            });
          }

          // Update the checkpoint with the new status list
          checkpointToUpdate['CheckPointStatus'] = existingStatuses;

          // Update the document in Firestore
          await doc.reference.update({'PatrolCheckPoints': checkpoints});
          print("Updated Patrol Status for document: ${doc.id}");
        } else {
          print(
              "No matching checkpoint found for CheckPointId: $checkPointId in document: ${doc.id}");
        }
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
      bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
        DateTime dateTime1 = timestamp1.toDate();
        DateTime dateTime2 = timestamp2.toDate();
        return dateTime1.year == dateTime2.year &&
            dateTime1.month == dateTime2.month &&
            dateTime1.day == dateTime2.day;
      }

      // Check if the status entry already exists
      List<Map<String, dynamic>> currentStatusList =
          List<Map<String, dynamic>>.from(data?['PatrolCurrentStatus'] ?? []);
      int existingIndex = currentStatusList.indexWhere((entry) =>
          entry['StatusReportedById'] == statusReportedById &&
          _isSameDay(entry['StatusReportedTime'], Timestamp.now()));

      if (existingIndex != -1) {
        // If the status entry exists for today, update it
        currentStatusList[existingIndex]['Status'] = status;
        currentStatusList[existingIndex]['StatusReportedByName'] =
            statusReportedByName;
        currentStatusList[existingIndex]['StatusReportedTime'] =
            Timestamp.now();
      } else {
        // If the status entry doesn't exist for today, add a new entry
        currentStatusList.add({
          'Status': status,
          'StatusReportedById': statusReportedById,
          'StatusReportedByName': statusReportedByName,
          'StatusReportedTime': Timestamp.now(),
        });
      }
      await updatePatrolCheckpointStatus(docId,
          statusReportedById); //This wont change the checkpoint status to unchecked

      await patrolDocument.update({
        'PatrolCurrentStatus': currentStatusList,
      });

      print('Document updated successfully');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  // using this at the start patrol button , so that patrol status will be unchecked for new patrol iteration
  Future<void> updatePatrolCurrentStatusToUnchecked(
      String docId,
      String status,
      String? statusReportedById,
      String? statusReportedByName,
      String ShiftId) async {
    try {
      // Get a reference to the Firestore document
      DocumentReference<Map<String, dynamic>> patrolDocument =
          FirebaseFirestore.instance.collection('Patrols').doc(docId);

      // Fetch the current document data
      var documentSnapshot = await patrolDocument.get();
      var data = documentSnapshot.data();
      // bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
      //   DateTime dateTime1 = timestamp1.toDate();
      //   DateTime dateTime2 = timestamp2.toDate();
      //   return dateTime1.year == dateTime2.year &&r
      //       dateTime1.month == dateTime2.month &&
      //       dateTime1.day == dateTime2.day;
      // }

      // Check if the status entry already exists
      List<Map<String, dynamic>> currentStatusList =
          List<Map<String, dynamic>>.from(data?['PatrolCurrentStatus'] ?? []);
      int existingIndex = currentStatusList.indexWhere((entry) =>
          entry['StatusReportedById'] == statusReportedById &&
          entry['StatusShiftId'] == ShiftId);

      if (existingIndex != -1) {
        // If the status entry exists for today, update it
        currentStatusList[existingIndex]['Status'] = status;
        currentStatusList[existingIndex]['StatusReportedByName'] =
            statusReportedByName;
        currentStatusList[existingIndex]['StatusReportedTime'] =
            Timestamp.now();
        currentStatusList[existingIndex]['StatusShiftId'] = ShiftId;
      } else {
        // If the status entry doesn't exist for today, add a new entry
        currentStatusList.add({
          'Status': status,
          'StatusReportedById': statusReportedById,
          'StatusReportedByName': statusReportedByName,
          'StatusShiftId': ShiftId,
          'StatusReportedTime': Timestamp.now(),
        });
      }
      await updatePatrolCheckpointStatusToUnchecked(docId, statusReportedById,
          ShiftId); //updates the checkpoint status to unchecked
      // Update the document with the updated status array
      await patrolDocument.update({
        'PatrolCurrentStatus': currentStatusList,
      });

      print('Document updated successfully');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> updatePatrolCheckpointStatus(
    String docId,
    String? statusReportedById,
  ) async {
    try {
      // Get a reference to the Firestore document
      DocumentReference<Map<String, dynamic>> patrolDocument =
          FirebaseFirestore.instance.collection('Patrols').doc(docId);

      // Fetch the current document data
      var documentSnapshot = await patrolDocument.get();
      var data = documentSnapshot.data();
      bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
        DateTime dateTime1 = timestamp1.toDate();
        DateTime dateTime2 = timestamp2.toDate();
        return dateTime1.year == dateTime2.year &&
            dateTime1.month == dateTime2.month &&
            dateTime1.day == dateTime2.day;
      }

      // Check if the PatrolCheckPoints array exists
      List<Map<String, dynamic>> checkPointsList =
          List<Map<String, dynamic>>.from(data?['PatrolCheckPoints'] ?? []);

      // Update CheckPointStatus for each checkpoint
      checkPointsList.forEach((checkpoint) {
        List<Map<String, dynamic>> checkPointStatuses =
            List<Map<String, dynamic>>.from(
                checkpoint['CheckPointStatus'] ?? []);

        // Find the latest status reported by the same ID
        int existingIndex = checkPointStatuses.indexWhere((status) =>
            status['StatusReportedById'] == statusReportedById &&
            _isSameDay(status['StatusReportedTime'], Timestamp.now()));

        // Update CheckPointStatus if it is empty, null, or not updated today
        if (existingIndex == -1) {
          checkPointStatuses.add({
            // 'Status': 'unchecked',
            'StatusReportedById': statusReportedById,
            'StatusReportedTime': Timestamp.now(),
          });
        } else {
          // Update the existing status with the current timestamp and 'unchecked' status
          // checkPointStatuses[existingIndex]['Status'] = 'unchecked';
          checkPointStatuses[existingIndex]['StatusReportedTime'] =
              Timestamp.now();
        }

        // Update the CheckPointStatus in the checkpoint
        checkpoint['CheckPointStatus'] = checkPointStatuses;
      });

      // Update the document with the updated CheckPoints array
      await patrolDocument.update({
        'PatrolCheckPoints': checkPointsList,
      });

      print('Document updated successfully');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> updatePatrolCheckpointStatusToUnchecked(
      String docId, String? statusReportedById, String shiftId) async {
    try {
      // Get a reference to the Firestore document
      DocumentReference<Map<String, dynamic>> patrolDocument =
          FirebaseFirestore.instance.collection('Patrols').doc(docId);

      // Fetch the current document data
      var documentSnapshot = await patrolDocument.get();
      var data = documentSnapshot.data();
      bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
        DateTime dateTime1 = timestamp1.toDate();
        DateTime dateTime2 = timestamp2.toDate();
        return dateTime1.year == dateTime2.year &&
            dateTime1.month == dateTime2.month &&
            dateTime1.day == dateTime2.day;
      }

      // Check if the PatrolCheckPoints array exists
      List<Map<String, dynamic>> checkPointsList =
          List<Map<String, dynamic>>.from(data?['PatrolCheckPoints'] ?? []);

      // Update CheckPointStatus for each checkpoint
      checkPointsList.forEach((checkpoint) {
        List<Map<String, dynamic>> checkPointStatuses =
            List<Map<String, dynamic>>.from(
                checkpoint['CheckPointStatus'] ?? []);

        // Find the latest status reported by the same ID
        int existingIndex = checkPointStatuses.indexWhere((status) =>
            status['StatusReportedById'] == statusReportedById &&
            // _isSameDay(status['StatusReportedTime'], Timestamp.now()
            status['StatusShiftId'] == shiftId);

        // Update CheckPointStatus if it is empty, null, or not updated today
        if (existingIndex == -1) {
          checkPointStatuses.add({
            'Status': 'unchecked',
            'StatusReportedById': statusReportedById,
            'StatusReportedTime': Timestamp.now(),
            'StatusShiftId': shiftId
          });
        } else {
          // Update the existing status with the current timestamp and 'unchecked' status
          checkPointStatuses[existingIndex]['Status'] = 'unchecked';
          checkPointStatuses[existingIndex]['StatusReportedTime'] =
              Timestamp.now();
          checkPointStatuses[existingIndex]['StatusImage'] = [];
        }

        // Update the CheckPointStatus in the checkpoint
        checkpoint['CheckPointStatus'] = checkPointStatuses;
      });

      // Update the document with the updated CheckPoints array
      await patrolDocument.update({
        'PatrolCheckPoints': checkPointsList,
      });

      print('Document updated successfully');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> EndPatrolupdatePatrolsStatus(
      String patrolId,
      String statusReportedById,
      String statusReportedByName,
      String ShiftID) async {
    if (patrolId.isEmpty) {
      return;
    }

    DocumentReference<Map<String, dynamic>> patrolDocument =
        FirebaseFirestore.instance.collection('Patrols').doc(patrolId);

    try {
      // Fetch the current document data
      var documentSnapshot = await patrolDocument.get();
      var data = documentSnapshot.data();

      // Update checkpoint statuses to "unchecked"
      List<dynamic> checkpoints = List.from(data?['PatrolCheckPoints'] ?? []);
      checkpoints.forEach((checkpoint) {
        List<dynamic> status = List.from(checkpoint['CheckPointStatus']);
        status.forEach((entry) {
          entry['Status'] = 'unchecked';
          // entry['StatusReportedTime'] = Timestamp.now();
        });
      });
      bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
        DateTime dateTime1 = timestamp1.toDate();
        DateTime dateTime2 = timestamp2.toDate();
        return dateTime1.year == dateTime2.year &&
            dateTime1.month == dateTime2.month &&
            dateTime1.day == dateTime2.day;
      }

      // Update the status entry for the given statusReportedById
      List<Map<String, dynamic>> currentStatusList =
          List<Map<String, dynamic>>.from(data?['PatrolCurrentStatus'] ?? []);

      // Check if the status entry already exists for today
      int existingIndex = currentStatusList.indexWhere((entry) =>
          entry['StatusReportedById'] == statusReportedById &&
          // _isSameDay(entry['StatusReportedTime'], Timestamp.now())
          entry['StatusShiftId'] == ShiftID);

      if (existingIndex != -1) {
        // If the status entry exists for today, update it
        currentStatusList[existingIndex]['Status'] = "completed";
        currentStatusList[existingIndex]['StatusReportedByName'] =
            statusReportedByName;
        // currentStatusList[existingIndex]['StatusReportedTime'] =
        //     Timestamp.now();
        currentStatusList[existingIndex]['StatusCompletedCount'] =
            (currentStatusList[existingIndex]['StatusCompletedCount'] ?? 0) + 1;
      } else {
        // If the status entry doesn't exist for today, add a new entry
        currentStatusList.add({
          'Status': "completed",
          'StatusReportedById': statusReportedById,
          'StatusReportedByName': statusReportedByName,
          'StatusCompletedCount': 1,
          'StatusReportedTime': Timestamp.now(),
          'StatusShiftId': ShiftID
        });
      }

      // Update the document with the updated CheckPoints and PatrolCurrentStatus arrays
      await patrolDocument.update({
        'PatrolCheckPoints': checkpoints,
        'PatrolCurrentStatus': currentStatusList,
      });

      print("Patrol and checkpoint statuses updated successfully");
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  Future<void> LastEndPatrolupdatePatrolsStatus(
      String patrolId,
      String statusReportedById,
      String statusReportedByName,
      String ShiftId) async {
    if (patrolId.isEmpty) {
      return;
    }

    DocumentReference<Map<String, dynamic>> patrolDocument =
        FirebaseFirestore.instance.collection('Patrols').doc(patrolId);

    try {
      // Fetch the current document data
      var documentSnapshot = await patrolDocument.get();
      var data = documentSnapshot.data();
      bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
        DateTime dateTime1 = timestamp1.toDate();
        DateTime dateTime2 = timestamp2.toDate();
        return dateTime1.year == dateTime2.year &&
            dateTime1.month == dateTime2.month &&
            dateTime1.day == dateTime2.day;
      }

      // Update checkpoint statuses to "not_checked"
      List<dynamic> checkpoints = List.from(data?['PatrolCheckPoints'] ?? []);
      checkpoints.forEach((checkpoint) {
        List<dynamic> status = List.from(checkpoint['CheckPointStatus']);
        status.forEach((entry) {
          // entry['Status'] = 'checked';
          // entry['StatusReportedTime'] = Timestamp.now();
        });
      });

      // Update the status entry for the given statusReportedById
      List<Map<String, dynamic>> currentStatusList =
          List<Map<String, dynamic>>.from(data?['PatrolCurrentStatus'] ?? []);

      // Check if the status entry already exists for today
      int existingIndex = currentStatusList.indexWhere((entry) =>
          entry['StatusReportedById'] == statusReportedById &&
          entry['StatusShiftId'] == ShiftId);

      if (existingIndex != -1) {
        // If the status entry exists for today, update it
        currentStatusList[existingIndex]['Status'] = "completed";
        currentStatusList[existingIndex]['StatusReportedByName'] =
            statusReportedByName;
        currentStatusList[existingIndex]['StatusReportedTime'] =
            Timestamp.now();
        currentStatusList[existingIndex]['StatusCompletedCount'] =
            (currentStatusList[existingIndex]['StatusCompletedCount'] ?? 0) + 1;
      } else {
        // If the status entry doesn't exist for today, add a new entry
        currentStatusList.add({
          'Status': "completed",
          'StatusReportedById': statusReportedById,
          'StatusReportedByName': statusReportedByName,
          'StatusCompletedCount': 1,
          'StatusReportedTime': Timestamp.now(),
          'StatusShiftId': ShiftId
        });
      }

      // Update the document with the updated CheckPoints and PatrolCurrentStatus arrays
      await patrolDocument.update({
        'PatrolCheckPoints': checkpoints,
        'PatrolCurrentStatus': currentStatusList,
      });

      print("Patrol and checkpoint statuses updated successfully");
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  //Generate Patrol Logs
  // Future<void> fetchAndCreatePatrolLogs(
  //     String patrolId,
  //     String empId,
  //     String EmpName,
  //     int PatrolCount,
  //     String ShiftDate,
  //     Timestamp StartTime,
  //     Timestamp EndTime,
  //     String FeedbackComment) async {
  //   // Assuming Firestore is initialized
  //   var patrolsCollection = FirebaseFirestore.instance.collection('Patrols');
  //   var patrolDoc = await patrolsCollection.doc(patrolId).get();
  //   var patrolData = patrolDoc.data() as Map<String, dynamic>;
  //   print("Patrol Data from Fetch = ${patrolData}");
  //   final dateFormat = DateFormat('yyyy-MM-dd');
  //   DateTime shiftDateTime = dateFormat.parse(ShiftDate);

  //   // Convert DateTime to Timestamp
  //   Timestamp shiftTimestamp = Timestamp.fromDate(shiftDateTime);
  //   // Filter and extract relevant checkpoint status information
  //   List<Map<String, dynamic>> relevantCheckpoints = [];
  //   for (var checkpoint in patrolData['PatrolCheckPoints']) {
  //     for (var status in checkpoint['CheckPointStatus']) {
  //       if (status['StatusReportedById'] == empId) {
  //         relevantCheckpoints.add({
  //           'CheckPointName': checkpoint['CheckPointName'],
  //           'CheckPointStatus': status['Status'],
  //           'CheckPointComment': status['StatusComment'],
  //           'CheckPointImage': status['StatusImage'],
  //           'CheckPointReportedAt': status['StatusReportedTime']
  //         });
  //         break; // Stop iterating through CheckPointStatus once a match is found
  //       }
  //     }
  //   }

  //   // Save relevant checkpoint status information to Firestore in the PatrolLogs collection
  //   var patrolLogsCollection =
  //       FirebaseFirestore.instance.collection('PatrolLogs');
  //   var docRef = await patrolLogsCollection.add({
  //     'PatrolId': patrolData['PatrolId'],
  //     'PatrolDate': shiftTimestamp,
  //     'PatrolLogGuardId': empId,
  //     'PatrolLogGuardName': EmpName,
  //     'PatrolLogPatrolCount': PatrolCount,
  //     'PatrolLogFeedbackComment': FeedbackComment,
  //     'PatrolLogCheckPoints': relevantCheckpoints,
  //     'PatrolLogStatus': "completed",
  //     'PatrolLogStartedAt': StartTime,
  //     'PatrolLogEndedAt': EndTime,
  //     'PatrolLogCreatedAt': Timestamp.now(),
  //   });
  //   await docRef.update({'PatrolLogId': docRef.id});
  // }
  Future<void> fetchAndCreatePatrolLogs(
      String patrolId,
      String empId,
      String EmpName,
      int PatrolCount,
      String ShiftDate,
      Timestamp? StartTime,
      Timestamp EndTime,
      String FeedbackComment,
      String ShiftId) async {
    try {
      var patrolsCollection = FirebaseFirestore.instance.collection('Patrols');
      var patrolDoc = await patrolsCollection.doc(patrolId).get();
      var patrolData = patrolDoc.data() as Map<String, dynamic>?;

      if (patrolData == null) {
        print("No patrol data found for the given patrolId.");
        return;
      }

      print("Patrol Data from Fetch = ${patrolData}");
      DateTime dateTime = DateFormat("MMMM d, yyyy").parse(ShiftDate);
      Timestamp ShiftTimeStamp = Timestamp.fromDate(dateTime);

      // Filter and extract relevant checkpoint status information
      List<Map<String, dynamic>> relevantCheckpoints = [];
      Timestamp earliestDate = Timestamp.now();
      for (var checkpoint in patrolData['PatrolCheckPoints']) {
        for (var status in checkpoint['CheckPointStatus']) {
          if (status['StatusReportedById'] == empId) {
            Timestamp statusReportedTime =
                status['StatusReportedTime'] ?? Timestamp.now();
            if (statusReportedTime.toDate().isBefore(earliestDate.toDate())) {
              earliestDate = statusReportedTime;
            }
            relevantCheckpoints.add({
              'CheckPointName': checkpoint['CheckPointName'],
              'CheckPointStatus': status['Status'],
              'CheckPointComment': status['StatusComment'],
              'CheckPointImage': status['StatusImage'],
              'CheckPointReportedAt': statusReportedTime,
              'CheckPointFailureReason': status['StatusFailureReason'] ?? ""
            });
            break; // Stop iterating through CheckPointStatus once a match is found
          }
        }
      }

      var patrolLogsCollection =
          FirebaseFirestore.instance.collection('PatrolLogs');
      var docRef = await patrolLogsCollection.add({
        'PatrolId': patrolData['PatrolId'],
        'PatrolDate': ShiftTimeStamp,
        'PatrolLogGuardId': empId,
        'PatrolLogGuardName': EmpName,
        'PatrolLogPatrolCount': PatrolCount,
        'PatrolLogFeedbackComment': FeedbackComment,
        'PatrolLogCheckPoints': relevantCheckpoints,
        'PatrolLogStatus': "completed",
        'PatrolLogStartedAt': StartTime,
        'PatrolLogEndedAt': EndTime,
        'PatrolShiftId': ShiftId,
        'PatrolLogCreatedAt': Timestamp.now(),
      });
      await docRef.update({'PatrolLogId': docRef.id});

      final CollectionReference employeesDARRef =
          FirebaseFirestore.instance.collection('EmployeesDAR');
      QuerySnapshot querySnapshot = await employeesDARRef
          .where('EmpDarEmpId', isEqualTo: empId)
          .where('EmpDarShiftId', isEqualTo: ShiftId)
          .get();

      print("Shift Id ${ShiftId}");
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        DocumentReference employeeDARDoc = documentSnapshot.reference;
        DocumentSnapshot employeeDARSnapshot = await employeeDARDoc.get();
        Map<String, dynamic> employeeDARData =
            employeeDARSnapshot.data() as Map<String, dynamic>;

        print('EmpDarTile: ${employeeDARData['EmpDarTile']}');
        if (employeeDARData['EmpDarTile'] is List) {
          List<dynamic> empDarTiles = employeeDARData['EmpDarTile'];
          empDarTiles = empDarTiles
              .where((tile) => tile is Map<String, dynamic>)
              .toList();

          DateTime currentDate = DateTime.now();
          for (int i = 0; i < empDarTiles.length; i++) {
            Map<String, dynamic> tile = empDarTiles[i] as Map<String, dynamic>;
            Timestamp tileDate = tile['TileDate'] ?? Timestamp.now();
            String tileTime = tile['TileTime'] ?? "";

            if (currentDate.year == tileDate.toDate().year &&
                currentDate.month == tileDate.toDate().month &&
                currentDate.day == tileDate.toDate().day) {
              List<String> timeRange = tileTime.split(' - ');
              List<int> startTimeParts =
                  timeRange[0].split(':').map(int.parse).toList();
              List<int> endTimeParts =
                  timeRange[1].split(':').map(int.parse).toList();

              DateTime startTime = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                startTimeParts[0],
                startTimeParts[1],
              );
              DateTime endTime = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                endTimeParts[0],
                endTimeParts[1],
              );

              if (endTime.isBefore(startTime)) {
                endTime = endTime.add(Duration(days: 1));
              }

              // if (Timestamp.now().toDate().isAfter(startTime) &&
              //     Timestamp.now().toDate().isBefore(endTime)) {
              if (StartTime != null) if ((StartTime.toDate()
                          .isBefore(endTime) &&
                      StartTime.toDate().isAfter(startTime)) ||
                  (EndTime.toDate().isBefore(endTime) &&
                      EndTime.toDate().isAfter(startTime)) ||
                  (StartTime.toDate().isBefore(startTime) &&
                      EndTime.toDate().isAfter(endTime))) {
                print("PatrolData ${patrolData}");
                String PatrolName = patrolData['PatrolName'];
                List<dynamic> checkpoints = patrolData['PatrolCheckPoints'];
                List<String> imageUrls = [];

                if (checkpoints != null) {
                  for (var checkpoint in checkpoints) {
                    List<dynamic>? statuses = checkpoint['CheckPointStatus'];
                    if (statuses != null) {
                      for (var status in statuses) {
                        if (status['StatusReportedById'] == empId) {
                          List<dynamic>? statusImages = status['StatusImage'];
                          if (statusImages != null && statusImages.length > 0) {
                            // Check if there are any images and at least one exists
                            var imageUrl = statusImages[
                                0]; // Access the first element (index 0)
                            if (imageUrl is String) {
                              imageUrls.add(imageUrl);
                              break; // Exit the inner loop after adding the first image
                            }
                          }
                        }
                      }
                    }
                  }
                }

                Map<String, dynamic> tilePatrol = {
                  'TilePatrolName': PatrolName,
                  'TilePatrolId': docRef.id,
                  // Format patrol start and end times for display
                  'TilePatrolData':
                      'Patrol Started At: ${DateFormat('HH:mm').format(StartTime.toDate())}, Patrol Ended At: ${DateFormat('HH:mm').format(EndTime.toDate())}',
                  'TilePatrolImage': imageUrls,
                };
                print(imageUrls);
                String updateString =
                    "Patrol Name ${PatrolName} Patrol Started At: ${DateFormat('HH:mm').format(StartTime.toDate())}, Patrol Ended At: ${DateFormat('HH:mm').format(EndTime.toDate())}";
                // tile['TileContent'] = updateString;
                if (!tile.containsKey('TilePatrol')) {
                  tile['TilePatrol'] = []; // Initialize as an empty array
                }
                tile['TilePatrol'].add(tilePatrol);

                empDarTiles[i] = tile;
                // empDarTiles[i] = tilePatrol;
                print('Updated Tile at index $i: $tile');
              } else {
                print("Current Timestamp ${Timestamp.now().toDate()}");
                print("startTime At $startTime");
                print("endTime At $endTime");
                print("unsuccessful in updating the tile");
              }
            }
          }
          print("Updating the Dar ${employeeDARDoc.id}");
          await employeeDARDoc
              .set({'EmpDarTile': empDarTiles}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print('Error fetching and creating patrol logs: $e');
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

//Shift Break Functions
  Future<void> startBreak(String employeeId, String shiftId) async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> currentArray =
          List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);

      int index = currentArray.indexWhere((element) =>
          element['StatusReportedById'] == employeeId &&
          element['Status'] == 'started');

      if (index != -1) {
        Map<String, dynamic> currentStatus = currentArray[index];
        List<dynamic> statusBreaks =
            List.from(currentStatus['StatusBreak'] ?? []);

        final breakData = {
          'BreakStartTime': Timestamp.now(),
          'BreakEndTime': null,
        };

        statusBreaks.add(breakData);
        currentStatus['StatusBreak'] = statusBreaks;
        currentStatus['StatusIsBreak'] = true; // Update StatusIsBreak to true
        currentArray[index] = currentStatus;

        await documentReference.update({'ShiftCurrentStatus': currentArray});
      } else {
        print('No active shift found for the employee.');
      }
    } catch (e) {
      print('Error starting break: $e');
      // Handle the error as needed
    }
  }

  Future<void> endBreak(String employeeId, String shiftId) async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> currentArray =
          List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);

      int index = currentArray.indexWhere((element) =>
          element['StatusReportedById'] == employeeId &&
          element['Status'] == 'started');

      if (index != -1) {
        Map<String, dynamic> currentStatus = currentArray[index];
        List<dynamic> statusBreaks =
            List.from(currentStatus['StatusBreak'] ?? []);

        if (statusBreaks.isNotEmpty) {
          int lastBreakIndex = statusBreaks
              .lastIndexWhere((breakData) => breakData['BreakEndTime'] == null);
          if (lastBreakIndex != -1) {
            statusBreaks[lastBreakIndex]['BreakEndTime'] = Timestamp.now();
            currentStatus['StatusBreak'] = statusBreaks;
            currentStatus['StatusIsBreak'] =
                false; // Update StatusIsBreak to false
            currentArray[index] = currentStatus;

            await documentReference
                .update({'ShiftCurrentStatus': currentArray});
          } else {
            print('No ongoing break found to end.');
          }
        } else {
          print('No break records found.');
        }
      } else {
        print('No active shift found for the employee.');
      }
    } catch (e) {
      print('Error ending break: $e');
      // Handle the error as needed
    }
  }

//Update the User Shift Status
  Future<void> startShiftLog(
      String employeeId, String shiftId, String EmpName) async {
    try {
      // Get the current system time
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> currentArray =
          List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);
      final statusData = {
        'Status': 'started',
        'StatusReportedById': employeeId,
        'StatusReportedByName': EmpName,
        'StatusStartedTime': Timestamp.now(),
        'StatusReportedTime': Timestamp.now(),
        'StatusIsBreak': false,
        'StatusBreak': []
      };
      int index = currentArray.indexWhere((element) =>
          element['StatusReportedById'] == employeeId &&
          element['Status'] == 'started');
      if (index != -1) {
        // If the map already exists in the array, update it
        currentArray[index] = statusData;
      } else {
        // If the map doesn't exist, add it to the array
        currentArray.add(statusData);
      }
      //acknowledge
      await documentReference.update({'ShiftCurrentStatus': currentArray});
      await documentReference.update({
        'ShiftAcknowledgedByEmpId': FieldValue.arrayUnion([employeeId])
      });
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
    String EmpNames,
    String ClientId,
  ) async {
    try {
      if (shiftId == null || shiftId.isEmpty) {
        throw ArgumentError('Invalid shiftId: $shiftId');
      }

      // Update the shift status in Firestore
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? savedInTime = prefs.getInt('savedInTime');
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);

      // Use a transaction to ensure data consistency
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot documentSnapshot =
            await transaction.get(documentReference);
        List<dynamic> currentArray =
            List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);

        final statusData = {
          'Status': 'completed',
          'StatusReportedById': employeeId,
          'StatusReportedByName': EmpNames,
          'StatusReportedTime': Timestamp.now(),
        };

        int index = currentArray.indexWhere((element) =>
            element['StatusReportedById'] == employeeId &&
            element['Status'] == 'started');

        if (index != -1) {
          // If the map already exists, update it excluding StatusStartedTime
          currentArray[index]
              .removeWhere((key) => key['StatusStartedTime'] != null);
          currentArray[index].addAll(statusData);
        } else {
          // If the map doesn't exist, add it to the array
          currentArray.add(statusData);
        }

        transaction
            .update(documentReference, {'ShiftCurrentStatus': currentArray});
      });

      // Generate report (rest of the code remains the same)
      // ...

      // Get the current system time
      DateTime currentTime = DateTime.now();
      print('Shift end logged at $currentTime');
    } catch (e) {
      print('Error logging shift end: $e');
    }
  }

  Future<List<String>> getCheckpointImages(String patrolId, String checkpointId,
      String reportedById, String shiftId) async {
    final CollectionReference patrolsCollection =
        FirebaseFirestore.instance.collection('Patrols');

    try {
      final patrolDocument = await patrolsCollection.doc(patrolId).get();
      if (patrolDocument.exists) {
        final patrolData = patrolDocument.data();

        // Check if PatrolCheckPoints is a map
        if (patrolData is Map && patrolData.containsKey('PatrolCheckPoints')) {
          final checkpoints = patrolData['PatrolCheckPoints'] as List;

          // Find the checkpoint with matching ID
          final checkpoint = checkpoints.firstWhere(
              (checkpoint) => checkpoint['CheckPointId'] == checkpointId);

          if (checkpoint != null) {
            // Extract image URLs from checkpoint status with reportedById check
            final statusArray = checkpoint['CheckPointStatus'] as List;
            final images = statusArray
                .where((status) =>
                    status['StatusReportedById'] == reportedById &&
                    status["StatusShiftId"] == shiftId)
                .map((status) => status['StatusImage'] as List)
                .expand((imageArray) => imageArray)
                .toList()
                .cast<String>();
            return images;
          } else {
            // Checkpoint not found in patrol
            return [];
          }
        } else {
          // Patrol doesn't have PatrolCheckPoints data
          return [];
        }
      } else {
        // Patrol document not found
        return [];
      }
    } catch (error) {
      // Handle errors
      print('Error fetching checkpoint images: $error');
      return [];
    }
  }

// fetch the patrol checkpoints that are unchecked
//using the patrol id, empid and shiftid
  Future<void> uncheckedCheckpointsFetch(
      String PatrolId, String ShiftId, String EmpId) async {
    try {
      // Assuming Firestore is initialized and you have a collection reference
      // 'PatrolCheckPoints' containing the data
      var snapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .doc(PatrolId)
          .get();

      // Assuming CheckPointStatus is a list
      List<dynamic> checkpoints = snapshot.data()!['CheckPointStatus'];

      checkpoints.forEach((checkpoint) {
        // Extracting checkpoint details
        String checkPointName = checkpoint['CheckPointName'];
        String status = checkpoint['Status'];
        // Extracting status details if available
        String statusComment = checkpoint['StatusComment'] ?? '';
        List<String> statusImages =
            (checkpoint['StatusImage'] ?? []).cast<String>();

        // Use the extracted information as needed
        print(
            'Checkpoint: $checkPointName, Status: $status, Comment: $statusComment, Images: $statusImages');
      });
    } catch (e) {
      print('Error fetching checkpoints: $e');
    }
  }

  //upload to uncheckedCheckpointReason
  Future<void> EndShiftLogComment(
      String employeeId,
      String Stopwatch,
      String? shiftId,
      String LocationName,
      String BrachId,
      String CompyId,
      String EmpNames,
      String ClientId,
      String Reason) async {
    try {
      if (shiftId == null || shiftId.isEmpty) {
        throw ArgumentError('Invalid shiftId: $shiftId');
      }

      // Update the shift status in Firestore
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? savedInTime = prefs.getInt('savedInTime');
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> currentArray =
          List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);

      final newStatusData = {
        'Status': 'completed',
        'StatusReportedById': employeeId,
        'StatusReportedByName': EmpNames,
        'StatusReportedTime': Timestamp.now(),
        'StatusStartedTime': savedInTime != null
            ? DateTime.fromMillisecondsSinceEpoch(savedInTime)
            : null,
        'StatusEndReason': Reason ?? ""
      };

      bool updated = false;

      for (var i = 0; i < currentArray.length; i++) {
        var status = currentArray[i];
        if (status['StatusReportedById'] == employeeId &&
            status['Status'] == 'completed') {
          print("Already completed");
          return;
        }
        if (status['StatusReportedById'] == employeeId &&
            status['Status'] == 'started') {
          // Merge existing status with new status data
          status['Status'] = newStatusData['Status'];
          status['StatusReportedTime'] = newStatusData['StatusReportedTime'];
          status['StatusEndReason'] = newStatusData['StatusEndReason'];

          // Update fields if they exist in newStatusData
          if (newStatusData['StatusStartedTime'] != null) {
            status['StatusStartedTime'] = newStatusData['StatusStartedTime'];
          }

          updated = true;
          break;
        }
      }

      if (!updated) {
        // If no existing "started" status is found, add the new "completed" status
        // currentArray.add(newStatusData);
      }

      await documentReference.update({'ShiftCurrentStatus': currentArray});

      // Generate report
      String Title = "ShiftEnded";
      String Data = "Shift Ended ";
      String type = "Shift";
      // await generateReport(LocationName, Title, employeeId, BrachId, Data,
      //     CompyId, "completed", EmpNames, ClientId, type);

      // Get the current system time
      DateTime currentTime = DateTime.now();
      print('Shift end logged at $currentTime');
    } catch (e) {
      print('Error logging shift end: $e');
    }
  }

  // Future<void> EndShiftLogComment(
  //     String employeeId,
  //     String Stopwatch,
  //     String? shiftId,
  //     String LocationName,
  //     String BrachId,
  //     String CompyId,
  //     String EmpNames,
  //     String ClientId,
  //     String Reason) async {
  //   try {
  //     if (shiftId == null || shiftId.isEmpty) {
  //       throw ArgumentError('Invalid shiftId: $shiftId');
  //     }

  //     // Update the shift status in Firestore
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     final int? savedInTime = prefs.getInt('savedInTime');
  //     DocumentReference documentReference =
  //         FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
  //     DocumentSnapshot documentSnapshot = await documentReference.get();
  //     List<dynamic> currentArray =
  //         List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);
  //     final statusData = {
  //       'Status': 'completed',
  //       'StatusReportedById': employeeId,
  //       'StatusReportedByName': EmpNames,
  //       'StatusReportedTime': Timestamp.now(),
  //       'StatusStartedTime': savedInTime != null
  //           ? DateTime.fromMillisecondsSinceEpoch(savedInTime)
  //           : null,
  //       'StatusEndReason': Reason ?? ""
  //     };
  //     int index = currentArray.indexWhere((element) =>
  //         element['StatusReportedById'] == employeeId &&
  //         element['Status'] == 'started');
  //     if (index != -1) {
  //       // If the map already exists in the array, update it
  //       currentArray[index]['Status'] = 'completed';
  //       currentArray[index]['StatusReportedById'] = employeeId;
  //       currentArray[index]['StatusReportedByName'] = EmpNames;
  //       currentArray[index]['StatusReportedTime'] = Timestamp.now();
  //       currentArray[index]['StatusEndReason'] = Reason ?? "";
  //     } else {
  //       // If the map doesn't exist, add it to the array
  //       currentArray.add(statusData);
  //     }
  //     await documentReference.update({'ShiftCurrentStatus': currentArray});

  //     // Generate report
  //     String Title = "ShiftEnded";
  //     String Data = "Shift Ended ";
  //     String type = "Shift";
  //     // await generateReport(LocationName, Title, employeeId, BrachId, Data,
  //     //     CompyId, "completed", EmpNames, ClientId, type);

  //     // Get the current system time
  //     DateTime currentTime = DateTime.now();
  //     print('Shift end logged at $currentTime');
  //   } catch (e) {
  //     print('Error logging shift end: $e');
  //   }
  // }

  Future<void> EndShiftLog2(
      String employeeId,
      String Stopwatch,
      String? shiftId,
      String LocationName,
      String BrachId,
      String CompyId,
      String EmpNames,
      String ClientId) async {
    try {
      if (shiftId == null || shiftId.isEmpty) {
        throw ArgumentError('Invalid shiftId: $shiftId');
      }

      // Update the shift status in Firestore
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int? savedInTime = prefs.getInt('savedInTime');
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> currentArray =
          List.from(documentSnapshot['ShiftCurrentStatus'] ?? []);
      final statusData = {
        'Status': 'completed',
        'StatusReportedById': employeeId,
        'StatusReportedByName': EmpNames,
        'StatusReportedTime': Timestamp.now(),
        'StatusStartedTime': savedInTime != null
            ? DateTime.fromMillisecondsSinceEpoch(savedInTime)
            : null,
        // 'StatusEndReason': Reason ?? ""
      };
      int index = currentArray.indexWhere((element) =>
          element['StatusReportedById'] == employeeId &&
          element['Status'] == 'started');
      if (index != -1) {
        // If the map already exists in the array, update it
        currentArray[index]['Status'] = 'completed';
        currentArray[index]['StatusReportedById'] = employeeId;
        currentArray[index]['StatusReportedByName'] = EmpNames;
        currentArray[index]['StatusReportedTime'] = Timestamp.now();
        // currentArray[index]['StatusEndReason'] = Reason ?? "";
      } else {
        // If the map doesn't exist, add it to the array
        currentArray.add(statusData);
      }
      await documentReference.update({'ShiftCurrentStatus': currentArray});

      // Generate report
      String Title = "ShiftEnded";
      String Data = "Shift Ended ";
      String type = "Shift";
      // await generateReport(LocationName, Title, employeeId, BrachId, Data,
      //     CompyId, "completed", EmpNames, ClientId, type);

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
        .where("EmployeeSupervisorId", arrayContains: CompanyId)
        .where("EmployeeIsBanned", isEqualTo: false)
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
      String ClientID) async {
    try {
      print('Ending patrol...');
      // Get the current system time
      DateTime currentTime = DateTime.now();
      String data = "Patrolling Ended";
      // Modify the PatrolModifiedAt
      final patrolRef = FirebaseFirestore.instance
          .collection('Patrols')
          .where("PatrolId", isEqualTo: PatrolId);
      String type = "Patrol";
      // await generateReport(PatrolArea, PatrolName, patrolAssignedGuardId, BId,
      //     data, PatrolCompanyId, "completed", EmpName, ClientID, type);

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

  Future<String?> getReportCategoryId(String type, String CompanyID) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ReportCategories")
        .where("ReportCategoryName", isEqualTo: type)
        .where('ReportCompanyId', isEqualTo: CompanyID)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      print("Report Category Id fetched : ${doc.data()} ");
      return doc.id;
    } else {
      return null; // Handle case when no document is found
    }
  }

  Future<String?> createReportCategoryId(String type, String CompanyId) async {
    final ReportRef = FirebaseFirestore.instance.collection("ReportCategories");
    final newDoc = await ReportRef.add({
      "ReportCategoryCreatedAt": Timestamp.now(),
      "ReportCategoryName": type,
      "ReportCompanyId": CompanyId
    });
    await newDoc.update({"ReportCategoryId": newDoc.id});
    return newDoc.id;
  }

  Future<String> generateUniqueID(
      String reportDate, String reportCategory, String reportName) async {
    // Format the date
    String formattedDate = reportDate.replaceAll(' ', '').replaceAll(',', '');

    // Extract the first two initials of the report category
    List<String> categoryWords = reportCategory.split(' ');
    String categoryInitials = categoryWords
        .map((word) => word.length >= 2 ? word.substring(0, 2) : word)
        .join()
        .toUpperCase();

    // Extract the first two initials of the report name
    List<String> nameWords = reportName.split(' ');
    String nameInitials = nameWords
        .map((word) => word.length >= 2 ? word.substring(0, 2) : word)
        .join()
        .toUpperCase();

    // Combine the elements to form the base unique ID
    String baseUniqueID = '${formattedDate}${categoryInitials}${nameInitials}';

    // Query Firestore to check if the base unique ID already exists
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Reports')
        .where('ReportSearchId', isEqualTo: baseUniqueID)
        .get();

    // If the base unique ID doesn't exist, return it
    if (querySnapshot.docs.isEmpty) {
      return baseUniqueID;
    }

    // If the base unique ID already exists, find a unique ID by incrementing a number
    int counter = 1;
    String uniqueID = '';
    while (true) {
      uniqueID = '$baseUniqueID$counter';
      querySnapshot = await FirebaseFirestore.instance
          .collection('Reports')
          .where('ReportSearchId', isEqualTo: uniqueID)
          .get();
      if (querySnapshot.docs.isEmpty) {
        break;
      }
      counter++;
    }

    return uniqueID;
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
      String ClientID,
      String type) async {
    try {
      print('Generating report...');

      //report Categories fetch the id according to the

      var ReportCategoryId = await getReportCategoryId(type, CompanyId);
      final ReportRef = FirebaseFirestore.instance.collection("Reports");
      String combinationName = "${reportName} ${address}";
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
        "ReportCategoryId": ReportCategoryId,
        "ReportClientId": ClientID,
      });
      print('Report generated successfully');
      await newDocRef.update({"ReportId": newDocRef.id});
    } catch (e) {
      print('Error generating report: $e');
      // Handle the error as needed
    }
  }

  String getRandomString(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

  //Patrol is Completed
  Future<String> ScheduleShift(
    List guards,
    String? role,
    String address,
    String companyBranchId,
    String companyId,
    List<DateTime> date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<Map<dynamic, dynamic>> patrol,
    String clientID,
    String requiredEmp,
    String? photoInterval,
    String? restrictedRadius,
    bool shiftenablerestriction,
    GeoPoint coordinates,
    String locationName,
    String locationId,
    String locationAddress,
    String branchId,
    String shiftDesc,
    String shiftName,
    List<Map<String, dynamic>> tasks,
  ) async {
    try {
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

      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
      final DateFormat timeFormatter = DateFormat('HH:mm');
      final String? BranchId = await getBranchIdByName(companyBranchId);
      for (DateTime date in date) {
        // Create the shift document without tasks first
        final newDocRef = await shifts.add({
          'ShiftName': shiftName,
          'ShiftPosition': role ?? '',
          'ShiftDate': Timestamp.fromDate(date),
          'ShiftStartTime': startTime != null
              ? timeFormatter.format(DateTime(date.year, date.month, date.day,
                  startTime.hour, startTime.minute))
              : '',
          'ShiftEndTime': endTime != null
              ? timeFormatter.format(DateTime(date.year, date.month, date.day,
                  endTime.hour, endTime.minute))
              : '',
          'ShiftCompanyBranchId': BranchId ?? '',
          'ShiftDescription': shiftDesc,
          'ShiftLocationName': locationName,
          'ShiftLocationAddress': locationAddress,
          'ShiftLocationId': locationId,
          'ShiftLocation': coordinates,
          'ShiftAcknowledgedByEmpId': [],
          'ShiftGuardWellnessReport': [],
          'ShiftIsSpecialShift': false,
          'ShiftAssignedUserId': selectedGuardIds,
          'ShiftClientId': clientID,
          'ShiftCompanyId': companyId,
          'ShiftRequiredEmp': int.tryParse(requiredEmp) ?? 0,
          // 'ShiftCompanyBranchId':
          //     companyBranchId.isNotEmpty ? companyBranchId : '',
          'ShiftCurrentStatus': [],
          'ShiftCreatedAt': Timestamp.now(),
          'ShiftModifiedAt': Timestamp.now(),
          'ShiftLinkedPatrols': patrol,
          'ShiftPhotoUploadIntervalInMinutes':
              photoInterval != null ? int.tryParse(photoInterval) ?? 0 : 0,
          'ShiftRestrictedRadius': restrictedRadius != null
              ? int.tryParse(restrictedRadius) ?? 0
              : 0,
          'ShiftEnableRestrictedRadius': shiftenablerestriction,
          "ShiftGuardWellnessReport": [],
          'ShiftTask': []
        });

        // Prepare the shift tasks array with the document id
        List<Map<String, dynamic>> shiftTasks =
            tasks.asMap().entries.map((entry) {
          int index = entry.key;
          var task = entry.value;
          String randomString =
              getRandomString(2); // Generate 2 random characters
          return {
            'ShiftTask': task['name'],
            'ShiftTaskId':
                "${newDocRef.id}${randomString}${index}", // Assign the modified document id to each task
            'ShiftTaskQrCodeReq': task['ShiftTaskQrCodeReq'] ?? false,
            'ShiftTaskReturnReq': task['ShiftTaskReturnReq'] ?? false,
            'ShiftReturnTaskStatus': [],
            'ShiftTaskStatus': []
          };
        }).toList();

        // Update the document with the tasks
        await newDocRef.update({
          'ShiftId': newDocRef.id,
          'ShiftTask': FieldValue.arrayUnion(shiftTasks),
        });
      }
      print('Shifts created successfully');
      return '';
    } catch (e) {
      print('Error creating shifts: $e');
      return '';
    }
  }

  // Future<void> generateAndSendQrPdf(
  //     String taskId, String supervisorEmail) async {
  //   Uint8List qrCodeBytes = await generateQrCode(taskId);
  //   String base64QrCode = base64Encode(qrCodeBytes);
  //   await callPdfApi(base64QrCode, supervisorEmail);
  // }

  // Future<void> callPdfApi(String base64Image, String supervisorEmail) async {
  //   final url =
  //       Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf');

  //   final headers = {
  //     'Content-Type': 'application/json',
  //   };

  //   final htmlContent = '''
  //   <!DOCTYPE html>
  //   <html lang="en">
  //   <head>
  //     <meta charset="UTF-8">
  //     <meta name="viewport" content="width=device-width, initial-scale=1.0">
  //   </head>
  //   <body>
  //     <h1>TASK QR CODE!</h1>
  //     <img src="data:image/png;base64,$base64Image"/>
  //   </body>
  //   </html>
  // ''';

  //   final body = jsonEncode({
  //     'html': htmlContent,
  //     'file_name': 'TaskQR.pdf',
  //   });

  //   final response = await http.post(
  //     url,
  //     headers: headers,
  //     body: body,
  //   );

  //   if (response.statusCode == 200) {
  //     final pdfBase64 = base64Encode(response.bodyBytes);
  //     await sendEmail({
  //       'to_email': supervisorEmail,
  //       'subject': 'Task QR Code',
  //       'from_name': 'Company',
  //       'html': '',
  //       'pdfFile': pdfBase64,
  //     });
  //   } else {
  //     print(
  //         'Failed to call API: ${response.statusCode}, ${response.reasonPhrase}');
  //   }
  // }

  // Future<String> prepareHtmlContent(
  //     List<Map<String, dynamic>> shiftTasks) async {
  //   String htmlContent = """
  // <!DOCTYPE html>
  // <html>
  // <head>
  //   <title>Shift Tasks</title>
  // </head>
  // <body>
  //   <h1>Shift Tasks</h1>
  //   <table border="1">
  //     <tr>
  //       <th>Task Name</th>
  //       <th>QR Code</th>
  //     </tr>
  // """;

  //   for (var task in shiftTasks) {
  //     Uint8List qrCodeBytes = await generateQrCode(task['ShiftTaskId']);
  //     String base64QrCode = base64Encode(qrCodeBytes);

  //     htmlContent += """
  //     <tr>
  //       <td>${task['ShiftTask']}</td>
  //       <td><img src="data:image/png;base64,$base64QrCode" alt="QR Code"></td>
  //     </tr>
  //   """;
  //   }

  //   htmlContent += """
  //   </table>
  // </body>
  // </html>
  // """;

  //   return htmlContent;
  // }
  Future<void> generateAndSendQrPdf(
    List<Map<String, dynamic>> shiftTasks,
    String supervisorEmail,
  ) async {
    // Generate HTML content with all QR codes
    String htmlContent = await prepareHtmlContent(shiftTasks);

    // Call PDF API
    await callPdfApi(htmlContent, supervisorEmail);
  }

  Future<void> callPdfApi(String htmlContent, String supervisorEmail) async {
    final url =
        Uri.parse('https://backend-security-app.onrender.com/api/html_to_pdf');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'html': htmlContent,
      'file_name': 'TaskQR.pdf',
    });

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final pdfBase64 = base64Encode(response.bodyBytes);
      await sendEmailUsingApi("Qr Testing", "Vaibhav", pdfBase64);
    } else {
      print(
          'Failed to call API: ${response.statusCode}, ${response.reasonPhrase}');
    }
  }

  Future<String> prepareHtmlContent(
    List<Map<String, dynamic>> shiftTasks,
  ) async {
    String htmlContent = """
<!DOCTYPE html>
<html>
<head>
  <title>Shift Tasks</title>
</head>
<body>
  <h1>Shift Tasks</h1>
  <table border="1">
    <tr>
      <th>Task Name</th>
      <th>QR Code</th>
    </tr>
""";

    for (var task in shiftTasks) {
      Uint8List qrCodeBytes = await generateQrCode(task['ShiftTaskId']);
      String base64QrCode = base64Encode(qrCodeBytes);

      htmlContent += """
    <tr>
      <td>${task['ShiftTask']}</td>
      <td><img src="data:image/png;base64,$base64QrCode" alt="QR Code"></td>
    </tr>
  """;
    }

    htmlContent += """
  </table>
</body>
</html>
""";

    return htmlContent;
  }

  Future<Uint8List> generateQrCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    final qrCode = qrValidationResult.qrCode;
    final painter = QrPainter.withQr(
      qr: qrCode!,
      color: Color(0xFF000000),
      emptyColor: Color(0xFFFFFFFF),
      gapless: true,
    );
    final image = await painter.toImage(200);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> updateShift(
    String shiftId,
    List guards,
    String? role,
    String Address,
    String CompanyBranchId,
    String CompanyId,
    List<DateTime> Date,
    TimeOfDay? startTime,
    TimeOfDay? EndTime,
    List<Map<dynamic, dynamic>> patrol,
    String clientID,
    String requiredEmp,
    String photoInterval,
    String restrictedRadius,
    bool shiftenablerestriction,
    GeoPoint coordinates,
    String locationName,
    String locationId,
    String locationAddress,
    String branchId,
    String shiftDesc,
    String ShiftName,
    List<Map<String, dynamic>> tasks,
  ) async {
    try {
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

      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
      final DateFormat timeFormatter = DateFormat('HH:mm');

      // Get the shift document reference
      final shiftDocRef =
          FirebaseFirestore.instance.collection('Shifts').doc(shiftId);

      // Fetch the current shift data
      DocumentSnapshot shiftSnapshot = await shiftDocRef.get();
      if (!shiftSnapshot.exists) {
        print('Shift document does not exist');
        return;
      }
      Map<String, dynamic> shiftData =
          shiftSnapshot.data() as Map<String, dynamic>;

      // Get the current patrol data
      List<Map<dynamic, dynamic>> currentPatrol =
          shiftData['ShiftLinkedPatrolIds'] != null
              ? List<Map<dynamic, dynamic>>.from(
                  shiftData['ShiftLinkedPatrolIds'])
              : [];

      // Append new patrol data
      currentPatrol.addAll(patrol);
      final String? BranchId = await getBranchIdByName(CompanyBranchId);
      // Update the shift document
      Map<String, dynamic> updateData = {
        'ShiftName': ShiftName,
        'ShiftPosition': role ?? '',
        'ShiftStartTime': startTime != null
            ? timeFormatter.format(DateTime(
                Date.first.year,
                Date.first.month,
                Date.first.day,
                startTime.hour,
                startTime.minute,
              ))
            : '',
        'ShiftEndTime': EndTime != null
            ? timeFormatter.format(DateTime(
                Date.first.year,
                Date.first.month,
                Date.first.day,
                EndTime.hour,
                EndTime.minute,
              ))
            : '',
        'ShiftCompanyBranchId': BranchId != null ? BranchId : '',
        'ShiftDescription': shiftDesc,
        'ShiftLocationName': locationName,
        'ShiftLocationAddress': locationAddress,
        'ShiftLocationId': locationId,
        'ShiftLocation': coordinates,
        'ShiftAssignedUserId': selectedGuardIds,
        'ShiftClientId': clientID,
        'ShiftCompanyId': CompanyId,
        'ShiftRequiredEmp': requiredEmp.isNotEmpty ? int.parse(requiredEmp) : 0,
        'ShiftPhotoUploadIntervalInMinutes':
            photoInterval.isNotEmpty ? int.parse(photoInterval) : 0,
        'ShiftRestrictedRadius':
            restrictedRadius.isNotEmpty ? int.parse(restrictedRadius) : 0,
        'ShiftEnableRestrictedRadius': shiftenablerestriction,
        'ShiftModifiedAt': Timestamp.now(),
        'ShiftTask': tasks,
        'ShiftLinkedPatrols': patrol
      };

      // Filter out empty or null values
      updateData.removeWhere((key, value) => value == null || value == '');

      // Update the shift document
      await shiftDocRef.update(updateData);
//  return {
//             'ShiftTask': task['name'],
//             'ShiftTaskId':
//                 "${newDocRef.id}${randomString}${index}", // Assign the modified document id to each task
//             'ShiftTaskQrCodeReq': task['isQrRequired'] ?? false,
//             'ShiftTaskReturnReq': task['isReturnQrRequired'] ?? false,
//             'ShiftReturnTaskStatus': [],
//             'ShiftTaskStatus': []
//           };
      // Prepare the shift tasks array with the document id
      List<Map<String, dynamic>> shiftTasks = tasks.map((task) {
        return {
          'ShiftTask': task['ShiftTask'],
          'ShiftTaskId':
              task['ShiftTaskId'], // Assign the shift id to each task
          'ShiftTaskQrCodeReq': task['ShiftTaskQrCodeReq'] ?? false,
          'ShiftTaskReturnReq': task['ShiftTaskReturnReq'] ?? false,
          'ShiftTaskStatus': [],
          'ShiftReturnTaskStatus': []
        };
      }).toList();

      // Update the shift tasks
      await shiftDocRef.update({
        'ShiftTask': shiftTasks,
      });

      print('Shift updated successfully');
    } catch (e) {
      print('Error updating shift: $e');
      // Handle the error as needed
    }
  }

  // Future<int> getIntervalfromSettings(String CompanyId) async {
  //   CollectionReference settings =
  //       FirebaseFirestore.instance.collection('Settings');

  //   // Fetch the document for the specific patrol
  //   QuerySnapshot<Object?> snapshot =
  //       await settings.where("SettingCompanyId", isEqualTo: CompanyId).get();
  // }
  Future<int> getIntervalFromSettings(String companyId) async {
    CollectionReference settings =
        FirebaseFirestore.instance.collection('Settings');

    // Fetch the document for the specific company
    QuerySnapshot<Object?> snapshot =
        await settings.where("SettingCompanyId", isEqualTo: companyId).get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['SettingEmpShiftTimeMarginInMins'] ??
          10; // Default to 0 if not found
    } else {
      // Handle the case when no document is found
      return 10; // Default to 0 or throw an exception based on your requirements
    }
  }

  Future<bool> getuncheckedstatus(
      String PatrolId, String ShiftId, String EmpId) async {
    try {
      // Reference to the Firestore collection
      CollectionReference patrols =
          FirebaseFirestore.instance.collection('Patrols');

      // Fetch the document for the specific patrol
      DocumentSnapshot snapshot = await patrols.doc(PatrolId).get();

      // Check if the document exists
      if (snapshot.exists) {
        // Get the patrol checkpoints
        List<dynamic> checkpoints = snapshot.get('PatrolCheckPoints');

        // Iterate over the checkpoints to check their status
        for (var checkpoint in checkpoints) {
          List<dynamic> statuses = checkpoint['CheckPointStatus'];

          for (var status in statuses) {
            if (status['Status'] == 'unchecked' &&
                status['StatusShiftId'] == ShiftId &&
                status['StatusReportedById'] == EmpId) {
              return true;
            }
          }
        }
      }

      return false; // No unchecked status found for the given conditions
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  //Get all the Schedules for Guards
  Future<String?> getBranchNameById2(String branchId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('CompanyBranch')
              .where('CompanyBranchId', isEqualTo: branchId)
              .limit(1) // Assuming there's only one matching document
              .get();

      if (snapshot.docs.isNotEmpty) {
        final String branchName =
            snapshot.docs.first.data()['CompanyBranchName'] as String;
        print("Branch name: $branchName");
        return branchName;
      } else {
        print("No branch found for the given CompanyId.");
        return null;
      }
    } catch (e) {
      print("Error fetching branch name: $e");
      return null; // Return null in case of error
    }
  }

  Future<String?> getBranchIdByName(String branchName) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('CompanyBranch')
              .where('CompanyBranchName', isEqualTo: branchName)
              .limit(1) // Assuming there's only one matching document
              .get();

      if (snapshot.docs.isNotEmpty) {
        final String branchId =
            snapshot.docs.first.data()['CompanyBranchId'] as String;
        print("Branch ID: $branchId");
        return branchId;
      } else {
        print("No branch found for the given branch name.");
        return null;
      }
    } catch (e) {
      print("Error fetching branch ID: $e");
      return null; // Return null in case of error
    }
  }

  Future<List<DocumentSnapshot>> getAllSchedules(String empId) async {
    if (empId.isEmpty) {
      return [];
    }
    DateTime now = DateTime.now();

    DateTime startDate = DateTime(now.year, now.month, now.day);
    DateTime endDate = startDate.add(Duration(days: 7));

    final querySnapshot = await shifts
        .where("ShiftAssignedUserId", arrayContains: empId)
        .where("ShiftDate", isGreaterThanOrEqualTo: startDate)
        .where("ShiftDate", isLessThan: endDate)
        .orderBy("ShiftDate", descending: false)
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
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

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

  Future<List<Map<String, dynamic>>> addImageToReportStorage(File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      Reference uploadRef =
          storageRef.child("employees/report/$uniqueName.jpg");

      // Set metadata with the content type
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      // Upload the already compressed image to Firebase Storage with metadata
      await uploadRef.putFile(file, metadata);

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

  Future<List<Map<String, dynamic>>> addVideoToReportStorage(File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      Reference uploadRef =
          storageRef.child("employees/report/$uniqueName.mp4");

      // Set metadata with the content type
      SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');

      // Upload the video to Firebase Storage with metadata
      await uploadRef.putFile(file, metadata);

      // Get the download URL of the uploaded video
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
  //Upload files to storage for report
  // Future<List<Map<String, dynamic>>> addToReportStorage(File file) async {
  //   try {
  //     String uniqueName = DateTime.now().toString();
  //     Reference storageRef = FirebaseStorage.instance.ref();

  //     Reference uploadRef =
  //         storageRef.child("employees/report/$uniqueName.jpg");
  //     // Compress the image
  //     Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
  //       file.absolute.path,
  //       quality: 50, // Adjust the quality as needed
  //     );

  //     // Upload the compressed image to Firebase Storage
  //     await uploadRef.putData(Uint8List.fromList(compressedImage!));

  //     // Get the download URL of the uploaded image
  //     String downloadURL = await uploadRef.getDownloadURL();
  //     print("Download URL: $downloadURL");

  //     // Return the download URL in a list
  //     return [
  //       {'downloadURL': downloadURL}
  //     ];
  //   } catch (e) {
  //     print(e);
  //     throw e;
  //   }
  // }

  Future<String> uploadFileToReportStorage(File file, String path) async {
    try {
      TaskSnapshot snapshot =
          await FirebaseStorage.instance.ref(path).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading file: $e");
      return "";
    }
  }
//   Future<void> uploadFiles() async {
//   for (var upload in uploads) {
//     String type = upload['type'];
//     String filePath = upload['file'];

//     File file = File(filePath);
//     String fileName = file.path.split('/').last;

//     firebase_storage.Reference ref =
//         firebase_storage.FirebaseStorage.instance.ref('employee/report/$fileName');

//     try {
//       await ref.putFile(file);
//       String downloadURL = await ref.getDownloadURL();

//       // Store the downloadURL in Firestore or use it as needed
//     } catch (e) {
//       print('Error uploading $type: $e');
//     }
//   }
// }

  //Dar images
  Future<String> addImageToDarStorage(File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      Reference uploadRef = storageRef.child("employees/Dar/$uniqueName.jpg");
      // Compress the image
      // Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      //   file.absolute.path,
      //   quality: 50, // Adjust the quality as needed
      // );

      // Upload the compressed image to Firebase Storage
      // await uploadRef.putData(Uint8List.fromList(compressedImage!));

      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      // Upload the already compressed image to Firebase Storage with metadata
      await uploadRef.putFile(file, metadata);

      // Get the download URL of the uploaded image
      String downloadURL = await uploadRef.getDownloadURL();
      print("Download URL: $downloadURL");

      // Return the download URL in a list
      return downloadURL;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  //add wellness to the collection
  Future<void> addImagesToShiftGuardWellnessReport(
      List<Map<String, dynamic>> uploads,
      String comment,
      String EmpId,
      String EmpName) async {
    try {
      final LocalStorage storage = LocalStorage('ShiftDetails');
      String shiftId = storage.getItem('shiftId');
      String empId = storage.getItem('EmpId') ?? "";
      final querySnapshot =
          await shifts.where("ShiftId", isEqualTo: shiftId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        List<Map<String, dynamic>> wellnessReports =
            List.from(doc["ShiftGuardWellnessReport"]);
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

        wellnessReports.add({
          "WellnessEmpId": EmpId,
          "WellnessEmpName": EmpName,
          "WellnessReportedAt": DateTime.now(),
          "WellnessComment": comment,
          "WellnessImg": imgUrls,
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

  // Future<void> addImagesToShiftPhotoReport(List<Map<String, dynamic>> uploads,
  //     String comment, String EmpId, String EmpName) async {
  //   try {
  //     final LocalStorage storage = LocalStorage('ShiftDetails');
  //     String shiftId = storage.getItem('shiftId');
  //     String empId = storage.getItem('EmpId') ?? "";
  //     final querySnapshot =
  //         await shifts.where("ShiftId", isEqualTo: shiftId).get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       final doc = querySnapshot.docs.first;

  //       List<Map<String, dynamic>> wellnessReports =
  //           List.from(doc["ShiftPhotoUploadReport"]);
  //       List<String> imgUrls = [];
  //       for (var upload in uploads) {
  //         if (upload['type'] == 'image') {
  //           File file = upload['file'];
  //           print(file);
  //           // Upload the image file and get the download URL
  //           List<Map<String, dynamic>> downloadURLs =
  //               await addImageToStorageShiftPhotoTask(file);
  //           // Add the image URLs to the list
  //           for (var urlMap in downloadURLs) {
  //             if (urlMap.containsKey('downloadURL')) {
  //               imgUrls.add(urlMap['downloadURL'] as String);
  //             }
  //           }
  //         }
  //       }

  //       wellnessReports.add({
  //         "ShiftPhotoUploadEmpId": EmpId,
  //         "ShiftPhotoUploadEmpName": EmpName,
  //         "ShiftPhotoUploadReportedAt": DateTime.now(),
  //         // "WellnessComment": comment,
  //         "ShiftPhotoUploadImg": imgUrls,
  //       });

  //       // Update the Firestore document with the new wellness reports
  //       await doc.reference.update({
  //         "ShiftPhotoUploadReport": wellnessReports,
  //       });
  //     } else {
  //       print("No document found with shiftId: $shiftId");
  //     }
  //   } catch (e) {
  //     print('Error adding images to ShiftGuardWellnessReport: $e');
  //     throw e;
  //   }
  // }
  Future<void> addImagesToShiftPhotoReport(List<Map<String, dynamic>> uploads,
      String comment, String EmpId, String EmpName) async {
    try {
      final LocalStorage storage = LocalStorage('ShiftDetails');
      String shiftId = storage.getItem('shiftId');
      String empId = storage.getItem('EmpId') ?? "";
      final querySnapshot =
          await shifts.where("ShiftId", isEqualTo: shiftId).get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final docData = doc.data() as Map<String, dynamic>;

        // Initialize the 'ShiftPhotoUploadReport' field if it doesn't exist
        List<Map<String, dynamic>> shiftPhotoUploadReport = [];
        if (docData.containsKey('ShiftPhotoUploadReport')) {
          shiftPhotoUploadReport = List<Map<String, dynamic>>.from(
              docData['ShiftPhotoUploadReport']);
        }

        List<String> imgUrls = [];
        for (var upload in uploads) {
          if (upload['type'] == 'image') {
            File file = upload['file'];
            print(file);
            // Upload the image file and get the download URL
            List<Map<String, dynamic>> downloadURLs =
                await addImageToStorageShiftPhotoTask(file);
            // Add the image URLs to the list
            for (var urlMap in downloadURLs) {
              if (urlMap.containsKey('downloadURL')) {
                imgUrls.add(urlMap['downloadURL'] as String);
              }
            }
          }
        }

        shiftPhotoUploadReport.add({
          "ShiftPhotoUploadEmpId": EmpId,
          "ShiftPhotoUploadEmpName": EmpName,
          "ShiftPhotoUploadReportedAt": DateTime.now(),
          "ShiftPhotoUploadImg": imgUrls,
        });

        // Update the Firestore document with the new shift photo upload report
        await doc.reference.update({
          "ShiftPhotoUploadReport": shiftPhotoUploadReport,
        });
      } else {
        print("No document found with shiftId: $shiftId");
      }
    } catch (e) {
      print('Error adding images to ShiftPhotoUploadReport: $e');
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

  Future<bool?> checkShiftReturnTaskStatus2(
      String empId, String shiftID) async {
    try {
      final documentSnapshot = await FirebaseFirestore.instance
          .collection("Shifts")
          .doc(shiftID)
          .get();

      if (documentSnapshot.exists) {
        print('Shift Task exists');
        final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
        print("Shiftask Status ${shiftTasks}");
        if (shiftTasks.isNotEmpty) {
          print("Shift Task is not empty");
          for (var shiftTask in shiftTasks) {
            // Check if ShiftReturnTaskStatus exists before accessing it
            if (shiftTask.containsKey('ShiftReturnTaskStatus') &&
                shiftTask['ShiftTaskReturnReq'] == true) {
              final taskStatusList =
                  shiftTask['ShiftReturnTaskStatus'] as List<dynamic>;
              if (taskStatusList == null || taskStatusList.isEmpty) {
                print("ReturnTsk: 0");
                // return true;
              }
              if (taskStatusList.isNotEmpty) {
                print("ShiftTaskStatus is not empty");
                for (var shiftTaskStatus in taskStatusList) {
                  if (shiftTaskStatus['TaskCompletedById'] == empId &&
                      shiftTask['ShiftTaskReturnReq'] == true &&
                      (shiftTaskStatus['TaskStatus'] == "pending" &&
                              shiftTask['ShiftTaskReturnReq'] == true ||
                          shiftTaskStatus['TaskStatus'] == null)) {
                    print("ReturnTsk: 1");
                    return false; // If any task matches the condition, return false
                  }
                }
              } else {
                print("ReturnTsk: 2");
                return false; // If ShiftReturnTaskStatus is empty, return false
              }
            } else {
              print("ReturnTsk: 3");
              // If ShiftReturnTaskStatus doesn't exist, return false
              return true;
            }
          }
        } else {
          return true; // If ShiftTask is empty, return true
        }
      } else {
        print("ReturnTsk: 4");
        return true; // If document doesn't exist, return false
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

  Future<String?> fetchPatrolId(String patrolName) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .where('PatrolName', isEqualTo: patrolName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot
            .docs.first.id; // Assuming PatrolId is the document ID
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching PatrolId: $e');
      return null;
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

  // Future<List<Map<String, dynamic>>?> fetchShiftReturnTask2(
  //     String shiftID) async {
  //   try {
  //     final documentSnapshot = await FirebaseFirestore.instance
  //         .collection("Shifts")
  //         .doc(shiftID)
  //         .get();

  //     if (documentSnapshot.exists) {
  //       final shiftTasks = documentSnapshot['ShiftTask'] as List<dynamic>;
  //       if (shiftTasks.isNotEmpty) {
  //         return List<Map<String, dynamic>>.from(shiftTasks);
  //       }
  //     }
  //     return null; // Return null if no tasks or document doesn't exist
  //   } catch (e) {
  //     print("Error fetching shift tasks: $e");
  //     return null; // Return null in case of error
  //   }
  // }

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

  Future<Map<String, dynamic>> fetchreturnShiftTasks2(String shiftID) async {
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
            final taskStatus = task['ShiftReturnTaskStatus'] as List<dynamic>;
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

  // Future<List<Map<String, dynamic>>> addImageToStorageShiftTask(
  //     File file) async {
  //   try {
  //     String uniqueName = DateTime.now().toString();
  //     Reference storageRef = FirebaseStorage.instance.ref();

  //     Reference uploadRef =
  //         storageRef.child("employees/shifttask/$uniqueName.jpg");

  //     await uploadRef.putFile(
  //       file,
  //     );

  //     // Get the download URL of the uploaded image
  //     String downloadURL = await uploadRef.getDownloadURL();

  //     // Return the download URL in a list
  //     print({'downloadURL': downloadURL});
  //     return [
  //       {'downloadURL': downloadURL}
  //     ];
  //   } catch (e) {
  //     print(e);
  //     throw e;
  //   }
  // }

  // //add wellness to the collection
  // Future<void> addImagesToShiftTasks(
  //     List<Map<String, dynamic>> uploads,
  //     String ShiftTaskId,
  //     String ShiftId,
  //     String EmpId,
  //     String EmpName,
  //     bool shiftTaskReturnStatus) async {
  //   try {
  //     print("Uploads from Firebase: $uploads");
  //     print("Shift Task ID from Firebase: $ShiftTaskId");

  //     if (ShiftId.isEmpty) {
  //       print("Shift ID is empty");
  //       return;
  //     }

  //     final DocumentReference shiftDocRef =
  //         FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
  //     final DocumentSnapshot shiftDoc = await shiftDocRef.get();

  //     if (!shiftDoc.exists) {
  //       print("Shift document not found");
  //       return;
  //     }

  //     List<dynamic> shiftTasks = shiftDoc['ShiftTask'];
  //     print("Shift Doc exists with ${shiftTasks.length} tasks");

  //     for (int i = 0; i < shiftTasks.length; i++) {
  //       if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
  //         print("Processing ShiftTaskId: $ShiftTaskId");
  //         List<String> imgUrls = [];

  //         for (var upload in uploads) {
  //           if (upload['type'] == 'image') {
  //             File file = upload['file'];
  //             print("Uploading file: $file");

  //             // Upload the image file and get the download URL
  //             List<Map<String, dynamic>> downloadURLs =
  //                 await addImageToStorageShiftTask(file);

  //             // Add the image URLs to the list
  //             for (var urlMap in downloadURLs) {
  //               if (urlMap.containsKey('downloadURL')) {
  //                 imgUrls.add(urlMap['downloadURL'] as String);
  //               }
  //             }
  //           }
  //         }

  //         // Create ShiftTaskStatus object with image URLs
  //         Map<String, dynamic> shiftTaskStatus = {
  //           "TaskStatus": "completed",
  //           "TaskCompletedById": EmpId,
  //           "TaskCompletedByName": EmpName,
  //           "TaskCompletionTime": DateTime.now(),
  //           "TaskPhotos": imgUrls,
  //         };

  //         if (shiftTaskReturnStatus) {
  //           shiftTaskStatus["ShiftTaskReturnStatus"] = true;
  //         }

  //         // Update the ShiftTaskStatus array with the new object
  //         shiftTasks[i]['ShiftTaskStatus'] = [shiftTaskStatus];

  //         // Update the Firestore document with the new ShiftTaskStatus
  //         await shiftDocRef.update({'ShiftTask': shiftTasks});
  //         print("ShiftTask updated successfully");
  //         break; // Exit loop after updating
  //       }
  //     }
  //   } catch (e) {
  //     print('Error adding images to ShiftTaskPhotos: $e');
  //     throw e;
  //   }
  // }

  // Future<void> addImagesToShiftReturnTasks(
  //     List<Map<String, dynamic>> uploads,
  //     String ShiftTaskId,
  //     String ShiftId,
  //     String EmpId,
  //     String EmpName,
  //     bool shiftTaskReturnStatus) async {
  //   try {
  //     print("Uploads from FIrebase: $uploads");
  //     print("Shift Task ID from FIrebase: $ShiftTaskId");

  //     if (ShiftId.isEmpty) {
  //       print("Shift ID from FIrebase: $ShiftId");
  //     } else {
  //       print("Shift ID is empty");
  //     }

  //     // String empId = storage.getItem('EmpId') ?? "";
  //     if (ShiftId.isEmpty) {
  //       print("LocalStorage shiftId is null or empty");
  //     }
  //     final DocumentReference shiftDocRef =
  //         FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
  //     final DocumentSnapshot shiftDoc = await shiftDocRef.get();
  //     print(DocumentSnapshot);
  //     if (shiftDoc.exists) {
  //       List<dynamic> shiftTasks = shiftDoc['ShiftTask'];
  //       print("Shift Doc exists");
  //       print(shiftTasks.length);
  //       for (int i = 0; i < shiftTasks.length; i++) {
  //         print("Success: $ShiftTaskId");
  //         List<String> imgUrls = [];
  //         for (var upload in uploads) {
  //           if (upload['type'] == 'image') {
  //             File file = upload['file'];
  //             print(file);
  //             // Upload the image file and get the download URL
  //             List<Map<String, dynamic>> downloadURLs =
  //                 await addImageToStorageShiftTask(file);
  //             // Add the image URLs to the list
  //             for (var urlMap in downloadURLs) {
  //               if (urlMap.containsKey('downloadURL')) {
  //                 imgUrls.add(urlMap['downloadURL'] as String);
  //               }
  //             }
  //           }
  //         }

  //         if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
  //           // Create ShiftTaskStatus object with image URLs
  //           Map<String, dynamic> shiftTaskStatus = {
  //             "TaskStatus": "completed",
  //             "TaskCompletedById": EmpId ?? "",
  //             "TaskCompletedByName": EmpName,
  //             "TaskCompletionTime": DateTime.now(),
  //             "TaskPhotos": imgUrls,
  //             // "ShiftTaskReturnStatus": true,
  //           };
  //           if (shiftTaskReturnStatus) {
  //             // shiftTaskStatus["ShiftTaskReturnStatus"] = true;
  //             shiftTasks[i]['ShiftReturnTaskStatus'] = [shiftTaskStatus];
  //           }
  //           // Update the ShiftTaskStatus array with the new object
  //           shiftTasks[i]['ShiftReturnTaskStatus'] = [shiftTaskStatus];

  //           // Update the Firestore document with the new ShiftTaskStatus
  //           await shiftDocRef.update({'ShiftTask': shiftTasks});
  //           break; // Exit loop after updating
  //         }
  //       }
  //     } else {
  //       print("Shift document not found");
  //     }
  //   } catch (e) {
  //     print('Error adding images to ShiftTaskPhotos: $e');
  //     throw e;
  //   }
  // }
  Future<List<Map<String, dynamic>>> addImageToStorageShiftTask(
      File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();
      Reference uploadRef =
          storageRef.child("employees/shifttask/$uniqueName.jpg");

      await uploadRef.putFile(file);

      // Get the download URL of the uploaded image
      String downloadURL = await uploadRef.getDownloadURL();
      return [
        {'downloadURL': downloadURL}
      ];
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> addImageToStorageShiftPhotoTask(
      File file) async {
    try {
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();
      Reference uploadRef =
          storageRef.child("employees/shiftphoto/$uniqueName.jpg");

      await uploadRef.putFile(file);

      // Get the download URL of the uploaded image
      String downloadURL = await uploadRef.getDownloadURL();
      return [
        {'downloadURL': downloadURL}
      ];
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<void> addImagesToShiftTasks(
      List<Map<String, dynamic>> uploads,
      String ShiftTaskId,
      String ShiftId,
      String EmpId,
      String EmpName,
      bool shiftTaskReturnStatus,
      String comment) async {
    try {
      if (ShiftId.isEmpty) {
        print("Shift ID is empty");
        return;
      }

      final DocumentReference shiftDocRef =
          FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
      final DocumentSnapshot shiftDoc = await shiftDocRef.get();

      if (!shiftDoc.exists) {
        print("Shift document not found");
        return;
      }

      List<dynamic> shiftTasks = shiftDoc['ShiftTask'];

      List<String> imgUrls = [];
      List<Future<void>> uploadFutures = [];

      for (var upload in uploads) {
        if (upload['type'] == 'image') {
          File file = upload['file'];
          uploadFutures
              .add(addImageToStorageShiftTask(file).then((downloadURLs) {
            for (var urlMap in downloadURLs) {
              if (urlMap.containsKey('downloadURL')) {
                imgUrls.add(urlMap['downloadURL'] as String);
              }
            }
          }));
        }
      }

      await Future.wait(uploadFutures);

      for (int i = 0; i < shiftTasks.length; i++) {
        if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
          Map<String, dynamic> shiftTaskStatus = {
            "TaskStatus": "completed",
            "TaskCompletedById": EmpId,
            "TaskCompletedByName": EmpName,
            "TaskCompletionTime": DateTime.now(),
            "TaskPhotos": imgUrls,
            "TaskComment": comment
          };

          if (shiftTaskReturnStatus) {
            shiftTaskStatus["ShiftTaskReturnStatus"] = true;
          }

          shiftTasks[i]['ShiftTaskStatus'] = [shiftTaskStatus];
          break; // Exit loop after updating
        }
      }

      await shiftDocRef.update({'ShiftTask': shiftTasks});
      print("ShiftTask updated successfully");
    } catch (e) {
      print('Error adding images to ShiftTaskPhotos: $e');
      throw e;
    }
  }

  Future<void> addImagesToShiftReturnTasks(
      List<Map<String, dynamic>> uploads,
      String ShiftTaskId,
      String ShiftId,
      String EmpId,
      String EmpName,
      bool shiftTaskReturnStatus,
      String comment) async {
    try {
      if (ShiftId.isEmpty) {
        print("Shift ID is empty");
        return;
      }

      final DocumentReference shiftDocRef =
          FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
      final DocumentSnapshot shiftDoc = await shiftDocRef.get();

      if (!shiftDoc.exists) {
        print("Shift document not found");
        return;
      }

      List<dynamic> shiftTasks = shiftDoc['ShiftTask'];

      List<String> imgUrls = [];
      List<Future<void>> uploadFutures = [];

      for (var upload in uploads) {
        if (upload['type'] == 'image') {
          File file = upload['file'];
          uploadFutures
              .add(addImageToStorageShiftTask(file).then((downloadURLs) {
            for (var urlMap in downloadURLs) {
              if (urlMap.containsKey('downloadURL')) {
                imgUrls.add(urlMap['downloadURL'] as String);
              }
            }
          }));
        }
      }

      await Future.wait(uploadFutures);

      for (int i = 0; i < shiftTasks.length; i++) {
        if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
          Map<String, dynamic> shiftTaskStatus = {
            "TaskStatus": "completed",
            "TaskCompletedById": EmpId ?? "",
            "TaskCompletedByName": EmpName,
            "TaskCompletionTime": DateTime.now(),
            "TaskPhotos": imgUrls,
            "TaskComment": comment
          };

          if (shiftTaskReturnStatus) {
            shiftTasks[i]['ShiftReturnTaskStatus'] = [shiftTaskStatus];
          } else {
            shiftTasks[i]['ShiftReturnTaskStatus'] = [shiftTaskStatus];
          }

          break; // Exit loop after updating
        }
      }

      await shiftDocRef.update({'ShiftTask': shiftTasks});
    } catch (e) {
      print('Error adding images to ShiftReturnTaskPhotos: $e');
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
      await uploadRef.putFile(file);

      // Get the download URL of the uploaded image
      // Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      //   file.absolute.path,
      //   quality: 50, // Adjust the quality as needed
      // );

      // Upload the compressed image to Firebase Storage
      // await uploadRef.putData(Uint8List.fromList(compressedImage!));
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

  //add pdf to firebase storage
  String randomAlphaNumeric(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<String> uploadFileToStorage(Uint8List fileBytes) async {
    try {
      // Generate a unique filename
      String uniqueFilename =
          'shift_report_${DateTime.now().millisecondsSinceEpoch}_${randomAlphaNumeric(5)}.pdf';

      // Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/$uniqueFilename';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(fileBytes);

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref =
          storage.ref().child("employees/ShiftReport/$uniqueFilename");
      UploadTask uploadTask = ref.putFile(tempFile);

      await uploadTask;
      String downloadURL = await ref.getDownloadURL();

      // Delete the temporary file
      await tempFile.delete();

      return downloadURL;
    } catch (e) {
      print('Failed to upload file: $e');
      return "";
    }
  }

  //Add report pdf to storage
  Future<String> uploadPdfToStorage(File file, String ShiftId) async {
    try {
      // Generate a unique name for the document
      String uniqueName = DateTime.now().toString();
      Reference storageRef = FirebaseStorage.instance.ref();

      // Determine the file extension (e.g., pdf, docx, txt)
      String extension = file.path.split('.').last;
      String compressedFileName = '$ShiftId.$extension';

      // Compress the document (adjust the quality as needed)
      Uint8List? compressedDocument =
          await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: 50, // Adjust the quality as needed
      );

      // Upload the compressed document to Firebase Storage
      Reference uploadRef =
          storageRef.child("employees/ShiftReport/$compressedFileName");
      await uploadRef.putData(Uint8List.fromList(compressedDocument!));

      // Get the download URL of the uploaded document
      String downloadURL = await uploadRef.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  bool isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
    DateTime dateTime1 = timestamp1.toDate();
    DateTime dateTime2 = timestamp2.toDate();
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  // Add images and comment
  // Future<void> addImagesToPatrol(
  //     List<Map<String, dynamic>> uploads,
  //     String comment,
  //     String patrolID,
  //     String empId,
  //     String patrolCheckPointId,
  //     String ShiftId) async {
  //   try {
  //     final querySnapshot = await patrols.doc(patrolID).get();

  //     if (querySnapshot.exists) {
  //       final doc = querySnapshot.data() as Map<String, dynamic>;

  //       List<Map<String, dynamic>> wellnessReports =
  //           List.from(doc["PatrolReport"] ?? []);

  //       // Check if PatrolCheckPoints is null or not properly initialized
  //       List<dynamic> patrolCheckPoints = doc["PatrolCheckPoints"] ?? [];

  //       // Find the specific CheckPoint within PatrolCheckPoints
  //       var checkPoint = patrolCheckPoints.firstWhere(
  //         (cp) => cp["CheckPointId"] == patrolCheckPointId,
  //         orElse: () => null,
  //       );

  //       if (checkPoint != null) {
  //         // Ensure that CheckPointStatus is correctly initialized and cast to List<dynamic>
  //         List<dynamic> checkPointStatus = checkPoint["CheckPointStatus"] ?? [];

  //         // Find the specific status within CheckPointStatus where StatusReportedById matches empId
  //         var status = checkPointStatus.firstWhere(
  //           (s) =>
  //               s["StatusReportedById"] == empId &&
  //               // isSameDay(s["StatusReportedTime"], Timestamp.now()
  //               s["StatusShiftId"] == ShiftId

  //           // )
  //           ,
  //           orElse: () => null,
  //         );

  //         if (status == null) {
  //           // Create a new status entry for the empId
  //           status = {
  //             "StatusReportedById": empId,
  //             "StatusImage": [],
  //             "StatusComment": "",
  //             "StatusReportedTime": Timestamp.now(),
  //             "StatusShiftId": ShiftId
  //           };
  //           checkPointStatus.add(status);
  //         }

  //         List<Map<String, dynamic>> imgUrls = [];
  //         for (var upload in uploads) {
  //           if (upload['type'] == 'image') {
  //             File file = upload['file'];

  //             // Upload the image file and get the download URL
  //             List<Map<String, dynamic>> downloadURL =
  //                 await addImageToStoragePatrol(file);

  //             // Add the download URLs to the imgUrls list
  //             for (var url in downloadURL) {
  //               imgUrls.add(url);
  //             }
  //           }
  //         }

  //         // Add the new image and comment map to the status
  //         status["StatusImage"] =
  //             imgUrls.map((url) => url['downloadURL']).toList();
  //         status["StatusComment"] = comment;
  //         status["StatusReportedTime"] = Timestamp.now();

  //         // Update the Firestore document with the new wellness reports
  //         await patrols.doc(patrolID).update({
  //           "PatrolReport": wellnessReports,
  //           "PatrolCheckPoints": patrolCheckPoints,
  //         });
  //       } else {
  //         print("No CheckPoint found with CheckPointId: $patrolCheckPointId");
  //       }
  //     } else {
  //       print("No document found with PatrolID: $patrolID");
  //     }
  //   } catch (e) {
  //     print('Error adding images to PatrolReport: $e');
  //     throw e;
  //   }
  // }
  Future<void> addImagesToPatrol(
    List<Map<String, dynamic>> uploads,
    String comment,
    String patrolID,
    String empId,
    String patrolCheckPointId,
    String shiftId,
    List<String> prevImages,
  ) async {
    try {
      final querySnapshot = await patrols.doc(patrolID).get();

      if (querySnapshot.exists) {
        final doc = querySnapshot.data() as Map<String, dynamic>;

        List<Map<String, dynamic>> wellnessReports =
            List.from(doc["PatrolReport"] ?? []);

        // Check if PatrolCheckPoints is null or not properly initialized
        List<dynamic> patrolCheckPoints = doc["PatrolCheckPoints"] ?? [];

        // Find the specific CheckPoint within PatrolCheckPoints
        var checkPoint = patrolCheckPoints.firstWhere(
          (cp) => cp["CheckPointId"] == patrolCheckPointId,
          orElse: () => null,
        );

        if (checkPoint != null) {
          // Ensure that CheckPointStatus is correctly initialized and cast to List<dynamic>
          List<dynamic> checkPointStatus = checkPoint["CheckPointStatus"] ?? [];

          // Find the specific status within CheckPointStatus where StatusReportedById matches empId
          var status = checkPointStatus.firstWhere(
            (s) =>
                s["StatusReportedById"] == empId &&
                s["StatusShiftId"] == shiftId,
            orElse: () => null,
          );

          if (status == null) {
            // Create a new status entry for the empId
            status = {
              "StatusReportedById": empId,
              "StatusImage": [],
              "StatusComment": "",
              "StatusReportedTime": Timestamp.now(),
              "StatusShiftId": shiftId
            };
            checkPointStatus.add(status);
          }

          // Get the existing images
          List<dynamic> existingImages = status["StatusImage"] ?? [];

          // Add the new images
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

          // Combine existing images with new images
          List<String> allImages = [
            ...prevImages,
            ...imgUrls.map((url) => url['downloadURL'])
          ];

          // Update the status with the combined images and new comment
          status["StatusImage"] = allImages;
          status["StatusComment"] = comment;
          status["StatusReportedTime"] = Timestamp.now();

          // Update the Firestore document with the new wellness reports
          await patrols.doc(patrolID).update({
            "PatrolReport": wellnessReports,
            "PatrolCheckPoints": patrolCheckPoints,
          });
        } else {
          print("No CheckPoint found with CheckPointId: $patrolCheckPointId");
        }
      } else {
        print("No document found with PatrolID: $patrolID");
      }
    } catch (e) {
      print('Error adding images to PatrolReport: $e');
      throw e;
    }
  }

  Future<void> addFailureReasonToPatrol(
    Map<String, String> checkpointReasons,
    String patrolID,
    String empId,
    String ShiftId,
  ) async {
    try {
      final querySnapshot = await patrols.doc(patrolID).get();

      if (querySnapshot.exists) {
        final doc = querySnapshot.data() as Map<String, dynamic>;

        // Check if PatrolCheckPoints is null or not properly initialized
        List<dynamic> patrolCheckPoints = doc["PatrolCheckPoints"] ?? [];

        // Update the failure reason for each checkpoint
        checkpointReasons.forEach((checkpointId, reason) {
          // Find the specific CheckPoint within PatrolCheckPoints
          var checkPoint = patrolCheckPoints.firstWhere(
            (cp) => cp["CheckPointId"] == checkpointId,
            orElse: () => null,
          );

          if (checkPoint != null) {
            // Ensure that CheckPointStatus is correctly initialized and cast to List<dynamic>
            List<dynamic> checkPointStatus =
                checkPoint["CheckPointStatus"] ?? [];

            // Find the specific status within CheckPointStatus where StatusReportedById matches empId
            var status = checkPointStatus.firstWhere(
              (s) =>
                  s["StatusReportedById"] == empId &&
                  s["StatusShiftId"] == ShiftId,
              orElse: () => null,
            );

            if (status != null) {
              // Update or replace the failure reason
              status["StatusFailureReason"] = reason;
            } else {
              print(
                  "No Status found for CheckPointId: $checkpointId and EmpId: $empId");
            }
          } else {
            print("No CheckPoint found with CheckPointId: $checkpointId");
          }
        });

        // Update the Firestore document with the new failure reasons
        await patrols.doc(patrolID).update({
          "PatrolCheckPoints": patrolCheckPoints,
        });
      } else {
        print("No document found with PatrolID: $patrolID");
      }
    } catch (e) {
      print('Error adding failure reasons to PatrolCheckPoints: $e');
      throw e;
    }
  }

  Future<bool> checkLocationAndAddEmail(String locationId) async {
    try {
      // Get the document from the Locations collection
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(locationId)
          .get();

      if (docSnapshot.exists) {
        // Check if LocationSendEmailForEachPatrol is true
        bool sendEmailForEachPatrol =
            docSnapshot.get('LocationSendEmailForEachPatrol');
        // if (sendEmailForEachPatrol) {
        //   // Get the client's email
        //   String clientEmail = docSnapshot.get('LocationManagerEmail');
        //   // Add the client's email to the list
        //   emailList.add(clientEmail);
        // }
        return sendEmailForEachPatrol;
      } else {
        // Document does not exist
        return false;
      }
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }

  Future<bool> ReturnLocationManagerAddEmail(String locationId) async {
    try {
      // Get the document from the Locations collection
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(locationId)
          .get();

      if (docSnapshot.exists) {
        // Check if LocationSendEmailForEachPatrol is true
        bool sendEmailForEachPatrol =
            docSnapshot.get('LocationSendEmailForEachPatrol');
        // if (sendEmailForEachPatrol) {
        //   // Get the client's email
        //   String clientEmail = docSnapshot.get('LocationManagerEmail');
        //   // Add the client's email to the list
        //   emailList.add(clientEmail);
        // }
        return sendEmailForEachPatrol;
      } else {
        // Document does not exist
        return false;
      }
    } catch (e) {
      print('Error checking location: $e');
      return false;
    }
  }

  Future<String?> getLocationManagerEmail(String locationId) async {
    try {
      // Get the document from the Locations collection
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(locationId)
          .get();

      if (docSnapshot.exists) {
        // Get the LocationManagerEmail
        String managerEmail = docSnapshot.get('LocationManagerEmail');
        return managerEmail;
      } else {
        // Document does not exist
        return null;
      }
    } catch (e) {
      print('Error getting location manager email: $e');
      return null;
    }
  }

  Future<bool> shouldSendEmailToClient(String locationId) async {
    try {
      // Get the document from the Locations collection
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .doc(locationId)
          .get();

      if (docSnapshot.exists) {
        // Check if LocationSendEmailToClient is true
        bool sendEmailToClient = docSnapshot.get('LocationSendEmailToClient');
        return sendEmailToClient;
      } else {
        // Document does not exist
        return false;
      }
    } catch (e) {
      print('Error checking send email to client: $e');
      return false;
    }
  }

  //Update the shift status when the qr is scanned correctly
  Future<void> updateShiftTaskStatus(
      String ShiftTaskId, String EmpID, String ShiftId, String EmpName) async {
    try {
      final DocumentReference shiftDocRef =
          FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
      final DocumentSnapshot shiftDoc = await shiftDocRef.get();

      if (shiftDoc.exists) {
        List<dynamic> shiftTasks = shiftDoc['ShiftTask'];

        for (int i = 0; i < shiftTasks.length; i++) {
          if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
            // Check if ShiftTaskStatus array is empty or null
            if (shiftTasks[i]['ShiftTaskStatus'] == null ||
                shiftTasks[i]['ShiftTaskStatus'].isEmpty) {
              shiftTasks[i]['ShiftTaskStatus'] = [];
            }

            // Create ShiftTaskStatus object without images
            Map<String, dynamic> shiftTaskStatus = {
              "TaskStatus": "completed",
              "TaskCompletedById": EmpID,
              "TaskCompletedByName": EmpName,
              "TaskCompletionTime": DateTime.now(),
            };

            // Update the ShiftTaskStatus array with the new object
            shiftTasks[i]['ShiftTaskStatus'].add(shiftTaskStatus);

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

  Future<void> updateShiftReturnTaskStatus(
      String ShiftTaskId, String EmpID, String ShiftId, String EmpName) async {
    try {
      final DocumentReference shiftDocRef =
          FirebaseFirestore.instance.collection("Shifts").doc(ShiftId);
      final DocumentSnapshot shiftDoc = await shiftDocRef.get();

      if (shiftDoc.exists) {
        List<dynamic> shiftTasks = shiftDoc['ShiftTask'];

        for (int i = 0; i < shiftTasks.length; i++) {
          if (shiftTasks[i]['ShiftTaskId'] == ShiftTaskId) {
            // Find the ShiftTaskStatus object in the array
            List<dynamic> shiftTaskStatuses = shiftTasks[i]['ShiftTaskStatus'];
            for (int j = 0; j < shiftTaskStatuses.length; j++) {
              // Update ShiftTaskReturnStatus if TaskCompletedById and TaskCompletedByName match
              if (shiftTaskStatuses[j]['TaskCompletedById'] == EmpID &&
                  shiftTaskStatuses[j]['TaskCompletedByName'] == EmpName) {
                shiftTaskStatuses[j]['ShiftTaskReturnStatus'] = true;
                break; // Exit loop after updating
              }
            }

            // Update the Firestore document with the updated ShiftTaskStatus array
            await shiftDocRef.update({'ShiftTask': shiftTasks});
            print('Updated Status');
            break; // Exit loop after finding the ShiftTaskId
          }
        }
      } else {
        print("Shift document not found");
      }
    } catch (e) {
      print('Error updating ShiftTaskStatus: $e');
      throw e;
    }
  }

  //fetch images from patrol
  Future<List<Map<String, dynamic>>> getImageUrlsForPatrol(
      String PatrolID, String EmpId, String ShiftId) async {
    try {
      final querySnapshot = await patrols.doc(PatrolID).get();

      if (querySnapshot.exists) {
        final doc = querySnapshot.data() as Map<String, dynamic>;

        List<dynamic> patrolCheckPoints = doc["PatrolCheckPoints"] ?? [];
        List<Map<String, dynamic>> imageData = [];

        for (var checkPoint in patrolCheckPoints) {
          List<dynamic> checkPointStatus = checkPoint["CheckPointStatus"] ?? [];

          var status = checkPointStatus.firstWhere(
            (s) =>
                s["StatusReportedById"] == EmpId &&
                s['StatusShiftId'] == ShiftId,
            orElse: () => null,
          );

          if (status != null) {
            List<String> statusImageUrls =
                List<String>.from(status["StatusImage"] ?? []);
            Timestamp statusReportedTime = status["StatusReportedTime"];
            String formattedTime = statusReportedTime.toDate().toString();

            String statusComment = status["StatusComment"] ?? "";
            String checkPointName = checkPoint["CheckPointName"] ?? "";
            String checkPointStatus = status["Status"] ?? "";

            imageData.add({
              "CheckPointName": checkPointName,
              "StatusReportedTime": formattedTime,
              "ImageUrls": statusImageUrls,
              "StatusComment": statusComment,
              "CheckPointStatus": checkPointStatus
            });
          }
        }

        if (imageData.isNotEmpty) {
          print("Images Data for Patrol : $imageData");
          return imageData;
        } else {
          print("No image data found for EmpId: $EmpId in PatrolID: $PatrolID");
        }
      } else {
        print("No document found with PatrolID: $PatrolID");
      }

      return [];
    } catch (e) {
      print('Error fetching image URLs: $e');
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

  Future<String?> getClientPatrolEmail(String clientId) async {
    try {
      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(clientId)
          .get();

      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        bool clientSendEmailForEachPatrol =
            clientData['ClientSendEmailForEachPatrol'];
        if (clientSendEmailForEachPatrol) {
          String clientEmail = clientData['ClientEmail'];
          print('Client Email: $clientEmail');
          return clientEmail;
        } else {
          print('ClientSendEmailForEachPatrol is false');
          return null; // Return null if ClientSendEmailForEachPatrol is false
        }
      } else {
        print('Client not found');
        return null; // Return null if client is not found
      }
    } catch (e) {
      print('Error fetching client: $e');
      return null; // Return null in case of error
    }
  }

  Future<String?> getClientShiftEmail(String clientId) async {
    try {
      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(clientId)
          .get();

      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        bool clientSendEmailForEachPatrol =
            clientData['ClientSendEmailForEachShift'];
        if (clientSendEmailForEachPatrol) {
          String clientEmail = clientData['ClientEmail'];
          print('Client Email: $clientEmail');
          return clientEmail;
        } else {
          print('ClientSendEmailForEachPatrol is false');
          return null; // Return null if ClientSendEmailForEachPatrol is false
        }
      } else {
        print('Client not found');
        return null; // Return null if client is not found
      }
    } catch (e) {
      print('Error fetching client: $e');
      return null; // Return null in case of error
    }
  }

  Future<String?> getClientName(String? clientId) async {
    try {
      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(clientId)
          .get();

      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        String clientName = clientData['ClientName'];
        print('Client Email: $clientName');
        return clientName;
      } else {
        print('Client not found');
        return null; // Return null if client is not found
      }
    } catch (e) {
      print('Error fetching client: $e');
      return null; // Return null in case of error
    }
  }

  //fetch the patrol images and its data
  Future<void> fetchPatrolData(String shiftId, String empid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Get ShiftLinkedPatrols
      DocumentSnapshot shiftDoc =
          await firestore.collection('Shifts').doc(shiftId).get();
      Map<String, dynamic>? shiftData =
          shiftDoc.data() as Map<String, dynamic>?;

      if (shiftData == null) {
        print('Shift data not found.');
        return;
      }

      List<dynamic> shiftLinkedPatrols = shiftData['ShiftLinkedPatrols'];

      if (shiftLinkedPatrols.isEmpty) {
        print('No linked patrols found for this shift.');
        return;
      }

      // Step 2: Iterate over ShiftLinkedPatrols
      for (var patrol in shiftLinkedPatrols) {
        String patrolId = patrol['LinkedPatrolId'];
        String patrolName = patrol['LinkedPatrolName'];
        int patrolReqHitCount = patrol['LinkedPatrolReqHitCount'];

        // Step 3: Query PatrolCheckPoints
        QuerySnapshot checkPointsQuery = await firestore
            .collection('Patrols')
            .where('PatrolId', isEqualTo: patrolId)
            .get();

        if (checkPointsQuery.docs.isEmpty) {
          print('No checkpoints found for patrol: $patrolName.');
          continue;
        }

        // Step 4: Iterate over matching CheckPoints
        for (QueryDocumentSnapshot checkPointDoc in checkPointsQuery.docs) {
          List<dynamic> checkPointStatusList =
              checkPointDoc.get('CheckPointStatus');
          var status = checkPointStatusList.firstWhere(
            (s) => s["StatusReportedById"] == empid,
            orElse: () => null,
          );

          if (status != null) {
            // Get StatusComment
            String statusComment = status['StatusComment'] ?? 'No comment';

            // Get StatusImage URLs
            List<String> statusImageUrls =
                List<String>.from(status['StatusImage'] ?? []);

            // Process statusComment and statusImageUrls as needed
            print(
              'Patrol: $patrolName, StatusComment: $statusComment, StatusImageUrls: $statusImageUrls',
            );
          } else {
            print(
                'No status found for employee $empid in checkpoint ${checkPointDoc.id}.');
          }
        }
      }
    } catch (e) {
      print('Error fetching patrol data: $e');
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

  Future<String?> getAdminID(String companyId) async {
    try {
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('Admins')
          .where('AdminCompanyId', isEqualTo: companyId)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        String AdminId = adminSnapshot.docs.first['AdminId'];
        print('Admin Email: $AdminId');
        return AdminId;
      } else {
        print('Admin not found');
        return null; // Return null if admin is not found
      }
    } catch (e) {
      print('Error fetching admin: $e');
      return null; // Return null in case of error
    }
  }

  Future<List<String>?> getSupervisorIDs(String EmpId) async {
    try {
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('Employees')
          .where('EmployeeId', isEqualTo: EmpId)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        List<dynamic> supervisorIds =
            employeeSnapshot.docs.first['EmployeeSupervisorId'];
        List<String> supervisorIdList =
            supervisorIds.map((id) => id.toString()).toList();
        print('Supervisor IDs: $supervisorIdList');
        return supervisorIdList;
      } else {
        print('Employee not found');
        return null; // Return null if employee is not found
      }
    } catch (e) {
      print('Error fetching employee: $e');
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

  Future<String?> getShiftClientID(String shiftID) async {
    try {
      DocumentSnapshot clientSnapshot = await FirebaseFirestore.instance
          .collection('Shifts')
          .doc(shiftID)
          .get();

      if (clientSnapshot.exists) {
        var clientData = clientSnapshot.data() as Map<String, dynamic>;
        String? clientId = clientData['ShiftClientId'];
        print('Client Id: $clientId');
        return clientId;
      } else {
        print('Client not found');
        return null;
      }
    } catch (e) {
      print('Error fetching client: $e');
      return null;
    }
  }

  //PatrolClientId

  // Fetch the the PatrolLogs using PatrolShiftIds
  Future<List<Map<String, dynamic>>> fetchDataForPdf(
      String empId, String ShiftId) async {
    List<Map<String, dynamic>> pdfDataList = [];
    try {
      // Get the array of ShiftLinkedPatrolIds
      print("Shift Id ${ShiftId}");
      print("EMP Id ${empId}");

      print("Search for pdf Data");
      var shiftDoc = await FirebaseFirestore.instance
          .collection('Shifts')
          .doc(ShiftId)
          .get();
      print("Shift Doc : ${shiftDoc.data()}");
      var shiftLinkedPatrolIds =
          List<String>.from(shiftDoc.data()?['ShiftLinkedPatrolIds'] ?? []);
      print("shiftLinkedPatrolIds Doc : ${shiftLinkedPatrolIds}");
      // Query PatrolLogs for data
      var querySnapshot = await FirebaseFirestore.instance
          .collection('PatrolLogs')
          .where('PatrolId', whereIn: shiftLinkedPatrolIds)
          .where('PatrolLogGuardId', isEqualTo: empId)
          .where('PatrolShiftId', isEqualTo: ShiftId)
          .orderBy('PatrolLogPatrolCount')
          .get();

      querySnapshot.docs.forEach((doc) {
        // Check if the document ID is in the list of specific IDs
        // Check if the document ID already exists in pdfDataList
        if (!pdfDataList.any((element) => element['PatrolLogId'] == doc.id)) {
          pdfDataList.add(doc.data());
          print("Data for Pdf: ${doc.data()}");
        }
      });
    } catch (e) {
      print(e);
    }
    return pdfDataList;
  }

  Future<List<Map<String, dynamic>>> fetchTemplateDataForPdf(
      String empId, String ShiftId) async {
    List<Map<String, dynamic>> pdfDataList = [];
    try {
      // Get the array of ShiftLinkedPatrolIds
      print("Shift Id ${ShiftId}");
      print("EMP Id ${empId}");

      print("Search for pdf Data");
      var shiftDoc = await FirebaseFirestore.instance
          .collection('Shifts')
          .doc(ShiftId)
          .get();
      print("Shift Doc : ${shiftDoc.data()}");
      var shiftLinkedPatrolIds =
          List<String>.from(shiftDoc.data()?['ShiftLinkedPatrolIds'] ?? []);
      print("shiftLinkedPatrolIds Doc : ${shiftLinkedPatrolIds}");
      // Query PatrolLogs for data
      var querySnapshot = await FirebaseFirestore.instance
          .collection('PatrolLogs')
          // .where('PatrolShiftId', isEqualTo: ShiftId)
          .where('PatrolLogGuardId', isEqualTo: empId)
          // .where('changePatrolStatus', isEqualTo: ShiftId)
          .orderBy('PatrolLogPatrolCount')
          .get();

      // Process query results
      List<String> specificDocIds = [
        '17R4yMJsBmegl2088uIe',
        '4YSj5Q4JNO9YFwSeOdua',
        'Gnq53zSuCqIa6JqXObnT'
      ];

      querySnapshot.docs.forEach((doc) {
        // Check if the document ID is in the list of specific IDs
        // Check if the document ID already exists in pdfDataList
        if (specificDocIds.contains(doc.id)) {
          // Check if the document ID already exists in pdfDataList
          if (!pdfDataList.any((element) => element['PatrolLogId'] == doc.id)) {
            pdfDataList.add(doc.data());
            print("Data for Pdf: ${doc.data()}");
          }
        }
      });
    } catch (e) {
      print(e);
    }
    return pdfDataList;
  }

  Future<void> copyAndCreateDocument(
      String collection, String sourceDocumentId) async {
    final DocumentReference sourceDocRef =
        FirebaseFirestore.instance.collection(collection).doc(sourceDocumentId);

    DocumentSnapshot sourceDocSnapshot = await sourceDocRef.get();

    if (!sourceDocSnapshot.exists) {
      print('Document does not exist');
      return;
    }

    final Map<String, dynamic> data =
        sourceDocSnapshot.data() as Map<String, dynamic>;

    // Copy the document to a new document with a different ID
    final DocumentReference newDocRef =
        FirebaseFirestore.instance.collection(collection).doc();

    await newDocRef.set(data);
  }

  //Create log
  // Future<void> addToLog(
  //     String logType,
  //     String LocationName,
  //     String ClientName,
  //     Timestamp LogBookTimeStamp,
  //     Timestamp LogBookModifiedAt,
  //     String LogBookEmployeeId,
  //     String LogbookEmployeeName,
  //     String LogBookCompanyID,
  //     String LogBookBranchID,
  //     String LogBookClientID) async {
  //   try {
  //     final userRef = FirebaseFirestore.instance.collection('LogBook');

  //     // Get the current system time
  //     DateTime currentTime = DateTime.now();

  //     // Create a new document in the "Log" subcollection with an auto-generated ID
  //     DocumentReference newLogRef = await userRef.add({
  //       'LogBookType': logType,
  //       'LogBookLocation': LocationName,
  //       'LogBookClientName': LocationName, // Note: Should this be ClientName?
  //       'LogBookID': "", // Placeholder value
  //       'LogBookTimeStamp': LogBookTimeStamp,
  //       'LogBookModifiedAt': LogBookModifiedAt,
  //       'LogBookEmployeeId': LogBookEmployeeId,
  //       'LogbookEmployeeName': LogbookEmployeeName,
  //       'LogBookCompanyID': LogBookCompanyID,
  //       'LogBookBranchID': LogBookBranchID,
  //       'LogBookClientID': LogBookClientID,
  //     });

  //     // Update the document to set LogBookID to the document ID
  //     await newLogRef.update({'LogBookID': newLogRef.id});

  //     print('Shift start logged at $currentTime');
  //   } catch (e) {
  //     print('Error logging shift start: $e');
  //   }
  // }
  // Future<void> addToLog(
  //     String logType,
  //     String LocationName,
  //     String ClientName,
  //     Timestamp LogBookTimeStamp,
  //     Timestamp LogBookModifiedAt,
  //     String LogBookEmployeeId,
  //     String LogbookEmployeeName,
  //     String LogBookCompanyID,
  //     String LogBookBranchID,
  //     String LogBookClientID) async {
  //   try {
  //     final now = DateTime.now();
  //     final formatedDate = DateFormat('dd-M-yyyy').format(now);

  //     final userRef = FirebaseFirestore.instance.collection('LogBook');

  //     // Create a new document in the "Log" subcollection with an auto-generated ID
  //     DocumentReference newLogRef = await userRef.add({
  //       'LogBookType': logType,
  //       'LogBookLocation': LocationName,
  //       'LogBookClientName': LocationName, // Note: Should this be ClientName?
  //       'LogBookID': "", // Placeholder value
  //       'LogBookTimeStamp': LogBookTimeStamp,
  //       'LogBookModifiedAt': LogBookModifiedAt,
  //       'LogBookEmployeeId': LogBookEmployeeId,
  //       'LogbookEmployeeName': LogbookEmployeeName,
  //       'LogBookCompanyID': LogBookCompanyID,
  //       'LogBookBranchID': LogBookBranchID,
  //       'LogBookClientID': LogBookClientID,
  //     });

  //     // Update the document to set LogBookID to the document ID
  //     await newLogRef.update({'LogBookID': newLogRef.id});

  //     // print('Shift start logged at $currentTime');
  //   } catch (e) {
  //     print('Error logging shift start: $e');
  //   }
  // }

  List convertDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return [date.day, date.month, date.year];
  }

  Future<void> addToLog(
      String logType,
      String locationName,
      String clientName,
      String logBookEmployeeId,
      String logbookEmployeeName,
      String logBookCompanyID,
      String logBookBranchID,
      String logBookClientID,
      String logBookLocationID,
      String ShiftName,
      String? PatrolName,
      String? CheckPointName) async {
    try {
      final today = DateTime.now();
      bool isDocumentPresent = false;
      final userRef = FirebaseFirestore.instance.collection('LogBook');
      final query = userRef.where('LogBookEmpId', isEqualTo: logBookEmployeeId);
      String documentID = '';

      final querySnapshot = await query.get();

      for (var log in querySnapshot.docs) {
        var data = log.data();
        var time = convertDate(data['LogBookDate']);
        if (today.day == time[0] &&
            today.month == time[1] &&
            today.year == time[2]) {
          isDocumentPresent = true;
          documentID = log.id;
          break;
        }
      }

      final logEntry = {
        'LogContent': '$logType at $locationName for $clientName',
        'LogType': logType,
        'LogReportedAt': Timestamp.fromDate(today),
      };

      // Add optional fields if they are not null
      if (PatrolName != null) {
        logEntry['LogPatrolName'] = PatrolName;
      }
      if (CheckPointName != null) {
        logEntry['LogCheckPointName'] = CheckPointName;
      }

      if (isDocumentPresent) {
        // A document exists, update the LogBookData array
        final docRef = userRef.doc(documentID);
        await docRef.update({
          'LogBookData': FieldValue.arrayUnion([logEntry]),
        });
      } else {
        // Set the timestamp separately
        final timestamp = Timestamp.fromDate(today);

        DocumentReference newLogRef = await userRef.add({
          'LogBookCompanyId': logBookCompanyID,
          'LogBookCompanyBranchId': logBookBranchID,
          'LogBookDate': timestamp,
          'LogBookEmpId': logBookEmployeeId,
          'LogBookEmpName': logbookEmployeeName,
          'LogBookClientId': logBookClientID,
          'LogBookClientName': clientName,
          'LogBookLocationId': logBookLocationID,
          'LogBookLocationName': locationName,
          'LogBookData': [logEntry],
          'LogBookCreatedAt': timestamp,
          'LogBookShiftName': ShiftName,
        });

        // Update the document to set LogBookId to the document ID
        await newLogRef.update({'LogBookId': newLogRef.id});
      }
    } catch (e) {
      print('Error logging: $e');
    }
  }

  //
  Future<void> changePatrolStatus(String shiftId, String empId) async {
    // Fetch ShiftLinkedPatrolIds from the Shifts collection
    DocumentSnapshot shiftSnapshot = await FirebaseFirestore.instance
        .collection('Shifts')
        .doc(shiftId)
        .get();
    final shiftLinkedPatrolIds = List<Map<String, dynamic>>.from(
        shiftSnapshot['ShiftLinkedPatrols'] ?? []);
    final patrolIds = shiftLinkedPatrolIds
        .map((patrol) => patrol["LinkedPatrolId"] as String)
        .toList();
    print('ShiftLinkedPatrolIds: $shiftLinkedPatrolIds');

    // Update Patrol documents for each patrolId in ShiftLinkedPatrolIds
    for (String patrolId in patrolIds) {
      DocumentSnapshot patrolSnapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .doc(patrolId)
          .get();
      print("Patrol Fetch for changing status ${patrolSnapshot}");
      // Check if PatrolCheckPoints field exists in the document
      if (patrolSnapshot.exists &&
          (patrolSnapshot.data() as Map<String, dynamic>)
              .containsKey('PatrolCheckPoints')) {
        List<dynamic> checkPointsList =
            List<dynamic>.from(patrolSnapshot['PatrolCheckPoints'] ?? []);

        print('CheckPoints for patrolId $patrolId: $checkPointsList');

        // Update CheckPointStatus array within PatrolCheckPoints
        List<dynamic> updatedCheckPointsList = [];
        for (var checkPoint in checkPointsList) {
          List<dynamic> checkPointStatusList =
              List<dynamic>.from(checkPoint['CheckPointStatus'] ?? []);
          List<dynamic> updatedCheckPointStatusList = [];
          for (var status in checkPointStatusList) {
            if (status['StatusReportedById'] != empId) {
              updatedCheckPointStatusList.add(status);
            }
          }
          checkPoint['CheckPointStatus'] = updatedCheckPointStatusList;
          updatedCheckPointsList.add(checkPoint);
        }

        // Update Patrol document with the updated PatrolCheckPoints array
        await FirebaseFirestore.instance
            .collection('Patrols')
            .doc(patrolId)
            .update({
          'PatrolCheckPoints': updatedCheckPointsList,
        });

        // Update PatrolCurrentStatus array
        List<dynamic> currentStatusList =
            List<dynamic>.from(patrolSnapshot['PatrolCurrentStatus'] ?? []);
        for (var status in currentStatusList) {
          if (status['StatusReportedById'] == empId) {
            status['Status'] = 'pending';
            status['StatusCompletedCount'] = 0;
            status['StatusShiftId'] = shiftId;
            // status['StatusReportedTime'] = DateTime.now().toUtc().toString();
            break; // Exit loop once the status is updated
          }
        }

        // Update Patrol document with the modified PatrolCurrentStatus array
        await FirebaseFirestore.instance
            .collection('Patrols')
            .doc(patrolId)
            .update({
          'PatrolCurrentStatus': currentStatusList,
        });
      }
    }
  }

  //get all the report titles
  Future<List<String>> getReportTitles() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('ReportCategories').get();

      final List<String> titles = snapshot.docs
          .map((doc) => doc.data()['ReportCategoryName'] as String)
          .toSet()
          .toList();

      return titles;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<List<Map<String, dynamic>>> getReportWithCompanyID(
      String companyId, String locationId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Reports')
              .where('ReportLocationId', isEqualTo: locationId)
              .where('ReportCompanyId', isEqualTo: companyId)
              .get();

      final Set<Map<String, dynamic>> dataSet = Set<Map<String, dynamic>>();

      snapshot.docs.forEach((doc) {
        dataSet.add(doc.data());
      });

      final List<Map<String, dynamic>> data = dataSet.toList();

      return data;
    } catch (e) {
      print("Error fetching report data: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<List<Map<String, dynamic>>> getReportWithEmpID(String empId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Reports')
              .where('ReportEmployeeId', isEqualTo: empId)
              // .where('ReportCompanyId', isEqualTo: companyId)
              .get();

      final Set<Map<String, dynamic>> dataSet = Set<Map<String, dynamic>>();

      snapshot.docs.forEach((doc) {
        dataSet.add(doc.data());
      });

      final List<Map<String, dynamic>> data = dataSet.toList();

      return data;
    } catch (e) {
      print("Error fetching report data: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<Map<String, dynamic>?> getReportWithId(String reportId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Reports')
              .doc(reportId)
              .get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        print("Document with ID $reportId does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching report data: $e");
      return null; // Return null in case of error
    }
  }

  Future<Map<String, dynamic>?> getReportWithSearchId(String reportId) async {
    try {
      if (reportId.isNotEmpty || reportId != null) {
        final QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('Reports')
                .where('ReportSearchId', isEqualTo: reportId)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Assuming there's only one document with the given ReportSearchId
          final data = querySnapshot.docs.first.data();
          if (data != null && data['ReportSearchId'] == reportId) {
            return data;
          } else {
            print(
                "Document with ID $reportId does not match the ReportSearchId");
            return null;
          }
        } else {
          print("No document with ReportSearchId $reportId found");
          return null;
        }
      }
    } catch (e) {
      print("Error fetching report data: $e");
      return null; // Return null in case of error
    }
  }

  //Create Report
//   export interface IReportsCollection {
//   ReportId: string;
//   ReportLocationId: string;
//   ReportLocationName: string;
//   ReportIsFollowUpRequired: boolean;
//   ReportFollowedUpId?: string | null;  //*Id of report which followed up this report
//   ReportCompanyId: string;
//   ReportCompanyBranchId?: string;
//   ReportEmployeeId: string;
//   ReportEmployeeName: string;
//   ReportName: string;
//   ReportCategoryName: string;
//   ReportCategoryId: string;
//   ReportData: string;
//   ReportShiftId?: string;
//   ReportPatrolId?: string;
//   ReportImage?: string[];
//   ReportVideo?: string[];
//   ReportStatus: 'pending' | 'started' | 'completed';
//   ReportClientId: string;
//   ReportCreatedAt: Timestamp | FieldValue;
// }
  Future<void> createReport({
    required String locationId,
    required String locationName,
    required bool isFollowUpRequired,
    String? followedUpId,
    required String companyId,
    String? companyBranchId,
    required String employeeId,
    required String employeeName,
    required String reportName,
    required String categoryName,
    required String categoryId,
    required String data,
    required String shiftId,
    String? patrolId,
    List<String>? image,
    List<String>? video,
    required String status,
    required String clientId,
    required DateTime? createdAt,
  }) async {
    try {
      final CollectionReference reportsRef =
          FirebaseFirestore.instance.collection('Reports');
      final DocumentReference reportDoc = await reportsRef.add({
        'ReportLocationId': locationId,
        'ReportLocationName': locationName,
        'ReportIsFollowUpRequired': isFollowUpRequired,
        if (followedUpId != null) 'ReportFollowedUpId': followedUpId,
        'ReportCompanyId': companyId,
        if (companyBranchId != null) 'ReportCompanyBranchId': companyBranchId,
        'ReportEmployeeId': employeeId,
        'ReportEmployeeName': employeeName,
        'ReportName': reportName,
        'ReportCategoryName': categoryName,
        'ReportCategoryId': categoryId,
        'ReportData': data,
        'ReportShiftId': shiftId,
        if (patrolId != null) 'ReportPatrolId': patrolId,
        if (image != null) 'ReportImage': image,
        if (video != null) 'ReportVideo': video,
        'ReportStatus': status,
        'ReportClientId': clientId,
        'ReportCreatedAt': createdAt,
      });

      await reportDoc.update({"ReportId": reportDoc.id});
      Timestamp timestamp = Timestamp.now();

      // Convert Timestamp to DateTime
      DateTime dateTime = timestamp.toDate();

      // Format DateTime as a date string
      String date = '${dateTime.day}${dateTime.month}';

      // Generate a unique ID
      var uniqueid = await generateUniqueID(date, reportName, categoryName);

      // Update ReportSearchId
      await reportDoc.update({"ReportSearchId": uniqueid});

      // Reference to EmployeesDAR collection
      final CollectionReference employeesDARRef =
          FirebaseFirestore.instance.collection('EmployeesDAR');

      // Query to find the document with the matching employeeId and shiftId
      QuerySnapshot querySnapshot = await employeesDARRef
          .where('EmpDarEmpId', isEqualTo: employeeId)
          .where('EmpDarShiftId', isEqualTo: shiftId)
          .get();
      print("Shift Id ${shiftId}");
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        // Get the first matching documents
        DocumentReference employeeDARDoc = documentSnapshot.reference;
        DocumentSnapshot employeeDARSnapshot = await employeeDARDoc.get();
        Map<String, dynamic> employeeDARData =
            employeeDARSnapshot.data() as Map<String, dynamic>;

        // Debugging: Print EmpDarTile
        print('EmpDarTile: ${employeeDARData['EmpDarTile']}');

        // Check if EmpDarTile is a list
        if (employeeDARData['EmpDarTile'] is List) {
          List<dynamic> empDarTiles = employeeDARData['EmpDarTile'];

          // Filter out non-map tiles
          empDarTiles = empDarTiles
              .where((tile) => tile is Map<String, dynamic>)
              .toList();

          // Ensure each tile is a Map
          DateTime currentDate = DateTime.now();
          for (int i = 0; i < empDarTiles.length; i++) {
            Map<String, dynamic>? tile =
                empDarTiles[i] as Map<String, dynamic>?;
            if (tile == null) continue;

            Timestamp? tileDate = tile['TileDate'] as Timestamp?;
            String? tileTime = tile['TileTime'] as String?;

            // Ensure tileDate and tileTime are not null
            if (tileDate == null || tileTime == null) continue;

            // Check if the tileDate is the current date
            if (currentDate.year == createdAt!.year &&
                currentDate.month == createdAt.month &&
                currentDate.day == createdAt.day) {
              // Parse the tileTime to get the start and end times
              List<String> timeRange = tileTime.split(' - ');
              List<int> startTimeParts =
                  timeRange[0].split(':').map(int.parse).toList();
              List<int> endTimeParts =
                  timeRange[1].split(':').map(int.parse).toList();

              // Create DateTime objects for start and end times
              DateTime startTime = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                startTimeParts[0],
                startTimeParts[1],
              );
              DateTime endTime = DateTime(
                currentDate.year,
                currentDate.month,
                currentDate.day,
                endTimeParts[0],
                endTimeParts[1],
              );

              // Adjust the end time if it's before the start time due to crossing midnight
              if (endTime.isBefore(startTime)) {
                endTime = endTime.add(Duration(days: 1));
              }

              // Check if the current time is within the range
              if (createdAt.isAfter(startTime) && createdAt.isBefore(endTime)) {
                print("Created At $createdAt");
                print("startTime At $startTime");
                print("endTime At $endTime");
                // String updateString = "${reportName} : ${uniqueid}";
                // tile['TileContent'] = updateString;
                Map<String, dynamic> tileReport = {
                  'TileReportName': reportName,
                  'TileReportId': reportDoc.id,
                  // Format patrol start and end times for display
                  'TileReportSearchId': uniqueid,
                };
                if (!tile.containsKey('TileReport')) {
                  tile['TileReport'] = []; // Initialize as an empty array
                }
                tile['TileReport'].add(tileReport);

                // tile['TileReportSearchId'] = uniqueid;
                // tile['TileReportName'] = reportName;

                // tile['ReportSearchId'] = uniqueid;
                empDarTiles[i] = tile;
                print('Updated Tile at index $i: $tile');
              } else {
                print("Created At ${createdAt}");
                print("startTime At $startTime");
                print("endTime At $endTime");
                print("unsuccessful in updating the tile");
              }
            }
          }

          // Update the document
          print("Updating the Dar ${employeeDARDoc.id}");
          await employeeDARDoc.update({'EmpDarTile': empDarTiles});
        } else {
          print('EmpDarTile is not a List');
        }
      }

      print('Report created successfully');
    } catch (e) {
      print('Error creating report: $e');
    }
  }

  Future<void> updateFollowUp(String reportId) async {
    try {
      final CollectionReference reportsRef =
          FirebaseFirestore.instance.collection('Reports');

      await reportsRef.doc(reportId).update({
        'ReportIsFollowUpRequired': false,
      });

      print('Follow-up updated successfully.');
    } catch (e) {
      print("Error in updating the follow-up: $e");
    }
  }

  //Gell all Shift
  Future<List<Map<String, dynamic>>> getShiftHistory(String empId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Shifts')
        .where('ShiftAssignedUserId', arrayContains: empId)
        .get();

    List<Map<String, dynamic>> shiftHistoryList = [];
    Set<String> addedDocIds = Set(); // To keep track of added document IDs

    querySnapshot.docs.forEach((doc) {
      List<dynamic> shiftCurrentStatus = doc['ShiftCurrentStatus'];
      if (shiftCurrentStatus != null) {
        for (var status in shiftCurrentStatus) {
          if (status is Map &&
              status['Status'] == 'completed' &&
              status['StatusReportedById'] == empId &&
              !addedDocIds.contains(doc.id)) {
            // Explicitly cast the result of doc.data() to Map<String, dynamic>
            shiftHistoryList.add(doc.data() as Map<String, dynamic>);
            addedDocIds.add(doc.id);
            break; // Exit the loop once a match is found
          }
        }
      }
    });

    return shiftHistoryList;
  }

  //fetch all the roles
  Future<List<String>> getEmployeeRoles(String companyid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('EmployeeRoles').get();

      final List<String> roles = snapshot.docs
          .where((doc) => doc.data()['EmployeeRoleCompanyId'] == companyid)
          .map((doc) => doc.data()['EmployeeRoleName'] as String)
          .toSet()
          .toList();
      print("Roles ${roles}");
      return roles;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  //fetch all the patrols according to the supervisor
  Future<List<String>> getAllClientsName(String companyid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Clients').get();

      final List<String> roles = snapshot.docs
          .where((doc) => doc.data()['ClientCompanyId'] == companyid)
          .map((doc) => doc.data()['ClientName'] as String)
          .toSet()
          .toList();
      print("Clientname ${roles}");
      return roles;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<Map<String, String>> getAllClientsNameAndID(String companyId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Clients').get();

      final Map<String, String> clients = Map.fromEntries(
        snapshot.docs
            .where((doc) => doc.data()['ClientCompanyId'] == companyId)
            .map((doc) => MapEntry(
                  doc.id,
                  doc.data()['ClientName'] as String,
                )),
      );

      print("Clients: $clients");
      return clients;
    } catch (e) {
      print("Error fetching clients: $e");
      return {}; // Return empty map in case of error
    }
  }

  //Fetch location
  Future<List<String>> getAllLocation(String companyid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Locations').get();

      final List<String> roles = snapshot.docs
          .where((doc) => doc.data()['LocationCompanyId'] == companyid)
          .map((doc) => doc.data()['LocationName'] as String)
          .toSet()
          .toList();
      print("Clientname ${roles}");
      return roles;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<List<String>> getAllBranch(String companyid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('CompanyBranch').get();

      final List<String> roles = snapshot.docs
          .where((doc) => doc.data()['CompanyId'] == companyid)
          .map((doc) => doc.data()['CompanyBranchName'] as String)
          .toSet()
          .toList();
      print("Clientname ${roles}");
      return roles;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<List<String>> getAllBranchNameById(String branchId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('CompanyBranch').get();

      final List<String> roles = snapshot.docs
          .where((doc) => doc.data()['CompanyId'] == branchId)
          .map((doc) => doc.data()['CompanyBranchId'] as String)
          .toSet()
          .toList();
      print("Clientname ${roles}");
      return roles;
    } catch (e) {
      print("Error fetching report titles: $e");
      return []; // Return empty list in case of error
    }
  }

  Future<Map<String, String>> getAllLocationsWithId(String companyId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Locations').get();

      final Map<String, String> locations = Map.fromEntries(
        snapshot.docs
            .where((doc) => doc.data()['LocationCompanyId'] == companyId)
            .map((doc) => MapEntry(
                  doc.id,
                  doc.data()['LocationName'] as String,
                )),
      );

      print("Locations: $locations");
      return locations;
    } catch (e) {
      print("Error fetching locations: $e");
      return {}; // Return empty map in case of error
    }
  }

  //fetch all the patrols
  // Future<List<Map<String, String>>> getAllPatrolName(String companyId) async {
  //   try {
  //     final QuerySnapshot<Map<String, dynamic>> snapshot =
  //         await FirebaseFirestore.instance.collection('Patrols').get();

  //     final List<Map<String, String>> roles = snapshot.docs
  //         .where((doc) => doc.data()['PatrolCompanyId'] == companyId)
  //         .map((doc) =>
  //             {'id': doc.id, 'name': doc.data()['PatrolName'] as String})
  //         .toSet()
  //         .toList();
  //     print("Clientname $roles");
  //     return roles;
  //   } catch (e) {
  //     print("Error fetching report titles: $e");
  //     return []; // Return empty list in case of error
  //   }
  // }

  Future<List<String>> getAllPatrolName(String companyId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Patrols').get();

      final List<String> patrolNames = snapshot.docs
          .where((doc) => doc.data()['PatrolCompanyId'] == companyId)
          .map((doc) => doc.data()['PatrolName'] as String)
          .toSet()
          .toList();
      print("Patrol names: $patrolNames");
      return patrolNames;
    } catch (e) {
      print("Error fetching patrol names: $e");
      return []; // Return empty list in case of error
    }
  }

  //fetch the location coordinates ,
  Future<String> getClientIdfromName(String clientName) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .where('ClientName', isEqualTo: clientName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming ClientId is a field in your document
        return snapshot.docs.first['ClientId'];
      } else {
        return ''; // Or handle the case where no document matches the clientName
      }
    } catch (e) {
      print(e);
      return ''; // Or throw an error if you want to handle it differently
    }
  }

  // patrol id from patrolname for a list of names
  Future<List<String>> getPatrolIdsFromNames(List<String> patrolNames) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .where('PatrolName', whereIn: patrolNames)
          .get();

      List<String> patrolIds = [];
      snapshot.docs.forEach((doc) {
        patrolIds.add(doc['PatrolId']);
      });

      return patrolIds;
    } catch (e) {
      print(e);
      return []; // Or throw an error if you want to handle it differently
    }
  }

  Future<String?> getPatrolNameFromId(String PatrolId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Patrols')
          .where('PatrolId', isEqualTo: PatrolId)
          .limit(
              1) // Limit to 1 result as we expect only one patrol name for a given PatrolId
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['PatrolName'];
      } else {
        return null; // Return null if no document is found
      }
    } catch (e) {
      print(e);
      return null; // Return null or handle the error as needed
    }
  }

  Future<DocumentSnapshot> getLocationByName(
      String locationName, String companyid) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Locations')
          .where('LocationName', isEqualTo: locationName)
          .where('LocationCompanyId', isEqualTo: companyid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        throw Exception('No document found with the specified location name.');
      }
    } catch (e) {
      print('Error getting location: $e');
      rethrow; // Rethrow the exception to handle it outside this function
    }
  }

  List<String> _generateSearchIndex(String keyName) {
    List<String> searchIndex = [];
    for (int i = 0; i < keyName.length; i++) {
      for (int j = i + 1; j <= keyName.length; j++) {
        searchIndex.add(keyName.substring(i, j).toLowerCase());
      }
    }
    return searchIndex;
  }

  //Create Key
  Future<void> CreateKey(
      String KeyCompanyBranchId,
      String KeyCompanyId,
      String KeyName,
      int KeyAllotedQuantity,
      String KeyDescription,
      int KeyTotalQuantity) async {
    try {
      // Define the Firestore instance
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define the collection name
      String collectionName = "Keys";

      // Get a document reference with an automatically generated ID
      DocumentReference docRef = firestore.collection(collectionName).doc();

      // Prepare the data
      Map<String, dynamic> keyData = {
        "KeyId": docRef.id, // Set the document ID as KeyId
        "KeyCompanyBranchId": KeyCompanyBranchId,
        "KeyCompanyId": KeyCompanyId,
        "KeyName": KeyName,
        "KeyAllotedQuantity": KeyAllotedQuantity,
        "KeyDescription": KeyDescription,
        "KeyTotalQuantity": KeyTotalQuantity,
        "KeyCreatedAt": FieldValue.serverTimestamp(),
        "KeyModifiedAt": FieldValue.serverTimestamp(),
        "KeyNameSearchIndex": _generateSearchIndex(KeyName),
      };

      // Add the data to Firestore using the document reference
      await docRef.set(keyData);

      print("Key created successfully!");
    } catch (e) {
      print("Failed to create key: $e");
    }
  }

  Future<String?> FetchKeyName(String KeyId) async {
    try {
      CollectionReference keysCollection =
          FirebaseFirestore.instance.collection('Keys');
      DocumentSnapshot snapshot = await keysCollection.doc(KeyId).get();

      if (snapshot.exists) {
        return snapshot.get('KeyName');
      } else {
        return null; // or throw an exception if you prefer
      }
    } catch (e) {
      print("Error fetching key name: $e");
      return null; // or handle the error as needed
    }
  }

  //Exchange update status
  Future<void> UpdateExchangeNotiStatus(String docId, String Status) async {
    try {
      // Get a reference to the ShiftExchange collection
      CollectionReference exchangeCollection =
          FirebaseFirestore.instance.collection('Notification');

      // Update the document with the provided docId
      await exchangeCollection.doc(docId).update({
        "NotificationStatus": Status, // Update status to "started"
      });

      print("Shift exchange status updated successfully!");
    } catch (e) {
      print("Error updating shift exchange status: $e");
    }
  }

  Future<void> UpdateExchangeStatus(String docId, String Status) async {
    try {
      // Get a reference to the ShiftExchange collection
      CollectionReference exchangeCollection =
          FirebaseFirestore.instance.collection('ShiftExchange');

      // Update the document with the provided docId
      await exchangeCollection.doc(docId).update({
        "ShiftExchReqStatus": Status, // Update status to "started"
      });

      print("Shift exchange status updated successfully!");
    } catch (e) {
      print("Error updating shift exchange status: $e");
    }
  }

  Future<void> UpdateOfferStatus(String docId, String Status) async {
    try {
      // Get a reference to the ShiftExchange collection
      CollectionReference exchangeCollection =
          FirebaseFirestore.instance.collection('ShiftOffer');

      // Update the document with the provided docId
      await exchangeCollection.doc(docId).update({
        "ShiftOfferStatus": Status, // Update status to "started"
      });

      print("Shift exchange status updated successfully!");
    } catch (e) {
      print("Error updating shift exchange status: $e");
    }
  }

  //send message
  Future<void> SendMessage(String Companyid, String UserName,
      String MessageData, List<String> receiversId, String Empid) async {
    try {
      // Assuming you have a 'messages' collection in Firestore
      CollectionReference messagesCollection =
          FirebaseFirestore.instance.collection('Messages');
      // List<String> receiversId = [
      //   'g3mGPRtk8wfGG2QSnzIMGELjK4u2',
      //   'aSvLtwII6Cjs7uCISBRR'
      // ];
      // Create a map for the message data
      Map<String, dynamic> messageData = {
        'MessageCompanyId': Companyid,
        'MessageCreatedAt': FieldValue.serverTimestamp(),
        'MessageCreatedById': Empid,
        'MessageCreatedByName': UserName,
        'MessageData': MessageData,
        'MessageReceiversId': receiversId,
        'MessageType': 'panic'
      };
      DocumentReference newDocRef = await messagesCollection.add(messageData);
      String messageId = newDocRef.id;

      // Update the document with the MessageId
      await newDocRef.update({'MessageId': messageId});

      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      throw e;
    }
  }

//Handling the New gallery option and timestamp condition
//Handling the gallery option
  Future<bool> showGalleryOption(String empid) async {
    try {
      // Reference the document in the 'Employee' collection using empid
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(empid)
          .get();

      // Check if the document exists and cast data to Map<String, dynamic>
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Check if the field exists and return its value or false
        return data.containsKey('EmployeeIsTimeStampForPatrolImagesEnabled')
            ? data['EmployeeIsTimeStampForPatrolImagesEnabled'] as bool
            : false;
      } else {
        return false; // Return false if the document doesn't exist
      }
    } catch (e) {
      print("Error fetching employee data: $e");
      return false; // Return false in case of any errors
    }
  }

//use timestamp
  Future<bool> useTimeStampOption(String empid) async {
    try {
      // Reference the document in the 'Employee' collection using empid
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(empid)
          .get();

      // Check if the document exists and cast data to Map<String, dynamic>
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Check if the field exists and return its value or false
        return data.containsKey('EmployeeIsUploadFromGalleryEnabled')
            ? data['EmployeeIsUploadFromGalleryEnabled'] as bool
            : false;
      } else {
        return false; // Return false if the document doesn't exist
      }
    } catch (e) {
      print("Error fetching employee data: $e");
      return false; // Return false in case of any errors
    }
  }
// Schedule and assign
}
