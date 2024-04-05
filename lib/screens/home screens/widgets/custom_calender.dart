import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

final today = DateUtils.dateOnly(DateTime.now());

class CustomCalender extends StatefulWidget {
  const CustomCalender({Key? key}) : super(key: key);

  @override
  State<CustomCalender> createState() => _CustomCalenderState();
}

class _CustomCalenderState extends State<CustomCalender> {
  DateTime? selectedDate; // Variable to store the selected date

  String _getValueText(
      CalendarDatePicker2Type datePickerType, List<DateTime?> values) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null)
        .toString()
        .replaceAll('00:00:00.000', '');

    if (datePickerType == CalendarDatePicker2Type.multi) {
      valueText = values.isNotEmpty
          ? values
              .map((v) => v.toString().replaceAll('00:00:00.000', ''))
              .join(', ')
          : 'null';
    } else if (datePickerType == CalendarDatePicker2Type.range) {
      if (values.isNotEmpty) {
        final startDate = values[0].toString().replaceAll('00:00:00.000', '');
        final endDate = values.length > 1
            ? values[1].toString().replaceAll('00:00:00.000', '')
            : 'null';
        valueText = '$startDate to $endDate';
      } else {
        return 'null';
      }
    }

    return valueText;
  }

  List<DateTime?> _multiDatePickerValueWithDefaultValue = [
    DateTime(today.year, today.month, 1),
    DateTime(today.year, today.month, 5),
    DateTime(today.year, today.month, 14),
    DateTime(today.year, today.month, 17),
    DateTime(today.year, today.month, 25),
  ];
  void _onDateSelected(List<DateTime?> dates) {
    setState(() {
      _multiDatePickerValueWithDefaultValue = dates;
    });
    Navigator.pop(context, dates);
  }

  Widget _buildDefaultMultiDatePickerWithValue() {
    return Container(
      decoration: BoxDecoration(
        color: Primarycolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFFCBA76B), // Background color
            onPrimary: const Color(0xFF704600), // Text color for selected dates
          ),
          // textTheme: ThemeData.dark().textTheme.apply(
          //   displayColor: Colors.black, // Unselected text color
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.multi,
                // backgroundColor: const Color(0xFFCBA76B), // Background color
                selectedDayTextStyle: TextStyle(
                  color: Colors.white, // Selected date text color
                ),
                selectedYearTextStyle: TextStyle(
                  color: Colors.white, // Selected year text color
                ),
                selectedDayHighlightColor: const Color(0xFF704600),
                // Selected date highlight color
                currentDate: DateTime.now(),
                // Set current date
                selectableDayPredicate: (DateTime date) => true,
                // All days are selectable
                dayBorderRadius:
                    BorderRadius.circular(50), // Set day border radius
              ),
              value: _multiDatePickerValueWithDefaultValue,
              onValueChanged: (dates) {
                setState(() {
                  _multiDatePickerValueWithDefaultValue = dates;
                  if (dates.isNotEmpty) {
                    // Update the selectedDate variable with the first date in the list
                    selectedDate = dates[0];
                  } else {
                    // If no date is selected, set selectedDate to null
                    selectedDate = null;
                  }
                });
              },
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDefaultMultiDatePickerWithValue();
  }
}
