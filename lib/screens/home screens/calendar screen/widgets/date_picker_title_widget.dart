import 'package:flutter/material.dart';
import 'package:tact_tik/screens/home%20screens/calendar%20screen/utills/extensions.dart';

import '../res/colors.dart';
import '../utills/constants.dart';

class DatePickerTitle extends StatelessWidget {
  const DatePickerTitle({
    required this.date,
    super.key,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          date.format(kMonthFormatWidthYear),
          style:  TextStyle(
            fontSize: 21,
            color: Theme.of(context).textTheme.bodyMedium!.color,
            fontWeight: FontWeight.w500,
          ),
        ));
  }
}
