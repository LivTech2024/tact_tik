import 'dart:ui' as ui;
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
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/SideBar%20Screens/profile_screen.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
import 'package:tact_tik/screens/client%20screens/client_home_screen.dart';
import 'package:tact_tik/screens/client%20screens/patrol/client_check_patrol_screen.dart';
import 'package:tact_tik/screens/client%20screens/patrol/client_open_patrol_screen.dart';
import 'package:tact_tik/screens/client%20screens/patrol/view_checkpoint_screen.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/logbook_screen.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/notification_screen.dart';
import 'package:tact_tik/screens/home%20screens/wellness_check_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/Report/s_report_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/Report/select_reports_guards.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_assets_view_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/select_assets_guards.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/dar/select_dar_guards.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/key%20management/s_key_managment_view_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/loogbook/select_loogbook_guards.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/panic/s_panic_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/create_post_order.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/s_post_order_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/all_schedules_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/Scheduling/select_guards_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:tact_tik/utils/constants.dart';
import 'package:tact_tik/utils/notification_api/firebase_notification_api.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Secondarycolor,
              body: Center(
                child: InterSemibold(
                  text:
                      'No internet connection.\nConnect to Internet or Restart the app',
                  fontsize: 20.sp,
                  color: color1,
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
