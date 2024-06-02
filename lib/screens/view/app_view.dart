import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/riverpod/auth_provider.dart';
import 'package:tact_tik/screens/CustomePopUp/custompopup.dart';
import 'package:tact_tik/screens/authChecker/authChecker.dart';
import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';
import 'package:tact_tik/screens/home%20screens/wellness_check_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../utils/colors.dart';
import '../feature screens/Log Book/logbook_screen.dart';
import '../feature screens/Report/report_screen.dart';
import '../feature screens/dar/create_dar_screen.dart';
import '../feature screens/petroling/eg_patrolling.dart';
import '../feature screens/petroling/patrolling.dart';
import '../home screens/shift_task_screen.dart';
import '../supervisor screens/home screens/Scheduling/all_schedules_screen.dart';
import '../supervisor screens/home screens/Scheduling/create_shedule_screen.dart';
import '../supervisor screens/home screens/Scheduling/select_guards_screen.dart';
import '../supervisor screens/home screens/s_home_screen.dart';

FireStoreService fireStoreService = FireStoreService();
FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
late SharedPreferences prefs;

class AppView extends ConsumerWidget {
  const AppView({Key? key}) : super(key: key);
  // static final GlobalKey<NavigatorState> navigatorKey =
  //     GlobalKey<NavigatorState>();
  final String companyId = "1iFPbYfBB1F6ymMEvEAt";

  static void showPopup(String message) {
    // navigatorKey.currentState?.overlay?.insert(
    //   OverlayEntry(
    //     builder: (context) => CustomPopup(message: message),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return FutureBuilder<int>(
    //   future: fireStoreService.wellnessFetch(
    //       companyId), // Replace companyId with your actual company ID
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       int interval = snapshot.data ?? 0;
    //       if (interval > 0) {
    //         // Use the interval value to set up your Timer and show the popup
    //         Timer.periodic(
    //           Duration(minutes: interval),
    //           (timer) {
    //             // Show popup alert
    //             showDialog(
    //               context: context,
    //               builder: (BuildContext context) {
    //                 return AlertDialog(
    //                   title: Text('Wellness Pop UP'),
    //                   content: Text(
    //                     'Please upload ur wellness report.',
    //                     style: TextStyle(color: Colors.white),
    //                   ),
    //                   actions: <Widget>[
    //                     TextButton(
    //                       child: Text('Close'),
    //                       onPressed: () {
    //                         Navigator.of(context).pop();
    //                       },
    //                     ),
    //                     TextButton(
    //                       child: Text('Open'),
    //                       onPressed: () {
    //                         Navigator.push(
    //                             context,
    //                             MaterialPageRoute(
    //                               builder: (context) =>
    //                                   const WellnessCheckScreen(),
    //                             ));
    //                       },
    //                     ),
    //                   ],
    //                 );
    //               },
    //             );
    //           },
    //         );
    //       }
    //     }

    return MaterialApp(
      title: 'Tact Tik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Primarycolor,
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: AuthChecker(),
    );
    // },
    // );
  }
}
