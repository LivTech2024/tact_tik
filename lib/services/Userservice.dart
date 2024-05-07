import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? ShiftDate;
  // Timestamp? shiftDate;
  UserService({required FireStoreService firestoreService});

  String? get employeeId => null;

  Future<void> getShiftInfo() async {
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
    if (userInfo != null) {
      userName = userInfo['EmployeeName'];
      String employeeId = userInfo['EmployeeId'];
      // String empEmail = userInfo['EmployeeEmail'];
      // String empImage = userInfo['EmployeeImg'] ?? "";
      var shiftInfo =
          await fireStoreService.getShiftByEmployeeIdFromUserInfo(employeeId);

      print('User Info: ${userInfo.data()}');

      if (shiftInfo != null) {
        shiftLocationId = shiftInfo['ShiftLocationId'] ?? " ";
        shiftStartTime = shiftInfo['ShiftStartTime'] ?? " ";
        shiftEndTime = shiftInfo['ShiftEndTime'] ?? " ";
        shiftLocation = shiftInfo['ShiftLocationAddress'] ?? " ";
        ShiftId = shiftInfo['ShiftId'];
        shiftClientId = shiftInfo['ShiftClientId'] ?? " ";
        shiftCompanyId = shiftInfo['ShiftCompanyId'] ?? " ";
        shiftCompanyBranchId = shiftInfo['ShiftCompanyBranchId'] ?? " ";
        shiftName = shiftInfo['ShiftName'] ?? " ";
        ShiftDate = shiftInfo['ShiftDate'] ?? "";
        //ShiftClientId  ShiftCompanyBranchId  // ShiftCompanyId //ShiftDate

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
