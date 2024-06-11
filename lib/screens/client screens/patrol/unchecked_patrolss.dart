import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../fonts/inter_medium.dart';

class UncheckedPatrolScreen extends StatefulWidget {
  UncheckedPatrolScreen({super.key});

  @override
  State<UncheckedPatrolScreen> createState() => _UncheckedPatrolScreenState();
}

class _UncheckedPatrolScreenState extends State<UncheckedPatrolScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
              ),
              padding: EdgeInsets.only(left: 20.w),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: InterRegular(
              text: "Reason",
            ),
            centerTitle: true,
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              InterSemibold(
                  text: 'Let us know why you have missed?', fontsize: 18.sp),
              SizedBox(height: 20.h),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) => CheckReason(),
              )
            ],
          ),
        ),
      ),
    ));
  }
}

class CheckReason extends StatefulWidget {
  CheckReason({super.key});

  @override
  State<CheckReason> createState() => _CheckReasonState();
}

class _CheckReasonState extends State<CheckReason> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50.h),
      width: double.maxFinite,
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: DarkColor.WidgetColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 12.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  SizedBox(
                    width: 120.w,
                    child: InterMedium(
                      text: 'checkpointName',
                      // color: color21,
                      fontsize: 16.sp,
                    ),
                  )
                ],
              ),
              IconButton(
                onPressed: () {
                  print('clicked');
                  setState(() {
                    isExpand = !isExpand;
                  });
                },
                icon: Transform.rotate(
                  angle: 30, //set the angel
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 24.sp,
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: isExpand,
            child: InterRegular(
              text:
                  'jsgfksdnsd\njkshdfkjshdfshkjsdfksdsd\njsgfksdnsd\njkshdfkjshdfshkjsdfksdsd\njsgfksdnsd\njkshdfkjshdfshkjsdfksdsd\n',
              fontsize: 16.sp,
            ),
          )
        ],
      ),
    );
  }
}
