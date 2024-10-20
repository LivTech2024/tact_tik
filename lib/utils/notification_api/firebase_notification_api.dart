import 'dart:convert';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
// import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/message%20screen/widgets/info.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

class FirebaseNotificationApi {
  final _firebase_messaging = FirebaseMessaging.instance;
  FireStoreService fireStoreService = FireStoreService();
  // final LocalStorage storage;
  final androidChannel = const AndroidNotificationChannel(
      "high_importance_channel", "High Importance Notification",
      description: 'local Noti', importance: Importance.defaultImportance);
  // FirebaseNotificationApi() : storage = LocalStorage('currentUserEmail');
  final _localnotification = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    //request permissions
    await _firebase_messaging.requestPermission();
    await Permission.location.request();
    await Permission.locationAlways.request();
    await Permission.locationWhenInUse.request();
    // final status = await AppTrackingTransparency.requestTrackingAuthorization();
    // if (await AppTrackingTransparency.trackingAuthorizationStatus ==
    //     TrackingStatus.notDetermined) {
    //   // Show a custom explainer dialog before the system dialog
    //   // await showDialog(context); //TODO: Handle the context to display the dailog box
    //   // Wait for dialog popping animation
    //   await Future.delayed(const Duration(milliseconds: 200));
    //   // Request system's tracking authorization dialog
    //   await AppTrackingTransparency.requestTrackingAuthorization();
    // }
    var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail2();
    if (userInfo != null) {
      String employeeId = userInfo['EmployeeId'];
      final FCMToken = await _firebase_messaging.getToken();
      fireStoreService.updateLoggedInNotifyFcmToken(
          loggedInUserId: employeeId, newNotifyFcmToken: FCMToken.toString());
      print('Token ${FCMToken}');
    }
    print("Firebase Notification TOken");
    // print('Token ${FCMToken}');

    initPushNotification();
  }

  //Handle Inapp route based on Message notification
  void handleMessage(RemoteMessage? message) {
    print('Received a message while in the foreground: ${message}');
    // if (message == null) return;
    // navigatorKey.currentState
    //     ?.pushNamed('/notification_screen', arguments: message);

    // if (message == '/notification_screen') {
    // } else if (message == '/wellness_check') {
    //   navigatorKey.currentState
    //       ?.pushNamed('/wellness_chec', arguments: message);
    // }
    if (message?.data['route'] != null) {
      String route = message?.data['route'];
      print("Route from Message ${route}");
      navigatorKey.currentState?.pushNamed(route, arguments: message);
    }
  }
// AIzaSyDd_MBd7IV8MRQKpyrhW9O1BGLlp-mlOSc
  // void _storeNotification(String? title, String? body) async {
  //   // prit
  //   var box = Hive.box('notifications');
  //   var notification = {
  //     'title': title ?? 'No Title',
  //     'body': body ?? 'No Body',
  //     'timestamp': DateTime.now().toIso8601String(),
  //   };
  //   await box.add(notification);
  // }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessage));
    FirebaseMessaging.onMessage.listen((message) {
      // handleMessage(message);
      final notification = message.notification;
      if (notification == null) return;
      // _storeNotification(notification.title, notification.body);
      _localnotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()));
      Get.dialog(
        AlertDialog(
          title: Text(notification.title ?? 'Notification'),
          content: Text(notification.body ?? 'You have a new notificp ation'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
    // showDialog(context: context, builder: builder)
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );
    // FirebaseMessaging.onMessage.listen(handleMessage);
  }
}
