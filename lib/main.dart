import 'dart:io';
import 'dart:ui' as ui;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:tact_tik/common/widgets/guard_alert_widget.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/SideBar%20Screens/pay_discrepancy_display.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:tact_tik/screens/home%20screens/guard_notification_screen.dart';
import 'package:tact_tik/screens/home%20screens/notification_screen.dart';
import 'package:tact_tik/screens/home%20screens/wellness_check_screen.dart';
import 'package:tact_tik/utils/constants.dart';
import 'package:tact_tik/utils/notification_api/firebase_notification_api.dart';
import 'package:tact_tik/utils/theme_manager.dart';
import 'package:tact_tik/utils/themes.dart';

ThemeManager themeManager = ThemeManager();

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // await Hive.initFlutter();
  // await Hive.openBox('notifications');
  await FirebaseAppCheck.instance.activate(
    // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );

  //Fethcing FCM TOken
  await FirebaseNotificationApi().initNotifications();
  MapboxOptions.setAccessToken(appConstants.mapBoxPublicKey);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _authStatus = 'Unknown';
  @override
  void initState() {
    themeManager.addListener(ThemeListerner);
    // initPlugin();
    super.initState();
  }

  @override
  void dispose() {
    themeManager.removeListener(ThemeListerner);
    super.dispose();
  }

  ThemeListerner() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initPlugin() async {
    // if (Platform.isIOS) {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    print("AuthState $status");
    if (status == TrackingStatus.notDetermined) {
      await showCustomTrackingDialog(context);
      await Future.delayed(const Duration(milliseconds: 200));
      final TrackingStatus newStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$newStatus');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
    // }
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. We keep this app free by showing ads. '
            'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
            'Our partners will collect data and use a unique identifier on your device to show you ads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ScreenUtilInit(
      designSize: const ui.Size(430, 932),
      builder: (context, child) {
        return ProviderScope(
          child: GetMaterialApp(
            title: 'Tact Tik',
            debugShowCheckedModeBanner: false,
            theme: ligthTheme,
            darkTheme: darkTheme,
            themeMode: themeManager.themeMode,
            navigatorKey: navigatorKey,
            routes: {
              '/notification_screen': (context) => NotificationScreen(),
              '/wellness_check': (context) => WellnessCheckScreen(
                    EmpName: '',
                    EmpId: '',
                  ),
              '/alert_screen': (ontext) => GuardNotificationScreen(
                    employeeId: '',
                    companyId: '',
                  )
            },
            home: child,
          ),
        );
      },
      child: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          final bool isConnected = connectivity != ConnectivityResult.none;
          if (isConnected) {
            return child;
          } else {
            return Scaffold(
              body: Center(
                child: InterSemibold(
                  text:
                      'No internet connection.\nConnect to Internet or Restart the app',
                  fontsize: 20.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            );
          }
        },
        child: AuthChecker(),
      ),
    );
  }
}
// "default": "livtech-dbcf2"
// "default": "security-app-3b156" 
