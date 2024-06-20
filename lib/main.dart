


import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';

// import 'package:tact_tik/screens/home%20screens/message%20screen/message_screen.dart';
// import 'package:workmanager/workmanager.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:tact_tik/utils/constants.dart';
import 'package:tact_tik/utils/notification_api/firebase_notification_api.dart';
import 'package:tact_tik/utils/theme_manager.dart';
import 'package:tact_tik/utils/themes.dart';

ThemeManager themeManager = ThemeManager();

// final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
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
  @override
  void initState() {
    themeManager.addListener(ThemeListerner);
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
            // navigatorKey: navigatorKey,
            // routes: {
            //   '/notification_screen': (context) => NotificationScreen(),
            //   '/wellness_check': (context) => WellnessCheckScreen(
            //         EmpName: '',
            //         EmpId: '',
            //       ),
            // },
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

/*
    return ScreenUtilInit(
      designSize: const ui.Size(430, 932),
      builder: (context, child) {
        return ProviderScope(
          child: GetMaterialApp(
            title: 'Tact Tik',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              textTheme: GoogleFonts.poppinsTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            home: child,
            // OfflineBuilder(
            //   connectivityBuilder: (
            //     BuildContext context,
            //     ConnectivityResult connectivity,
            //     Widget child,
            //   ) {
            //     final bool isConnected = connectivity != ConnectivityResult.none;
            //     if (isConnected) {
            //       return child;
            //     } else {
            //       return const Scaffold(
            //         body: Center(
            //           child: Text(
            //             'No internet connection. Connect to Internet or Restart the app',
            //             style: TextStyle(
            //               fontSize: 20, // Adjust the font size as needed
            //               fontWeight: FontWeight.bold, // Add bold font weight
            //               color: Colors.white, // Change text color to red
            //             ),
            //           ),
            //         ),
            //       );
            //       // return OfflineScreen();
            //     }
            //   },
            //   child: AuthChecker(),
            // ),
          ),
        );
      },
      child: AuthChecker(),
    );
  }
}
*/
/*ProviderScope(
        child: GetMaterialApp(
          title: 'Tact Tik',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          home: child,
          // OfflineBuilder(
          //   connectivityBuilder: (
          //     BuildContext context,
          //     ConnectivityResult connectivity,
          //     Widget child,
          //   ) {
          //     final bool isConnected = connectivity != ConnectivityResult.none;
          //     if (isConnected) {
          //       return child;
          //     } else {
          //       return const Scaffold(
          //         body: Center(
          //           child: Text(
          //             'No internet connection. Connect to Internet or Restart the app',
          //             style: TextStyle(
          //               fontSize: 20, // Adjust the font size as needed
          //               fontWeight: FontWeight.bold, // Add bold font weight
          //               color: Colors.white, // Change text color to red
          //             ),
          //           ),
          //         ),
          //       );
          //       // return OfflineScreen();
          //     }
          //   },
          //   child: AuthChecker(),
          // ),
        ),
      ),*/
// "default": "livtech-dbcf2"
// "default": "security-app-3b156"
