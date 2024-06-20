import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/widgets/button1.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';

class ExchangeRequest extends StatelessWidget {
  const ExchangeRequest({super.key, this.isRequest = true});

  final bool isRequest;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                InterBold(
                  text: isRequest
                      ? "Request From: guardName"
                      : "Exchange Request From: guardName",
                  fontsize: 18.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Shift Name : shiftName',
                  fontsize: 18.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Details',
                  fontsize: 16.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                SizedBox(height: 14.h),
                InterRegular(
                  text: 'shiftDetails',
                  fontsize: 14.sp,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  maxLines: 3,
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Supervisor :',
                      fontsize: 16.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 4.w),
                    InterRegular(
                      text: 'supervisorName',
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Time :',
                      fontsize: 16.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 4.w),
                    InterRegular(
                      text: 'widget.startTime}-widget.endTime}',
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 24.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 4.w),
                    InterRegular(
                      text: 'location',
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ],
                ),
                if (isRequest!)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50.h,
                            width: 110.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/exchange.svg',
                                width: 20.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50.h),
                      InterBold(
                        text: isRequest
                            ? "Request From: guardName"
                            : "Exchange Request From: guardName",
                        fontsize: 18.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 30.h),
                      InterBold(
                        text: 'Shift Name : shiftName',
                        fontsize: 18.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 30.h),
                      InterBold(
                        text: 'Details',
                        fontsize: 16.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 14.h),
                      InterRegular(
                        text: 'shiftDetails',
                        fontsize: 14.sp,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        maxLines: 3,
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InterBold(
                            text: 'Supervisor :',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(width: 4.w),
                          InterRegular(
                            text: 'supervisorName',
                            fontsize: 14.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          )
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InterBold(
                            text: 'Time :',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(width: 4.w),
                          InterRegular(
                            text: 'widget.startTime}-widget.endTime}',
                            fontsize: 14.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 24.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(width: 4.w),
                          InterRegular(
                            text: 'location',
                            fontsize: 14.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ],
                      ),
                    ],
                  ),

                IgnorePointer(
                  ignoring: /**condition clicked true* */ false /*Todo pass the bool of true and false*/,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button1(
                        text: isRequest ? 'Accept' : 'Exchange',
                        onPressed: () {
                          // if (isRequest) {
                          //   onExchangeShift(widget.empId, widget.shiftId);
                          // } else {
                          //   onAcceptShift(widget.empId, widget.shiftId);
                          // }
                        },
                        backgroundcolor: Theme.of(context).primaryColor,
                        // Todo apply this to the buttons when one of the button is clicked
                        // backgroundcolor: *condition clicked true* ? Theme.of(context).primaryColorLight :Theme.of(context).primaryColor,
                        borderRadius: 10.r,
                        fontsize: 18.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      Button1(
                        text: 'Reject',
                        onPressed: () {},
                        backgroundcolor: Theme.of(context).primaryColor,
                        // Todo apply this to the buttons when one of the button is clicked
                        // backgroundcolor: *condition clicked true* ? Theme.of(context).primaryColorLight :Theme.of(context).primaryColor,
                        borderRadius: 10.r,
                        fontsize: 18.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color,
                        useBorder: true,
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
