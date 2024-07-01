import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';
import '../calendar_screen.dart';

final today = DateUtils.dateOnly(DateTime.now());

class CustomCalendar extends StatefulWidget {
  final List<DateTime?> selectedDates;

  const CustomCalendar(
      {Key? key,
      required this.selectedDates,
      this.employeeCompanyID,
      this.employeeId})
      : super(key: key);
  final employeeCompanyID;
  final employeeId;

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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Theme(
            data: Theme.of(context).brightness == Brightness.dark
                ? ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Color(0xFFCBA76B), // Background color
                      onPrimary: const Color(
                          0xFF704600), // Text color for selected dates
                    ),
                  )
                : ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: LightColor.Primarycolorlight, // Background color
                      onPrimary: LightColor
                          .Primarycolor, // Text color for selected dates
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
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    selectedDayHighlightColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? DarkColor.Primarycolor
                            : LightColor.Primarycolor,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InterBold(
              text: 'Weekly Shifts',
              fontsize: width / width18,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
            SizedBox(
              width: 130,
              child: Button1(
                height: 40.h,
                borderRadius: 10.r,
                fontsize: 15.sp,
                color: Colors.white,
                backgroundcolor: Theme.of(context).primaryColor,
                  text: 'Advance Mode',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalendarScreen(
                                companyId: widget.employeeCompanyID,
                                employeeId: widget.employeeId)));
                  }),
            )
          ],
        )
      ],
    );
  }

  bool _selectableDayPredicate(DateTime date) {
    // You can customize the predicate to allow or disallow specific dates to be selectable
    return false; // Disallow all dates to be selectable
  }
}
