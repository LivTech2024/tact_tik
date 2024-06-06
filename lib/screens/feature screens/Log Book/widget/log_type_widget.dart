import 'package:flutter/material.dart';
import 'package:tact_tik/main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../common/enums/log_type_enums.dart';
import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class LogTypeWidget extends StatelessWidget {
  const LogTypeWidget(
      {super.key,
      required this.type,
      required this.clientname,
      required this.logtype,
      required this.location,
      required this.time});

  final LogBookEnum type;
  final String clientname;
  final String logtype;
  final String location;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: 90.h,
      width: double.maxFinite,
      decoration: BoxDecoration(
        boxShadow: [
         BoxShadow(
            color: isDark
                ? Colors.transparent
                : LightColor.color3.withOpacity(.05),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
       borderRadius: BorderRadius.circular(10.r),
        color:  isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                type == LogBookEnum.shift_start
                    ? Icons.directions_walk_rounded
                    : type == LogBookEnum.shift_end
                        ? Icons.directions_walk_rounded
                        : type == LogBookEnum.patrol_start
                            ? Icons.apartment_outlined
                            : type == LogBookEnum.patrol_end
                                ? Icons.apartment_outlined
                    : type == LogBookEnum.TotalWorkTime
                    ? Icons.av_timer
                    : type == LogBookEnum.check_point
                    ? Icons.qr_code_scanner
                    : type == LogBookEnum.shift_break
                    ? Icons.free_breakfast
                                : Icons.error,
                color:  isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                size: 24.sp,
              ),
              SizedBox(width: 30.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterMedium(
                    text: '$logtype',
                    fontsize: 14.sp,
                    color:  isDark ? DarkColor.color2 : LightColor.color3,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: InterMedium(
                      text: '$location',
                     fontsize: 14.sp,maxLines: 1,
                      color:  isDark ? DarkColor.color1 : LightColor.color3,
                    ),
                  ),
                  InterBold(
                    text: 'Client: $clientname',
                   fontsize: 14.sp,
                    color:  isDark ? DarkColor.color2 : LightColor.color3,
                  ),
                ],
              ),
            ],
          ),
          InterMedium(
            text: time,
            color:  isDark ? DarkColor.color1 : LightColor.color3,
            fontsize: 14.sp,
          ),
        ],
      ),
    );
  }
}
