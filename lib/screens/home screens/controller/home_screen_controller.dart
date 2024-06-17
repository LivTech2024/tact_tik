import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import '../../../services/BackgroundLocationService/location_callback_handler.dart';
import '../../../services/BackgroundLocationService/location_service_repo.dart';

class HomeScreenController extends GetxController {
  static HomeScreenController get instance => Get.find();
  LocationDto? lastLocation;
  ReceivePort port = ReceivePort();
  late bool isRunning;

  @override
  void onInit() {
    super.onInit();
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
      (dynamic data) async {
        await updateUI(data);
        print('listening');
      },
    );
    initPlatformState();
  }

  Future<void> updateUI(dynamic data) async {
    await _updateNotificationText();
  }

  Future<void> _updateNotificationText() async {
    await BackgroundLocator.updateNotificationText(
        title: "Background location",
        msg: "${DateTime.now()}",
        bigMsg: "Background location service is running");
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
    isRunning = await BackgroundLocator.isServiceRunning();
    print('Running ${isRunning.toString()}');
  }

  /// start Bg the location service
  Future<void> startBgLocationService() async {
    try {
      print('start Bg location service');
      if (await _checkLocationPermission()) {
        await _startLocator();
        isRunning = await BackgroundLocator.isServiceRunning();
        print('Running ${isRunning.toString()}');
        lastLocation = null;
      } else {
        print("Location permission Error");
        // customErrorToast(
        //     "Location permission is required for background tracking.");
      }
    } catch (e) {
      print(e);
      // customErrorToast("An error occurred while starting location service: $e");
    }
  }

  Future<bool> _checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var statusAlways = await Permission.locationAlways.request();
      return statusAlways.isGranted;
    } else {
      if (status.isDenied) {
        // Handle permission denied
      } else if (status.isPermanentlyDenied) {
        // Handle permission permanently denied
        await openAppSettings();
      }
      return false;
    }
  }

  Future<void> _startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.HIGH,
            distanceFilter: 0,
            stopWithTerminate: false,
            showsBackgroundLocationIndicator: true),
        autoStop: false,
        androidSettings: const AndroidSettings(
          accuracy: LocationAccuracy.HIGH,
          interval: 5,
          distanceFilter: 0,
          client: LocationClient.google,
          androidNotificationSettings: AndroidNotificationSettings(
              notificationChannelName: 'Location tracking',
              notificationTitle: 'Start Location Tracking',
              notificationMsg: 'Track location in background',
              notificationBigMsg:
                  'Background location is on to keep the app up-to-date with your location. This is required for main features to work properly when the app is not running.',
              notificationIconColor: Colors.grey,
              notificationTapCallback:
                  LocationCallbackHandler.notificationCallback),
        ));
  }

  /// stop Bg the location service
  Future<void> stopBgLocationService() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    isRunning = await BackgroundLocator.isServiceRunning();
  }
}
