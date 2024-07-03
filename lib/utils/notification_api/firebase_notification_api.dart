import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
      navigatorKey.currentState?.pushNamed(route, arguments: message);
    }
  }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessage));
    FirebaseMessaging.onMessage.listen((message) {
      // handleMessage(message);
      final notification = message.notification;
      if (notification == null) return;
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
          content: Text(notification.body ?? 'You have a new notification'),
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
        alert: true, sound: true, badge: true);
    // FirebaseMessaging.onMessage.listen(handleMessage);
  }
}
