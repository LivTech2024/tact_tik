import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/Report/s_report_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/Report/select_reports_guards.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/s_assets_view_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/key%20management/s_key_managment_view_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/panic/s_panic_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/create_post_order.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/s_post_order_screen.dart';
import 'package:tact_tik/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  MapboxOptions.setAccessToken(appConstants.mapBoxPublicKey);
  // Get.put(LocationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          home: AuthChecker()
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
  }
}
