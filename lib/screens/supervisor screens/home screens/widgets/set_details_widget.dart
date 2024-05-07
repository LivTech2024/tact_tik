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
    final targetTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return this.isBefore(targetTime) || this.isBefore(today);
  }
}

class SetDetailsWidget extends StatelessWidget {
  SetDetailsWidget({
    super.key,
    required this.hintText,
    this.icon,
    this.controller,
    this.useTextField = false,
    required this.onTap,
    this.keyboardType,
  });

  final String hintText;
  final IconData? icon;
  final bool useTextField;
  final TextEditingController? controller;
  final VoidCallback onTap;
  String? selectedLocation;
  final TextInputType? keyboardType;
  final List<String> suggestions = ['Location 1', 'Location 2', 'Location 3'];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      height: height / height60,
      width: double.maxFinite,
      decoration: BoxDecoration(
        // color: Colors.redAccent,
        borderRadius: BorderRadius.circular(width / width10),
        border: Border(
          bottom: BorderSide(
            color: color19,
          ),
        ),
      ),
      margin: EdgeInsets.only(top: height / height10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: width / width10),
          Icon(
            icon,
            size: width / width24,
            color: color1,
          ),
          SizedBox(width: width / width10),
          useTextField
              ? Expanded(
                  child: TextField(
                    keyboardType: keyboardType,
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
                    controller: controller,
                  ),
                )
              : GestureDetector(
                  onTap: onTap,
                  child: InterMedium(
                    text: hintText,
                    fontsize: width / width18,
                    color: color25,
                  ),
                ),
        ],
      ),
    );
  }
}
