import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';

extension TimeOfDayExtension on TimeOfDay {
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

extension DateTimeExtension on DateTime {
  bool isBeforeTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return this.isBefore(targetTime) || this.isBefore(today);
  }
}
class SetDetailsWidget extends StatelessWidget {
  const SetDetailsWidget({
    super.key,
    required this.hintText,
    required this.icon,
    this.featureIndex = 0,
  });

  final String hintText;
  final IconData icon;
  final int featureIndex;




  Future<List<TimeOfDay>?> showCustomTimePicker(BuildContext context) async {
    List<TimeOfDay> selectedTimes = [];
    bool validTimesSelected = false;

    do {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Primarycolor, // Change primary color to red
                secondary: Primarycolor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        selectedTimes.add(selectedTime);
        if (selectedTimes.length == 2) {
          validTimesSelected = true;
        }
      } else {
        // If user cancels, exit the loop
        validTimesSelected = true;
      }
    } while (!validTimesSelected);

    return selectedTimes.isNotEmpty ? selectedTimes : null;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      height: 50,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(
            color: color19,
          ),
        ),
      ),
      margin: EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              Icon(
                icon,
                size: 24,
                color: color1,
              ),
              SizedBox(width: 10),
              featureIndex == 0
                  ? Expanded(
                      child: TextField(
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w300,
                          fontSize: width / width18,
                          color: Colors.white, // Change text color to white
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(
                              Radius.circular(width / width10),
                            ),
                          ),
                          focusedBorder: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w300,
                            fontSize: width / width18,
                            color: color2, // Change text color to white
                          ),
                          hintText: hintText,
                          contentPadding: EdgeInsets.zero, // Remove padding
                        ),
                        cursorColor: Primarycolor,
                      ),
                    )
                  : featureIndex == 1
                      ? GestureDetector(
                          onTap: () async {
                            DateTime? datePicked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(3000),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary:
                                          Primarycolor, // Change primary color to red
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                          },
                          child: InterMedium(
                            text: hintText,
                            fontsize: width / width18,
                            color: color25,
                          ),
                        )
                      : featureIndex == 2
                          ? GestureDetector(
                              onTap: () async {
                                final selectedTime = await showCustomTimePicker(context);
                                print('Selected times: $selectedTime');
                              },
                              child: InterMedium(
                                text: hintText,
                                fontsize: width / width18,
                                color: color25,
                              ),
                            )
                          : SizedBox(),
            ],
          )
        ],
      ),
    );
  }
}
