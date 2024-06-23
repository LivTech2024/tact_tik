import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import '../../main.dart';
import '../../screens/feature screens/petroling/eg_patrolling.dart';
import 'file_manager.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    //TODO change logs
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    await setLogLabel("start");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    await setLogLabel("end");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('$_count location in dart: ${locationDto.toString()}');
    // await Future.delayed(Duration(seconds: 30));
    // if ((_count) % 5 == 0 || _count == 1) {
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail2();
    if (userInfo != null) {
      String employeeId = userInfo['EmployeeId'];

      // Define the new location to be added
      Map<String, dynamic> newLocation = {
        'LocationCoordinates':
            GeoPoint(locationDto.latitude, locationDto.longitude),
        'LocationReportedAt': Timestamp.now(),
      };

      late UserService _userService;
      FireStoreService fireStoreService = FireStoreService();
      _userService = UserService(firestoreService: FireStoreService());
      print(_userService.ShiftId);
      print(_userService.employeeId);

      // Fetch the employee's current route document
      QuerySnapshot routeSnapshot = await FirebaseFirestore.instance
          .collection('EmployeeRoutes')
          .where('EmpRouteEmpId', isEqualTo: employeeId)
          // .where('EmpRouteShiftId', isEqualTo: _userService.ShiftId)ss
          .where('EmpRouteShiftStatus', isEqualTo: 'started')
          .get();

      if (routeSnapshot.docs.isNotEmpty) {
        // Assuming you only get one actisve route document per empzzzloyee
        DocumentReference routeDocRef = routeSnapshot.docs.first.reference;

        // Update the EmpRouteLocations array in the document
        await routeDocRef.update({
          'EmpRouteLocations': FieldValue.arrayUnion([newLocation])
        });

        print('Location added to employee route: $newLocation');
      } else {
        print('No active route found for employee: $employeeId');
      }
    } else {
      print('User info is null');
    }
    // }
    await setLogPosition(_count, locationDto);
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto.toJson());
    _count++;
  }

  static Future<void> setLogLabel(String label) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '------------\n$label: ${formatDateLog(date)}\n------------\n');
  }

  static Future<void> setLogPosition(int count, LocationDto data) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');
  }

  static double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}
