// import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/offlineScreen.dart';
import 'package:tact_tik/screens/SideBar%20Screens/employment_letter.dart';
import 'package:tact_tik/screens/SideBar%20Screens/profile_screen.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/report_checkpoint_screen.dart';
import 'package:tact_tik/screens/feature%20screens/post_order.dart/post_order_screen.dart';
import 'package:tact_tik/screens/feature%20screens/task/task_feature_screen.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/visitors.dart';

import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_create_assign_asset.dart';
// import 'package:tact_tik/screens/home%20screens/message%20screen/message_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/patrol_logs.dart';
import 'package:tact_tik/screens/view/app_view.dart';
// import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Tact Tik',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: OfflineBuilder(
          connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
          ) {
            final bool isConnected = connectivity != ConnectivityResult.none;
            if (isConnected) {
              return child;
            } else {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'No internet connection. Connect to Internet or Restart the app',
                    style: TextStyle(
                      fontSize: 20, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Add bold font weight
                      color: Colors.white, // Change text color to red
                    ),
                  ),
                ),
              );
              // return OfflineScreen();
            }
          },
          child: ReportCheckpointScreen(),
        ),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Tact Tik',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         textTheme: GoogleFonts.poppinsTextTheme(
//           Theme.of(context).textTheme,
//         ),
//       ),
//       home: GetStartedScreens(),
//     );
//   }
// }
