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
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
       borderRadius: BorderRadius.circular(10.r),
        color:  Theme.of(context).cardColor,
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
                color: Theme.of(context).primaryColor,
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
                    color:  Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: InterMedium(
                      text: '$location',
                     fontsize: 14.sp,maxLines: 1,
                      color:  Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                  InterBold(
                    text: 'Client: $clientname',
                   fontsize: 14.sp,
                    color:  Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ],
              ),
            ],
          ),
          InterMedium(
            text: time,
            color:  Theme.of(context).textTheme.bodyMedium!.color,
            fontsize: 14.sp,
          ),
        ],
      ),
    );
  }
}
