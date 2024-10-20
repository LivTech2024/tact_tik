import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tact_tik/screens/location_filter_page.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

class UserService {
  FireStoreService fireStoreService = FireStoreService();
  String? shiftLocationId;
  String? shiftStartTime;
  String? shiftEndTime;
  String? shiftLocation;
  String? userName;
  String? ShiftId;
  String? shiftClientId;
  String? shiftCompanyId;
  String? shiftCompanyBranchId;
  String? shiftName;
  String? employeeID;
  Timestamp? shiftDate;
  // Timestamp? shiftDate; //shiftDate
  UserService({required FireStoreService firestoreService});
  Future<void> getShiftInfo() async {
    var currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No current user logged in");
      return null;
    }

    final currentUserEmail = currentUser.email;
    print("Current User Email ${currentUserEmail}");
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail2();
    if (userInfo != null) {
      userName = userInfo['EmployeeName'];
      String employeeId = userInfo['EmployeeId'];
      // String empEmail = userInfo['EmployeeEmail'];
      // String empImage = userInfo['EmployeeImg'] ?? "";
      if (employeeId.isNotEmpty || employeeId != null) {
        employeeID = employeeId;
      }
      var shiftInfo =
          await fireStoreService.getShiftByEmployeeIdFromUserInfo(employeeId);
      print('User Info: ${userInfo.data()}');
      if (shiftInfo != null) {
        shiftLocationId = shiftInfo['ShiftLocationId'] ?? " ";
        shiftStartTime = shiftInfo['ShiftStartTime'] ?? " ";
        shiftEndTime = shiftInfo['ShiftEndTime'] ?? " ";
        shiftLocation = shiftInfo['ShiftLocationAddress'] ?? " ";
        ShiftId = shiftInfo['ShiftId'] ?? "";
        shiftClientId = shiftInfo['ShiftClientId'] ?? " ";
        shiftCompanyId = shiftInfo['ShiftCompanyId'] ?? " ";
        shiftCompanyBranchId = shiftInfo['ShiftCompanyBranchId'] ?? " ";
        shiftName = shiftInfo['ShiftName'] ?? " ";
        shiftDate = shiftInfo['ShiftDate'] ?? " ";
        //ShiftClientId  ShiftCompanyBranchId  // ShiftCompanyId //ShiftDate  //ShiftCompanyBranchId  //ShiftDate
        // String shiftName = shiftInfo['ShiftName'] ?? " ";
        String shiftId = shiftInfo['ShiftId'] ?? " ";
      } else {
        print('Shift info not found');
      }
    } else {
      print('User info not found');
    }
  }
}
