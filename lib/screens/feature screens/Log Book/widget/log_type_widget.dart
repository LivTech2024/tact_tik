import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../../../common/enums/log_type_enums.dart';
import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class LogTypeWidget extends StatelessWidget {
  const LogTypeWidget({
    Key? key,
    required this.logEnum,
    required this.clientName,
    required this.location,
    required this.logtype,
    required this.time,
  }) : super(key: key);

  final LogBookEnum logEnum;
  final Timestamp time;
  final String clientName;
  final String location;
  final String logtype;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    // Convert logtype string to LogBookEnum
    LogBookEnum logTypeEnum = logtype.toEnum();
    print('time = $time');

    return logEnum == LogBookEnum.TotalWorkTime
        ? Container(
            margin: EdgeInsets.only(top: height / height10),
            padding: EdgeInsets.symmetric(horizontal: width / width20),
            height: height / height90,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width / width10),
              color: DarkColor. WidgetColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/avg_pace.svg',
                      color: DarkColor. Primarycolor,
                      width: width / width24,
                    ),
                    SizedBox(width: width / width30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'Patrolling',
                          fontsize: width / width14,
                          color: DarkColor. color2,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: height / height5),
                          child: InterMedium(
                            text: 'Clark Place interior',
                            fontsize: width / width14,
                            color: DarkColor.color1,
                          ),
                        ),
                        InterBold(
                          text: 'Client: $clientName',
                          fontsize: width / width14,
                          color: DarkColor.color2,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InterMedium(
                      text: DateFormat('hh:mm a').format(time.toDate()),
                      color: DarkColor.color1,
                      fontsize: width / width14,
                    ),
                    InterBold(
                      text: '12 hr 36 mn',
                      color: DarkColor.color1,
                      fontsize: width / width14,
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container(
            margin: EdgeInsets.only(top: height / height10),
            padding: EdgeInsets.symmetric(horizontal: width / width20),
            height: height / height90,
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width / width10),
              color: DarkColor.WidgetColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      logTypeEnum == LogBookEnum.ShiftStarted
                          ? Icons.directions_walk_rounded
                          : logTypeEnum == LogBookEnum.ShiftEnd
                              ? Icons.directions_walk_rounded
                              : logTypeEnum == LogBookEnum.PatrolStart
                                  ? Icons.apartment_outlined
                                  : logTypeEnum == LogBookEnum.PatrolEnd
                                      ? Icons.apartment_outlined
                                      : logTypeEnum == LogBookEnum.CheckPoint
                                          ? Icons.qr_code_scanner
                                          : Icons.error,
                      color: DarkColor.Primarycolor,
                      size: width / width24,
                    ),
                    SizedBox(width: width / width30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: '$logtype',
                          fontsize: width / width14,
                          color: DarkColor.color2,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: height / height5),
                          child: SizedBox(
                            width: width / width140,
                            child: InterMedium(
                              text: '$location',
                              fontsize: width / width14,
                              color: DarkColor. color1,
                            ),
                          ),
                        ),
                        InterBold(
                          text: 'Client: $clientName',
                          fontsize: width / width14,
                          color: DarkColor. color2,
                        ),
                      ],
                    ),
                  ],
                ),

                //

                InterMedium(
                  text: DateFormat('hh:mm a').format(time.toDate()),
                  color: DarkColor.color1,
                  fontsize: width / width14,
                ),
              ],
            ),
          );
  }
}
