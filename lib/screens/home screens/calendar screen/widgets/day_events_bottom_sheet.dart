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
    bool isDateAfterToday(DateTime date) {
      DateTime today = DateTime.now();
      DateTime justToday = DateTime(today.year, today.month, today.day);
      return date.isAfter(justToday);
    }

    bool isDateISToday(DateTime date) {
      DateTime today = DateTime.now();
      DateTime justToday = DateTime(today.year, today.month, today.day);
      DateTime justDate = DateTime(date.year, date.month, date.day);
      return justDate.isAtSameMomentAs(justToday);
    }

    bool isToday = isDateISToday(widget.day);
    print('isToday: $isToday');
    bool canExchangeRequest = isDateAfterToday(widget.day);

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) {
        return widget.events.isEmpty
            ? Center(
                child: InterMedium(
                text: 'No shifts on this day',
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontsize: 18.sp,
              ))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 18.w,
                        top: 16.h,
                        bottom: 16.h,
                      ),
                      child: Column(
                        children: [
                          InterMedium(
                            text: widget.day.format('dd/MM/yy'),
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
                          ),
                          SizedBox(height: 30.h),
                          InterMedium(
                            text: 'My shifts',
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                            fontsize: 20.sp,
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
                            event.others.isShiftRequested[0]
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ExchangeRequest(
                                              isRequest: false,
                                              exchangeId:
                                                  event.others.shiftRequestId!,
                                            )))
                                : !event.isShiftAcknowledgedByEmployee
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ShiftInformation(
                                                  empId: widget.empId,
                                                  currentUserId:
                                                      widget.currentUserId,
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
                            height: 100.h,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 4.h,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  color: event.isShiftAcknowledgedByEmployee
                                      ? Colors.green.shade700
                                      : (Theme.of(context).cardColor),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    width: 2,
                                    color: event.others.isShiftRequested[0]
                                        ? Colors.redAccent
                                        : Colors.transparent,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60.h,
                                      width: 4.w,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10.r),
                                            bottomRight: Radius.circular(10.r)),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Container(
                                      height: 50.h,
                                      width: 50.w,
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
                                          left: 14.w,
                                        ),
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
                                                fontsize: 16.sp,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              SizedBox(height: 8.h),
                                              IntrinsicHeight(
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          size: 10.sp,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium!
                                                                  .color,
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        InterMedium(
                                                          text: event.location,
                                                          fontsize: 14.sp,
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
                                                        fontsize: 14.sp,
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
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20.sp,
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
                        left: 18.w,
                        top: 16.h,
                        bottom: 16.h,
                      ),
                      child: InterMedium(
                        text: 'Others',
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontsize: 20.sp,
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
                              context, event, canExchangeRequest, isToday
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

  Widget createWidget(BuildContext context, CalendarEventModel event,
      bool canExchangeRequest, bool isToday) {
    print('inside create widget');
    if (event.others.ids.isEmpty) {
      print('return empty container');
      return Container();
    }

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
                      isToday: isToday,
                      canExchangeRequest: canExchangeRequest,
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
          height: 100.h,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: event.others.isExchangeRequested![0]
                      ? Colors.redAccent
                      : Colors.transparent,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Container(
                    height: 60.h,
                    width: 4.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.r),
                        bottomRight: Radius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    height: 50.h,
                    width: 50.w,
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
                      padding: EdgeInsets.only(left: 12.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InterSemibold(
                              text: event.others.othersShiftName,
                              fontsize: 16.sp,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                            SizedBox(height: 8.h),
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 10.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                      SizedBox(width: 4.w),
                                      InterMedium(
                                        text: event.others.othersShiftLocation,
                                        fontsize: 14.sp,
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
                                      fontsize: 14.sp,
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
                    padding: EdgeInsets.only(right: 10.w),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 20.sp,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShiftInformation(
                          isToday: isToday,
                          canExchangeRequest: canExchangeRequest,
                          toAccept: event.others.isExchangeRequested![index],
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
                              isToday: isToday,
                              canExchangeRequest: canExchangeRequest,
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
  ) {
    return SizedBox(
      height: 100.h,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 4.h,
        ),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              )
            ],
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.r),

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
                height: 60.h,
                width: 4.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                height: 50.h,
                width: 50.w,
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
                  padding: EdgeInsets.only(left: 12.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterSemibold(
                          text: shiftName,
                          fontsize: 16.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 8.h),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 10.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                  SizedBox(width: 4.w),
                                  InterMedium(
                                    text: shiftLocation,
                                    fontsize: 14.sp,
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
                                  fontsize: 14.sp,
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
                padding: EdgeInsets.only(right: 10.w),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20.sp,
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
