import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

class UserService {
  FireStoreService fireStoreService = FireStoreService();
  String? shiftLocationId;
  String? shiftStartTime;
  String? shiftEndTime;
  String? shiftLocation;
  String? userName;
  UserService({required FireStoreService firestoreService});

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

        // String shiftName = shiftInfo['ShiftName'] ?? " ";
        // String shiftId = shiftInfo['ShiftId'] ?? " ";
      } else {
        print('Shift info not found');
      }
    } else {
      print('User info not found');
    }
  }
}
