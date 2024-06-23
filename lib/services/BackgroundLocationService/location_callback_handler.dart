import 'dart:async';
import 'package:background_locator_2/location_dto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'location_service_repo.dart';

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    // Initialize Firebase
    // if (Firebase.apps.isEmpty) {
    //   print('Firebase App is not initialized');
    // Check if Firebase App is initialized
    await Firebase.initializeApp();
    // } else {
    //   print('Firebase App is already initialized');
    // }
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    // await Future.delayed(Duration(seconds: 30));
    await myLocationCallbackRepository.callback(locationDto);
  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}
