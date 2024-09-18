import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Future<void> initializeTimezone() async {
//   tz.initializeTimeZones();
//   final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
//   tz.setLocalLocation(
//       tz.getLocation(timeZoneName)); // Ensure correct local timezone
// }

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {},
  );

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Initialize timezone
Future<void> initializeTimezone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local); // Use the device's local timezone
}

Future<void> testNotification() async {
  DateTime now = DateTime.now();
  DateTime scheduledTime = now.add(Duration(minutes: 1));

  await _scheduleSingleNotification(
    'test_notification_1min', // Unique ID for the test notification
    'Test Notification',
    'This is a test notification scheduled for 1 minute from now',
    scheduledTime,
  );

  print("Test notification scheduled for: $scheduledTime");
}

// Function to schedule the notifications for each shift
Future<void> scheduleNotification(String shiftId, String shiftName,
    String startTime, String endTime, DateTime shiftDate) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if notifications for this shift have already been scheduled
  bool isScheduled = prefs.getBool(shiftId) ?? false;

  if (!isScheduled) {
    // Convert start and end time strings ("HH:mm") into DateTime objects
    DateTime shiftStartDateTime = DateTime(
      shiftDate.year,
      shiftDate.month,
      shiftDate.day,
      int.parse(startTime.split(":")[0]),
      int.parse(startTime.split(":")[1]),
    );

    DateTime shiftEndDateTime = DateTime(
      shiftDate.year,
      shiftDate.month,
      shiftDate.day,
      int.parse(endTime.split(":")[0]),
      int.parse(endTime.split(":")[1]),
    );
    // Schedule notifications at different intervals
    await _scheduleSingleNotification(
        shiftId + '_1day',
        'Shift Reminder',
        'You have a shift: $shiftName tomorrow at $startTime',
        shiftStartDateTime.subtract(const Duration(days: 1)));

    await _scheduleSingleNotification(
        shiftId + '_1hour_before_start',
        'Shift Reminder',
        'Your shift: $shiftName starts in 1 hour at $startTime',
        shiftStartDateTime.subtract(const Duration(hours: 1)));

    await _scheduleSingleNotification(
        shiftId + '_1hour_before_end',
        'Shift Reminder',
        'Your shift: $shiftName ends in 1 hour at $endTime',
        shiftEndDateTime.subtract(const Duration(hours: 1)));

    // Mark the shift as scheduled in SharedPreferences
    await prefs.setBool(shiftId, true);
  }
}

// Function to schedule a single notification
Future<void> _scheduleSingleNotification(
    String id, String title, String body, DateTime scheduledTime) async {
  // Convert DateTime to TZDateTime
  final tz.TZDateTime tzScheduledTime =
      tz.TZDateTime.from(scheduledTime, tz.local);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'shift_channel_id',
    'Shift Notifications',
    channelDescription: 'Notifications for scheduled shifts',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Schedule the notification if the time is in the future
  if (scheduledTime.isAfter(DateTime.now())) {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode, // Unique ID for the notification
      title,
      body,
      tzScheduledTime, // Use TZDateTime for the scheduled time
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}