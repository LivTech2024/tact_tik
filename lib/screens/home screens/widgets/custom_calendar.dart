import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

final today = DateUtils.dateOnly(DateTime.now());

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({Key? key}) : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalenderState();
}

class _CustomCalenderState extends State<CustomCalendar> {


  // Get Thia List From Screen..
  List<DateTime?> _selectedDates = [
    DateTime(today.year, today.month, 1),
    DateTime(today.year, today.month, 5),
    DateTime(today.year, today.month, 14),
  ];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFFCBA76B), // Background color
                onPrimary: const Color(0xFF704600), // Text color for selected dates
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height / height10),
                CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    rangeBidirectional: true,
                    disableModePicker: true,
                    calendarType: CalendarDatePicker2Type.multi,
                    selectedDayTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                    selectedYearTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                    selectedDayHighlightColor: Color(0xFF704600),
                    currentDate: DateTime.now(),
                    selectableDayPredicate: _selectableDayPredicate,
                    dayBorderRadius: BorderRadius.circular(width / width50), // Set day border radius
                  ),
                  value: _selectedDates,
                  // onValueChanged: (List<DateTime?>? dates) {
                  //   if (dates != null) {
                  //     setState(() {
                  //       _selectedDates = List<DateTime?>.from(dates);
                  //     });
                  //   }
                  // },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: height/ height25),
        InterBold(text: 'Weekly Shifts' , fontsize: width / width18,color: Color(0xFFE9E9E9),)
      ],
    );
  }

  bool _selectableDayPredicate(DateTime date) {
    // You can customize the predicate to allow or disallow specific dates to be selectable
    return false; // Disallow all dates to be selectable
  }
}