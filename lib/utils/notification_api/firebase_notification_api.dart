import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tact_tik/main.dart';

class FirebaseNotificationApi {
  final _firebase_messaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    //request permissions
    await _firebase_messaging.requestPermission();

    final FCMToken = await _firebase_messaging.getToken();

    print("Firebase Notification TOken");
    print('Token ${FCMToken}');

    initPushNotification();
  }

  //Handle Inapp route based on Message notification
  void handleMessage(RemoteMessage? message) {
    print('Received a message while in the foreground: ${message}');
    if (message == null) return;
    // navigatorKey.currentState
    //     ?.pushNamed('/notification_screen', arguments: message);

    if (message == '/notification_screen') {
    } else if (message == '/wellness_check') {
      // navigatorKey.currentState
      //     ?.pushNamed('/wellness_chec', arguments: message);
    }
  }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessage));

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onMessage.listen(handleMessage);
  }
}
