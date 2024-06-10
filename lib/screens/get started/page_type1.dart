import 'package:flutter/material.dart';
import 'package:tact_tik/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/sizes.dart';
import '../../fonts/poppins_regular.dart';
import '../../fonts/poppis_semibold.dart';
import '../../utils/colors.dart';

class PageType1 extends StatelessWidget {
  PageType1({
    super.key,
    required this.index,
  });

  final int index;
  List images = [
    'assets/images/g1.png',
    'assets/images/g2.png',
    'assets/images/g3.png',
    'assets/images/g4.png'
  ];

  List tittls = [
    'App For Security Guards',
    'Access Schedules',
    'Receive Post Orders',
    'Stay Connected'
  ];

  List description = [
    'Tacttik is designed to simplify your job as a\nsecurity guard so you can provide excellent\npatrol service.',
    'Easily confirm the shifts right within your\napp or pick up open shifts that match your\nschedule. Find out when, where, and how\nlong you are working ahead of time.',
    'Easily access clear instructions about the\npost site right within the app. Tacttik\nmobile app makes it easy to review\nthe important information on the go',
    'Get updates from your security team,\nabout reports, time clocks,\ncommunication and much more.'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 470.h,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(40.r),
                bottomLeft: Radius.circular(40.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 65.w,
                right: 65.w,
                top: 76.h,
                bottom: 144.h,
              ),
              child: SizedBox(
                height: 250.h,
                width: 300.w,
                // color: Colors.white,
                child: Image.asset(images[index]),
              ),
            ),
          ),
          SizedBox(
            height: 100.h,
          ),
          PoppinsSemibold(
            text: tittls[index],
            fontsize: 32.sp,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          SizedBox(height: 27.h),
          SizedBox(
            width: 54.w,
            child: Divider(
              height: 3,
            ),
          ),
          SizedBox(height: 30.h),
          PoppinsRegular(
            text: description[index],
          fontsize: 14.sp,
            color: Theme.of(context).textTheme.bodyLarge!.color,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
