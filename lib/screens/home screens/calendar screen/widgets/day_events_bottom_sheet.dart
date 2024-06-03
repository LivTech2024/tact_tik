import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/home%20screens/calendar%20screen/utills/extensions.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/widgets/customErrorToast.dart';
import '../../../../common/widgets/customToast.dart';
import '../pages/shift_information.dart';
import '../utills/constants.dart';

/// Draggable bottom sheet with events for the day.
class DayEventsBottomSheet extends StatelessWidget {
  const DayEventsBottomSheet({
    required this.screenHeight,
    required this.events,
    required this.day,
    super.key,
    required this.empId,
  });

  final String empId;
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
                color: color1,
                fontsize: width / width18,
              ))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: width / width18,
                        top: height / height16,
                        bottom: height / height16,
                      ),
                      child: InterMedium(
                        text: day.format('dd/MM/yy'),
                        color: color1,
                        fontsize: width / width20,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: controller,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        if (!event.isAssignedToCurrentUser) {
                          return Container();
                        }
                        return GestureDetector(
                          onTap: () {
                            !event.isShiftAcknowledgedByEmployee
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShiftInformation(
                                              empId: empId,
                                              shiftId: event.shiftId,
                                              startTime: event.startTime,
                                              endTime: event.endTime,
                                            )))
                                : showErrorToast(
                                    duration: const Duration(seconds: 3),
                                    context,
                                    'Shift already accepted');
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
                                  color: event.isShiftAcknowledgedByEmployee
                                      ? Colors.green.shade700
                                      : WidgetColor,
                                  borderRadius:
                                      BorderRadius.circular(width / width10),
                                  // border: Border.all(color: Colors.redAccent)
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  children: [
                                    Container(
                                      height: height / height60,
                                      width: width / width4,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                      ),
                                    ),
                                    SizedBox(width: width / width10),
                                    Container(
                                      height: height / height50,
                                      width: width / width50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Primarycolor,
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
                                            left: width / width14),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              InterSemibold(
                                                text: event.name,
                                                fontsize: width / width16,
                                                color: color1,
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
                                                          size: width / width10,
                                                          color: color1,
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width / width4),
                                                        InterMedium(
                                                          text: event.location,
                                                          fontsize:
                                                              width / width14,
                                                          color: color2,
                                                        ),
                                                      ],
                                                    ),
                                                    const VerticalDivider(
                                                      color: color1,
                                                      thickness: 1,
                                                    ),
                                                    Expanded(
                                                      child: InterMedium(
                                                        text:
                                                            '${event.startTime}-${event.endTime}',
                                                        fontsize:
                                                            width / width14,
                                                        color: color2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                        color: color1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: width / width18,
                        top: height / height16,
                        bottom: height / height16,
                      ),
                      child: InterMedium(
                        text: 'Others',
                        color: color1,
                        fontsize: width / width20,
                      ),
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        controller: controller,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];

                          // Create a common child widget for GestureDetector to avoid code repetition
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShiftInformation(
                                    startTime: event.others.startTime!,
                                    endTime: event.others.endTime!,
                                    toRequest: true,
                                    empId: empId,
                                    otherEmpId: event.others.ids.length > 1
                                        ? event.others.ids[index]
                                        : event.others.ids.first,
                                    shiftId: event.others.othersShiftId!,
                                  ),
                                ),
                              );
                            },
                            child: createWidget(
                              context,
                              event,
                              height,
                              width,
                            ),
                          );
                        }),
                    SizedBox(
                      height: height / height100,
                    )
                  ],
                ),
              );
      },
    );
  }

  Widget createWidget(BuildContext context, CalendarEventModel event,
      double height, double width) {
    if (event.others.ids.length > 1) {
      return Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: event.others.ids.length,
            itemBuilder: (context, index) {
              final id = event.others.ids[index];
              return createAnotherWidget(
                context,
                id,
                event.eventColor,
                event.others.othersShiftName,
                event.others.othersShiftLocation,
                event.others.startTime!,
                event.others.endTime!,
                height,
                width,
              );
            },
          ),
        ],
      );
    }
    if (event.others.ids.isEmpty) return Container();
    return SizedBox(
      height: height / height100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width / width16,
          vertical: height / height4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: WidgetColor,
            borderRadius: BorderRadius.circular(width / width10),

            /// TODO : Change the border color to red if the shift exchange is not assigned
            border: Border.all(
                color: false ? Colors.redAccent : Colors.transparent),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                height: height / height60,
                width: width / width4,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
              ),
              SizedBox(width: width / width10),
              Container(
                height: height / height50,
                width: width / width50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Primarycolor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/default.png'),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: width / width12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterSemibold(
                          text: event.others.othersShiftName,
                          fontsize: width / width16,
                          color: color1,
                        ),
                        SizedBox(height: height / height8),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: width / width10,
                                    color: color1,
                                  ),
                                  SizedBox(width: width / width4),
                                  InterMedium(
                                    text: event.others.othersShiftLocation,
                                    fontsize: width / width14,
                                    color: color2,
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: color1,
                                thickness: 1,
                              ),
                              Expanded(
                                child: InterMedium(
                                  text:
                                      '${event.others.startTime!} - ${event.others.endTime!}',
                                  fontsize: width / width14,
                                  color: color2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// TODO : get ID form here
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: event.others.ids.map((id) {
                            return Text(
                              id,
                              style: TextStyle(
                                fontSize: width / width14,
                                color: color2,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width / width10),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: width / width20,
                  color: color1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createAnotherWidget(
      BuildContext context,
      String id,
      Color eventColor,
      String shiftName,
      String shiftLocation,
      String startTime,
      String endTime,
      double height,
      double width) {
    return SizedBox(
      height: height / height100,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width / width16,
          vertical: height / height4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: WidgetColor,
            borderRadius: BorderRadius.circular(width / width10),

            /// TODO : Change the border color to red if the shift exchange is not assigned
            border: Border.all(
                color: false ? Colors.redAccent : Colors.transparent),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                height: height / height60,
                width: width / width4,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
              ),
              SizedBox(width: width / width10),
              Container(
                height: height / height50,
                width: width / width50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Primarycolor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/default.png'),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: width / width12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterSemibold(
                          text: shiftName,
                          fontsize: width / width16,
                          color: color1,
                        ),
                        SizedBox(height: height / height8),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: width / width10,
                                    color: color1,
                                  ),
                                  SizedBox(width: width / width4),
                                  InterMedium(
                                    text: shiftLocation,
                                    fontsize: width / width14,
                                    color: color2,
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: color1,
                                thickness: 1,
                              ),
                              Expanded(
                                child: InterMedium(
                                  text: '${startTime} - ${endTime}',
                                  fontsize: width / width14,
                                  color: color2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// TODO : get ID form here
                        Text(
                          id,
                          style: TextStyle(
                            fontSize: width / width14,
                            color: color2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: width / width10),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: width / width20,
                  color: color1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
