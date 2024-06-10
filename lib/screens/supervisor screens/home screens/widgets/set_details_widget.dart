import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

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


    return Container(
      height: 60.h,
      width: double.maxFinite,
      decoration: BoxDecoration(
        // color: Colors.redAccent,
        borderRadius: BorderRadius.circular(10.r),
        border: Border(
          bottom: BorderSide(
            color: DarkColor.color19,
          ),
        ),
      ),
      margin: EdgeInsets.only(top: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10.w),
          Icon(
            icon,
            size: 24.w,
            color:  Theme.of(context).textTheme.bodyMedium!.color,
          ),
          SizedBox(width: 10.w),
          useTextField
              ? Expanded(
                  child: TextField(
                    keyboardType: keyboardType,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w300,
                      fontSize: 18.sp,
                      color:  Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .color, // Change text color to white
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.r),
                        ),
                      ),
                      focusedBorder: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        fontSize: 18.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color, // Change text color to white
                      ),
                      hintText: hintText,
                      contentPadding: EdgeInsets.zero, // Remove padding
                    ),
                    cursorColor:  Theme.of(context).textTheme.bodySmall!.color,
                    controller: controller,
                  ),
                )
              : GestureDetector(
                  onTap: onTap,
                  child: InterMedium(
                    text: hintText,
                    fontsize: 18.sp,
                    color:   Theme.of(context).highlightColor,
                  ),
                ),
        ],
      ),
    );
  }
}
