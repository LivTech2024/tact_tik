import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/calendar%20screen/utills/extensions.dart';
import 'package:tact_tik/utils/colors.dart';

import '../pages/shift_information.dart';
import '../utills/constants.dart';

/// Draggable bottom sheet with events for the day.
class DayEventsBottomSheet extends StatelessWidget {
  const DayEventsBottomSheet({
    required this.screenHeight,
    required this.events,
    required this.day,
    super.key,
  });

  final List<CalendarEventModel> events;
  final DateTime day;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) {
        return events.isEmpty
            ? Center(
                child: InterMedium(
                text: 'No shifts on this day',
                color: isDark ? DarkColor.color1 : LightColor.color3,
                fontsize: width / width18,
              ))
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: controller,
                      itemCount: events.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: width / width18,
                              top: height / height16,
                              bottom: height / height16,
                            ),
                            child: InterMedium(
                              text: day.format('dd/MM/yy'),
                              color: isDark ? DarkColor.color1 : LightColor.color3,
                              fontsize: width / width20,
                            ),
                          );
                        } else {
                          final event = events[index - 1];
                          return GestureDetector(
                            onTap: () {
                              //   ShiftInformation
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShiftInformation()));
                            },
                            child: SizedBox(
                              height: height / height100,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / width16,
                                  vertical: height / height4,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius:
                                        BorderRadius.circular(width / width10),
                                    // border: Border.all(color: Colors.redAccent)
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    children: [
                                      Container(
                                        color: event.eventColor,
                                        width: width / width6,
                                      ),
                                      SizedBox(width: width / width10),
                                      Container(
                                        height: height / height50,
                                        width: width / width50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/default.png'),
                                            filterQuality: FilterQuality.high,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: width / width16),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InterSemibold(
                                                  text: 'Shift name....',
                                                  fontsize: width / width16,
                                                  color: isDark
                                                      ? DarkColor.color1
                                                      : LightColor.color3,
                                                ),
                                                SizedBox(
                                                    height: height / height8),
                                                IntrinsicHeight(
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            size:
                                                                width / width10,
                                                            color: isDark
                                                                ? DarkColor
                                                                    .color1
                                                                : LightColor
                                                                    .color3,
                                                          ),
                                                          SizedBox(
                                                              width: width /
                                                                  width4),
                                                          InterMedium(
                                                            text:
                                                                'Bangalore south',
                                                            fontsize:
                                                                width / width14,
                                                            color: isDark
                                                                ? DarkColor
                                                                    .color2
                                                                : LightColor
                                                                    .color2,
                                                          ),
                                                        ],
                                                      ),
                                                      VerticalDivider(
                                                        color: isDark
                                                            ? DarkColor.color1
                                                            : LightColor.color3,
                                                        thickness: 1,
                                                      ),
                                                      InterMedium(
                                                        text: '9:30am - '
                                                            '11:30am',
                                                        fontsize:
                                                            width / width14,
                                                        color: isDark
                                                            ? DarkColor.color2
                                                            : LightColor.color2,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: width / width10),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: width / width20,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      controller: controller,
                      itemCount: events.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: width / width18,
                              top: height / height16,
                              bottom: height / height16,
                            ),
                            child: InterMedium(
                              text: 'Others',
                              color: isDark ? DarkColor.color1 : LightColor.color3,
                              fontsize: width / width20,
                            ),
                          );
                        } else {
                          final event = events[index - 1];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShiftInformation(
                                            toRequest: true,
                                          )));
                            },
                            child: SizedBox(
                              height: height / height100,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: width / width16,
                                  vertical: height / height4,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isDark
                                          ? DarkColor.WidgetColor
                                          : LightColor.WidgetColor,
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
                                      border:
                                          Border.all(color: Colors.redAccent)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Row(
                                    children: [
                                      Container(
                                        color: event.eventColor,
                                        width: width / width6,
                                      ),
                                      SizedBox(width: width / width10),
                                      Container(
                                        height: height / height50,
                                        width: width / width50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'assets/images/default.png'),
                                            filterQuality: FilterQuality.high,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: width / width16),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InterSemibold(
                                                  text: 'Shift name....',
                                                  fontsize: width / width16,
                                                  color: isDark
                                                      ? DarkColor.color1
                                                      : LightColor.color3,
                                                ),
                                                SizedBox(
                                                    height: height / height8),
                                                IntrinsicHeight(
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            size:
                                                                width / width10,
                                                            color: isDark
                                                                ? DarkColor
                                                                    .color1
                                                                : LightColor
                                                                    .color3,
                                                          ),
                                                          SizedBox(
                                                              width: width /
                                                                  width4),
                                                          InterMedium(
                                                            text:
                                                                'Bangalore south',
                                                            fontsize:
                                                                width / width14,
                                                            color: isDark
                                                                ? DarkColor
                                                                    .color2
                                                                : LightColor
                                                                    .color2,
                                                          ),
                                                        ],
                                                      ),
                                                      VerticalDivider(
                                                        color: isDark
                                                            ? DarkColor.color1
                                                            : LightColor.color3,
                                                        thickness: 1,
                                                      ),
                                                      InterMedium(
                                                        text: '9:30am - '
                                                            '11:30am',
                                                        fontsize:
                                                            width / width14,
                                                        color: isDark
                                                            ? DarkColor.color2
                                                            : LightColor.color2,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: width / width10),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: width / width20,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: height / height100,
                    )
                  ],
                ),
              );
      },
    );
  }
}
