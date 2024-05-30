import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
// import 'package:tact_tik/screens/home%20screens/message%20screen/message_screen.dart';
// import 'package:workmanager/workmanager.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
  runApp(const MyApp());
}

bool isDark = false;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'First Method',
      // You can use the library anywhere in the app even in theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1),
      ),
      home: ProviderScope(
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
                return Scaffold(
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
            child: AuthChecker(),
          ),
        ),
      ),
    );
  }
}
