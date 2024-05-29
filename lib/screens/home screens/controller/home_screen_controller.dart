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
    LocationDto? locationDto =
        (data != null) ? LocationDto.fromJson(data) : null;
    if (locationDto != null) {
      await _updateNotificationText(locationDto);
      lastLocation = locationDto;
    } else {
      print('Received null location data');
    }
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    if (data == null) {
      return;
    }

    await BackgroundLocator.updateNotificationText(
        title: "Background location",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");

    print('Location updated flutter: ${data.latitude}, ${data.longitude},');
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();

    print('Initialization done');
    final _isRunning = await BackgroundLocator.isServiceRunning();

    isRunning = _isRunning;

    print('Running ${isRunning.toString()}');
  }

  /// start Bg the location service
  Future<void> startBgLocationService() async {
    // try {
    print('start Bg location service');
    if (await _checkLocationPermission()) {
      await _startLocator();
      final _isRunning = await BackgroundLocator.isServiceRunning();
      print('Running ${_isRunning.toString()}');

      // isRunning = _isRunning;
      // lastLocation = null;
    } else {
      // show error
    }
    // } catch (e) {
    //   print(e);
    // }
  }

  Future<bool> _checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      var statusAlways = await Permission.locationAlways.request();
      if (statusAlways.isGranted) {
      } else {}
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {}

    return true;
  }

  Future<void> _startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  /// stop Bg the location service
  Future<void> stopBgLocationService() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    final _isRunning = await BackgroundLocator.isServiceRunning();
    isRunning = _isRunning;
  }
}
