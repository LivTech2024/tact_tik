import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import '../res/colors.dart';

/// Widget that represents week days in row above calendar month view.
class WeekDaysWidget extends StatelessWidget {
  const WeekDaysWidget({
    required this.day,
    super.key,
  });

  /// [WeekDay] value from [WeekDaysBuilder].
  final WeekDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Center(
        child: InterMedium(
          text: describeEnum(day).substring(0, 1).toUpperCase(),
          color: violet.withOpacity(0.9),
        ),
      ),
    );
  }
}
