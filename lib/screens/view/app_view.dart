import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/screens/get%20started/getstarted_screen.dart';

import '../supervisor screens/home screens/Scheduling/all_schedules_screen.dart';
import '../supervisor screens/home screens/Scheduling/create_shedule_screen.dart';
import '../supervisor screens/home screens/Scheduling/select_guards_screen.dart';
import '../supervisor screens/home screens/s_home_screen.dart';

class AppView extends ConsumerWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Tact Tik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: AllSchedulesScreen(),
    );
  }
}
