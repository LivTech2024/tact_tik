import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

int elapsedSeconds = 0;
bool isPaused = false;

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  isPaused = prefs.getBool('isPaused') ?? false;

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    elapsedSeconds = 0;
    service.stopSelf();
  });

  service.on('pauseStopwatch').listen((event) async {
    isPaused = true;
    await prefs.setBool('isPaused', isPaused);
  });

  service.on('resumeStopwatch').listen((event) async {
    isPaused = false;
    await prefs.setBool('isPaused', isPaused);
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Shift is On",
          content: "Click here to end the shift!",
        );
      }
    }

    if (!isPaused) {
      elapsedSeconds++;
    }

    final hours = (elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    final formattedTime = "$hours:$minutes:$seconds";

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "elapsed_time": formattedTime,
      },
    );
  });
}

class StopWatchBackgroundService extends GetxController {
  static StopWatchBackgroundService get instance => Get.find();

  /// variables
  RxBool stopWatchRunning = false.obs;
  RxBool isPaused = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeService();
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isPaused.value = prefs.getBool('isPaused') ?? false;
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: false,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    await checkService(service);
  }

  Future<void> checkService(FlutterBackgroundService service) async {
    var isRunning = await service.isRunning();
    stopWatchRunning.value = isRunning;
  }

  Future<void> startStopWatch() async {
    print('start/stop watch function ');
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke("stopStopwatch");
      service.invoke("stopService");
      stopWatchRunning.value = false;
      isPaused.value = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPaused', false);
    } else {
      service.startService();
      stopWatchRunning.value = true;
      isPaused.value = false;
    }
  }

  Future<void> pauseStopWatch() async {
    final service = FlutterBackgroundService();
    service.invoke("pauseStopwatch");
    isPaused.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPaused', false);
  }

  Future<void> resumeStopWatch() async {
    final service = FlutterBackgroundService();
    service.invoke("resumeStopwatch");
    isPaused.value = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPaused', false);
  }
}
