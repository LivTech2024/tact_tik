import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

final today = DateUtils.dateOnly(DateTime.now());
  
class CustomCalendar extends StatefulWidget {
  final List<DateTime?> selectedDates;
  const CustomCalendar({Key? key, required this.selectedDates})
      : super(key: key);

  @override
  State<CustomCalendar> createState() => _CustomCalenderState();
}

class _CustomCalenderState extends State<CustomCalendar> {
  // Get Thia List From Screen..
  List<DateTime?> _selectedDates = [];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              )
            ],
            color:  Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: isDark?ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary:  Color(0xFFCBA76B), // Background color
                onPrimary:
                    const Color(0xFF704600), // Text color for selected dates
              ),
            ):ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary:  LightColor.Primarycolorlight, // Background color
                onPrimary:
                    LightColor.Primarycolor, // Text color for selected dates
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
                      color:  Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    selectedYearTextStyle: TextStyle(
                      color:  Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    selectedDayHighlightColor:isDark? Color(0xFF704600):LightColor.Primarycolor,
                    currentDate: DateTime.now(),
                    selectableDayPredicate: _selectableDayPredicate,
                    dayBorderRadius: BorderRadius.circular(
                        width / width50), // Set day border radius
                  ),
                  value: widget.selectedDates,
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
        SizedBox(height: height / height25),
        InterBold(
          text: 'Weekly Shifts',
          fontsize: width / width18,
          color:  Theme.of(context).textTheme.bodyLarge!.color,
        )
      ],
    );
  }

  bool _selectableDayPredicate(DateTime date) {
    // You can customize the predicate to allow or disallow specific dates to be selectable
    return false; // Disallow all dates to be selectable
  }
}
