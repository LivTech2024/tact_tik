import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../common/enums/log_type_enums.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';

class LogTypeWidget extends StatelessWidget {
  const LogTypeWidget({
    super.key,
    required this.type,
    required this.clientname,
    required this.logtype,
    required this.location,
    required this.time,
    required this.shiftName,
    required this.patrolName,
    required this.checkPointName,
  });

  final LogBookEnum type;
  final String clientname;
  final String logtype;
  final String location;
  final String time;
  final String shiftName;
  final String patrolName;
  final String checkPointName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: 150.h, // Increased height to accommodate additional fields
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
        color: type == LogBookEnum.shift_start
            ? const Color(0xFF0A5531)
            : type == LogBookEnum.patrol_start
                ? const Color(0xFF0A5531)
                : type == LogBookEnum.shift_end
                    ? const Color(0xFF9A1010)
                    : type == LogBookEnum.patrol_end
                        ? const Color(0xFF9A1010)
                        : Theme.of(context).cardColor,
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
                    color: type == LogBookEnum.shift_start
                        ? Colors.white
                        : type == LogBookEnum.patrol_start
                            ? Colors.white
                            : type == LogBookEnum.shift_end
                                ? Colors.white
                                : type == LogBookEnum.patrol_end
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                  ),
                  location.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          child: SizedBox(
                            width: 200.w,
                            child: InterMedium(
                              text: '$location',
                              fontsize: 14.sp,
                              maxLines: 1,
                              color: type == LogBookEnum.shift_start
                                  ? Colors.white
                                  : type == LogBookEnum.patrol_start
                                      ? Colors.white
                                      : type == LogBookEnum.shift_end
                                          ? Colors.white
                                          : type == LogBookEnum.patrol_end
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    width: 200.w,
                    child: InterBold(
                      text: 'Client: $clientname',
                      fontsize: 14.sp,
                      color: type == LogBookEnum.shift_start
                          ? Colors.white
                          : type == LogBookEnum.patrol_start
                              ? Colors.white
                              : type == LogBookEnum.shift_end
                                  ? Colors.white
                                  : type == LogBookEnum.patrol_end
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                    ),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: InterBold(
                      text: 'Shift: $shiftName',
                      fontsize: 14.sp,
                      color: type == LogBookEnum.shift_start
                          ? Colors.white
                          : type == LogBookEnum.patrol_start
                              ? Colors.white
                              : type == LogBookEnum.shift_end
                                  ? Colors.white
                                  : type == LogBookEnum.patrol_end
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                    ),
                  ),
                  if (patrolName.isNotEmpty)
                    SizedBox(
                      width: 200.w,
                      child: InterBold(
                        text: 'Patrol: $patrolName',
                        fontsize: 14.sp,
                        color: type == LogBookEnum.shift_start
                            ? Colors.white
                            : type == LogBookEnum.patrol_start
                                ? Colors.white
                                : type == LogBookEnum.shift_end
                                    ? Colors.white
                                    : type == LogBookEnum.patrol_end
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                      ),
                    ),
                  if (checkPointName.isNotEmpty)
                    SizedBox(
                      width: 200.w,
                      child: InterBold(
                        text: 'Checkpoint: $checkPointName',
                        fontsize: 14.sp,
                        color: type == LogBookEnum.shift_start
                            ? Colors.white
                            : type == LogBookEnum.patrol_start
                                ? Colors.white
                                : type == LogBookEnum.shift_end
                                    ? Colors.white
                                    : type == LogBookEnum.patrol_end
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                      ),
                    ),
                ],
              ),
            ],
          ),
          InterMedium(
            text: time,
            color: type == LogBookEnum.shift_start
                ? Colors.white
                : type == LogBookEnum.patrol_start
                    ? Colors.white
                    : type == LogBookEnum.shift_end
                        ? Colors.white
                        : type == LogBookEnum.patrol_end
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium!.color,
            fontsize: 14.sp,
          ),
        ],
      ),
    );
  }
}
