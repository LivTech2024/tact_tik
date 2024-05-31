import 'package:flutter/material.dart';
import 'package:cr_calendar/src/cr_calendar.dart';

import 'calendar screen/pages/calendar_page.dart';

class CalendarScreen extends StatelessWidget {
  final String companyId;
  final String employeeId;
  const CalendarScreen(
      {super.key, required this.companyId, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CalendarPage(
          companyId: companyId,
          employeeId: employeeId,
        ),
      ),
    );
  }
}
