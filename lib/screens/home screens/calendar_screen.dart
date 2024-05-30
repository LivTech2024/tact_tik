import 'package:flutter/material.dart';
import 'package:cr_calendar/src/cr_calendar.dart';

import 'calendar screen/pages/calendar_page.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CalendarPage(),
      ),
    );
  }
}
