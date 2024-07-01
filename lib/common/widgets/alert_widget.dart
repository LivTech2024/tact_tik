import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';

import '../enums/alert_enums.dart';

class AlertWidget extends StatefulWidget {
  AlertWidget({
    super.key,
    required this.Enum,
  });

  final Enum;

  @override
  State<AlertWidget> createState() => _AlertWidgetState();
}

class _AlertWidgetState extends State<AlertWidget> {
  Widget ProfileName() {
    return Row(
      children: [
        Container(
          height: Platform.isIOS ? 41.h : 44.h,
          width: Platform.isIOS ? 41.w : 44.w,
          decoration: '' != ""
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('widget.employeeImg' ?? ""),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                )
              : BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/default.png'),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(
          width: Platform.isIOS ? 8.w : 10.w,
        ),
        InterBold(
          text: 'Yash',
          fontsize: Platform.isIOS ? 18.sp : 20.sp,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.Enum == AlertEnum.newOffer
        ? Container(
            height: 250.h,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterSemibold(
                  text: 'GUARD  •  3 min ago',
                  fontsize: Platform.isIOS ? 10.sp : 12.sp,
                ),
                SizedBox(
                  height: Platform.isIOS ? 13.h : 10.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterMedium(
                      text: 'New Offer: ',
                      fontsize: Platform.isIOS ? 14.sp : 16.sp,
                    ),
                    Flexible(
                      child: InterMedium(
                        text: 'Yash wants to offer Raj the Shift ',
                        fontsize: Platform.isIOS ? 14.sp : 16.sp,
                        maxLines: 2,
                        letterSpacing: -.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Platform.isIOS ? 26.sp : 20.sp,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProfileName(),
                      Container(
                        height: Platform.isIOS ? 43.h : 44.h,
                        width: Platform.isIOS ? 41.w : 43.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/images/arrow.svg',
                            width: 24.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ProfileName(),
                    ],
                  ),
                ),
                SizedBox(
                  height: Platform.isIOS ? 21.h : 23.h,
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: Divider(
                    height: 1.h,
                  ),
                ),
                SizedBox(
                  height: Platform.isIOS ? 12.h : 14.h,
                ),
                SizedBox(
                  height: Platform.isIOS ? 20.h : 22.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints:
                            BoxConstraints(minWidth: 80.w, maxWidth: 140.w),
                        child: IconTextWidget(
                          icon: Icons.location_on,
                          text: 'Bangalore south',
                          space: 3.w,
                          iconSize: Platform.isIOS ? 20.w : 24.w,
                          Iconcolor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      VerticalDivider(
                        width: 1,
                      ),
                      SizedBox(width: 10.w),
                      InterMedium(
                        text: '9:30am-11:30am',
                        fontsize: Platform.isIOS ? 14.sp : 16.sp,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: Platform.isIOS ? 16.h : 18.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 120.w,
                      child: Button1(
                        height: 41.h,
                        borderRadius: 5.r,
                        backgroundcolor: Theme.of(context).primaryColor,
                        text: 'Allow',
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(
                      width: Platform.isIOS ? 20.w : 24.w,
                    ),
                    SizedBox(
                      width: 120.w,
                      child: Button1(
                        height: 41.h,
                        borderRadius: 5.r,
                        backgroundcolor: Theme.of(context).primaryColor,
                        useBorder: true,
                        text: 'Deny',
                        color: Theme.of(context).primaryColor,
                        onPressed: () {},
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        : widget.Enum == AlertEnum.newExchange
            ? Container(
                constraints: BoxConstraints(minHeight: 249.h),
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterSemibold(
                      text: 'GUARD  •  3 min ago',
                      fontsize: Platform.isIOS ? 10.sp : 12.sp,
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 13.h : 10.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'New Exchange: ',
                          fontsize: Platform.isIOS ? 14.sp : 16.sp,
                        ),
                        Flexible(
                          child: InterMedium(
                            text: 'Yash wants to offer Raj the Shift ',
                            fontsize: Platform.isIOS ? 14.sp : 16.sp,
                            maxLines: 2,
                            letterSpacing: -.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 26.sp : 20.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ProfileName(),
                          Container(
                            height: Platform.isIOS ? 43.h : 44.h,
                            width: Platform.isIOS ? 41.w : 43.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: SvgPicture.asset(
                                  'assets/images/exchange.svg',
                                  width: 24.w,
                                ),
                              ),
                            ),
                          ),
                          ProfileName(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 21.h : 23.h,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Divider(
                        height: 1.h,
                      ),
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 12.h : 14.h,
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 20.h : 22.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints:
                                BoxConstraints(minWidth: 80.w, maxWidth: 140.w),
                            child: IconTextWidget(
                              icon: Icons.location_on,
                              text: 'Bangalore south',
                              space: 3.w,
                              iconSize: Platform.isIOS ? 20.w : 24.w,
                              Iconcolor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          VerticalDivider(
                            width: 1,
                          ),
                          SizedBox(width: 10.w),
                          InterMedium(
                            text: '9:30am-11:30am',
                            fontsize: Platform.isIOS ? 14.sp : 16.sp,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Platform.isIOS ? 16.h : 18.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120.w,
                          child: Button1(
                            height: 41.h,
                            borderRadius: 5.r,
                            backgroundcolor: Theme.of(context).primaryColor,
                            text: 'Allow',
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(
                          width: Platform.isIOS ? 20.w : 24.w,
                        ),
                        SizedBox(
                          width: 120.w,
                          child: Button1(
                            height: 41.h,
                            borderRadius: 5.r,
                            backgroundcolor: Theme.of(context).primaryColor,
                            useBorder: true,
                            text: 'Deny',
                            color: Theme.of(context).primaryColor,
                            onPressed: () {},
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            : widget.Enum == AlertEnum.exchange
                ? Container(
                    constraints: BoxConstraints(minHeight: 249.h),
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterSemibold(
                          text: 'GUARD  •  3 min ago',
                          fontsize: Platform.isIOS ? 10.sp : 12.sp,
                        ),
                        SizedBox(
                          height: Platform.isIOS ? 13.h : 10.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InterMedium(
                              text: 'New Exchange: ',
                              fontsize: Platform.isIOS ? 14.sp : 16.sp,
                            ),
                            Flexible(
                              child: InterMedium(
                                text: 'Yash wants to offer Raj the Shift ',
                                fontsize: Platform.isIOS ? 14.sp : 16.sp,
                                maxLines: 2,
                                letterSpacing: -.3,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Platform.isIOS ? 26.sp : 20.sp,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ProfileName(),
                              Container(
                                height: Platform.isIOS ? 43.h : 44.h,
                                width: Platform.isIOS ? 41.w : 43.w,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: SvgPicture.asset(
                                      'assets/images/exchange.svg',
                                      width: 24.w,
                                    ),
                                  ),
                                ),
                              ),
                              ProfileName(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Platform.isIOS ? 21.h : 23.h,
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          child: Divider(
                            height: 1.h,
                          ),
                        ),
                        SizedBox(
                          height: Platform.isIOS ? 12.h : 14.h,
                        ),
                        SizedBox(
                          height: Platform.isIOS ? 20.h : 22.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    minWidth: 80.w, maxWidth: 140.w),
                                child: IconTextWidget(
                                  icon: Icons.location_on,
                                  text: 'Bangalore south',
                                  space: 3.w,
                                  iconSize: Platform.isIOS ? 20.w : 24.w,
                                  Iconcolor: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              VerticalDivider(
                                width: 1,
                              ),
                              SizedBox(width: 10.w),
                              InterMedium(
                                text: '9:30am-11:30am',
                                fontsize: Platform.isIOS ? 14.sp : 16.sp,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Platform.isIOS ? 16.h : 18.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InterMedium(
                              text: 'Allowed: ',
                              fontsize: Platform.isIOS ? 14.sp : 16.sp,
                            ),
                            Flexible(
                              child: InterMedium(
                                text: 'This exchange was allowed by <Supervisor name>',
                                fontsize: Platform.isIOS ? 14.sp : 16.sp,
                                maxLines: 2,
                                letterSpacing: -.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                 : widget.Enum == AlertEnum.shiftEnded ? Container(
      constraints: BoxConstraints(minHeight: 150.h),
      margin: EdgeInsets.only(bottom: 10.h),
      padding:
      EdgeInsets.only(left: 24.w, top: 10.h , bottom: 10.h , right: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterSemibold(
            text: 'GUARD  •  3 min ago',
            fontsize: Platform.isIOS ? 10.sp : 12.sp,
          ),
          SizedBox(
            height: Platform.isIOS ? 13.h : 10.h,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check , size: Platform.isIOS ? 17.sp : 20.sp,color: Colors.white,),
              SizedBox(width: 10.w,),
              InterMedium(
                text: 'Shift Ended: ',
                fontsize: Platform.isIOS ? 14.sp : 16.sp,
              ),
              Flexible(
                child: InterMedium(
                  text: 'Yash wants to offer Raj the Shift ',
                  fontsize: Platform.isIOS ? 14.sp : 16.sp,
                  maxLines: 2,
                  letterSpacing: -.3,
                ),
              ),
            ],
          ),
          SizedBox(
            height: Platform.isIOS ? 26.sp : 20.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: Platform.isIOS ? 41.h : 44.h,
                width: Platform.isIOS ? 41.w : 44.w,
                decoration: '' != ""
                    ? BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('widget.employeeImg' ?? ""),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                )
                    : BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                  image: DecorationImage(
                    image: AssetImage('assets/images/default.png'),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: Platform.isIOS ? 8.w : 8.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterBold(
                    text: 'Yash',
                    fontsize: Platform.isIOS ? 18.sp : 20.sp,
                  ),
                  SizedBox(height: 5.h,),
                  SizedBox(
                    height: Platform.isIOS ? 20.h : 22.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              minWidth: 80.w, maxWidth: 140.w),
                          child: IconTextWidget(
                            icon: Icons.location_on,
                            text: 'Bangalore south',
                            space: 3.w,
                            iconSize: Platform.isIOS ? 20.w : 24.w,
                            Iconcolor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        VerticalDivider(
                          width: 1,
                        ),
                        SizedBox(width: 10.w),
                        InterMedium(
                          text: '9:30am-11:30am',
                          fontsize: Platform.isIOS ? 14.sp : 16.sp,
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),

        ],
      ),
    ) :Container();
  }
}
