import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/calendar%20screen/pages/exchange_request.dart';
import 'package:tact_tik/screens/home%20screens/calendar%20screen/utills/extensions.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/widgets/customErrorToast.dart';
import '../../../../common/widgets/customToast.dart';
import '../pages/shift_information.dart';
import '../utills/constants.dart';

/// Draggable bottom sheet with events for the day.
class DayEventsBottomSheet extends StatefulWidget {
  const DayEventsBottomSheet({
    required this.screenHeight,
    required this.events,
    required this.day,
    super.key,
    required this.empId,
    required this.currentUserId,
  });

  final String empId;
  final List<CalendarEventModel> events;
  final DateTime day;
  final double screenHeight;
  final String currentUserId;

  @override
  State<DayEventsBottomSheet> createState() => _DayEventsBottomSheetState();
}

class _DayEventsBottomSheetState extends State<DayEventsBottomSheet> {
  String sendersShiftId = '';

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) {
        return widget.events.isEmpty
            ? Center(
                child: InterMedium(
                text: 'No shifts on this day',
                color: Theme.of(context).textTheme.bodyMedium!.color,
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
                      child: Column(
                        children: [
                          InterMedium(
                            text: widget.day.format('dd/MM/yy'),
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: width / width20,
                          ),
                          SizedBox(height: 30.h),
                          InterMedium(
                            text: 'My shifts',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: width / width20,
                          )
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: controller,
                      itemCount: widget.events.length,
                      itemBuilder: (context, index) {
                        final event = widget.events[index];

                        if (!event.isAssignedToCurrentUser) {
                          return Container();
                        }
                        sendersShiftId = event.shiftId;
                        return GestureDetector(
                          onTap: () {
                            print(
                                'event.others.shiftRequestId: ${event.others.shiftRequestId}');
                            !event.isShiftAcknowledgedByEmployee
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShiftInformation(
                                              empId: widget.empId,
                                              currentUserId:
                                                  widget.currentUserId,
                                              shiftId: event.shiftId,
                                              startTime: event.startTime,
                                              endTime: event.endTime,
                                            )))
                                : event.others.isShiftRequested[index]
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ExchangeRequest(
                                                  isRequest: false,
                                                  exchangeId: event
                                                      .others.shiftRequestId!,
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
                                        : (Theme.of(context).cardColor),
                                    borderRadius:
                                        BorderRadius.circular(width / width10),
                                    border: Border.all(
                                        width: 2,
                                        color: event.others.isShiftRequested[0]
                                            ? Colors.redAccent
                                            : Colors.transparent)),
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor,
                                        image: const DecorationImage(
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
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
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
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .color,
                                                        ),
                                                        SizedBox(
                                                            width:
                                                                width / width4),
                                                        InterMedium(
                                                          text: event.location,
                                                          fontsize:
                                                              width / width14,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color,
                                                        ),
                                                      ],
                                                    ),
                                                    VerticalDivider(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .color,
                                                      thickness: 1,
                                                    ),
                                                    Expanded(
                                                      child: InterMedium(
                                                        text:
                                                            '${event.startTime}-${event.endTime}',
                                                        fontsize:
                                                            width / width14,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color,
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
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
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
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontsize: width / width20,
                      ),
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        controller: controller,
                        itemCount: widget.events.length,
                        itemBuilder: (context, index) {
                          var event = widget.events[index];
                          print(widget.events.length);
                          print(index);
                          // print(event.others.isExchangeRequested!);
                          print(event.others.isShiftRequested);
                          // Create a common child widget for GestureDetector to avoid code repetition
                          return createWidget(
                            context,
                            event,
                            height,
                            width,
                            // true,
                            // event.others.isExchangeRequested![index],
                          );
                        }),
                    SizedBox(
                      height: 100.h,
                    )
                  ],
                ),
              );
      },
    );
  }

  Widget createWidget(
    BuildContext context,
    CalendarEventModel event,
    double height,
    double width,
  ) {
    print('inside create widget');
    if (event.others.ids.isEmpty) {
      print('return empty container');
      return Container();
    }
    ;

    if (event.others.ids.length == 1) {
      print('length is one');
      return GestureDetector(
        onTap: () {
          event.others.isExchangeRequested![0]
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ExchangeRequest(
                            exchangeId: event.others.exchangeId!,
                          )),
                )
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShiftInformation(
                      toAccept: event.others.isExchangeRequested![0],
                      startTime: event.others.startTime!,
                      endTime: event.others.endTime!,
                      toRequest: true,
                      empId: event.others.ids[0],
                      shiftId: event.others.othersShiftId!,
                      currentUserId: widget.currentUserId,
                      sendersShiftId: sendersShiftId,
                    ),
                  ),
                );
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(width / width10),
                border: Border.all(
                    color: event.others.isExchangeRequested![0]
                        ? Colors.redAccent
                        : Colors.transparent),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                      image: const DecorationImage(
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
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
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
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                      SizedBox(width: width / width4),
                                      InterMedium(
                                        text: event.others.othersShiftLocation,
                                        fontsize: width / width14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                    ],
                                  ),
                                  VerticalDivider(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                    thickness: 1,
                                  ),
                                  Expanded(
                                    child: InterMedium(
                                      text:
                                          '${event.others.startTime!} - ${event.others.endTime!}',
                                      fontsize: width / width14,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
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
                    padding: EdgeInsets.only(right: width / width10),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: width / width20,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      print('more than one ids ');
      return Column(
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: event.others.ids.length,
            itemBuilder: (context, index) {
              final id = event.others.ids[index];
              return GestureDetector(
                onTap: () {
                  if (sendersShiftId == '') {
                    showErrorToast(
                      duration: const Duration(seconds: 3),
                      context,
                      'You don\'t have any shift to exchange on today.',
                    );
                    return;
                  }
                  print(
                      'ShiftExchReceiverShiftId: ${event.others.othersShiftId}');

                  event.others.isExchangeRequested![index]
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExchangeRequest(
                                    exchangeId: event.others.exchangeId!,
                                  )),
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShiftInformation(
                              toAccept:
                                  event.others.isExchangeRequested![index],
                              startTime: event.others.startTime!,
                              endTime: event.others.endTime!,
                              toRequest: true,
                              empId: event.others.ids[index],
                              shiftId: event.others.othersShiftId!,
                              currentUserId: widget.currentUserId,
                              sendersShiftId: sendersShiftId,
                            ),
                          ),
                        );
                },
                child: createAnotherWidget(
                  event.others.isExchangeRequested![index],
                  context,
                  id,
                  event.eventColor,
                  event.others.othersShiftName,
                  event.others.othersShiftLocation,
                  event.others.startTime!,
                  event.others.endTime!,
                  height,
                  width,
                ),
              );
            },
          ),
        ],
      );
    }
  }

  Widget createAnotherWidget(
      bool isExchangeRequested,
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(width / width10),

            /// TODO : Change the border color to red if the shift exchange is not assigned
            border: Border.all(
                color: isExchangeRequested
                    ? Colors.redAccent
                    : Colors.transparent),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  image: const DecorationImage(
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
                          color: Theme.of(context).textTheme.bodyMedium!.color,
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                  SizedBox(width: width / width4),
                                  InterMedium(
                                    text: shiftLocation,
                                    fontsize: width / width14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ],
                              ),
                              VerticalDivider(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                                thickness: 1,
                              ),
                              Expanded(
                                child: InterMedium(
                                  text: '${startTime} - ${endTime}',
                                  fontsize: width / width14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// TODO : get ID form here
                        // Text(
                        //   id,
                        //   style: TextStyle(
                        //     fontSize: width / width14,
                        //     color: color2,
                        //   ),
                        // ),
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
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
