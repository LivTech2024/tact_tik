import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../home screens/widgets/icon_text_widget.dart';

class ClientDarOpenScreen extends StatefulWidget {
  const ClientDarOpenScreen({super.key});

  @override
  State<ClientDarOpenScreen> createState() => _ClientDarOpenScreenState();
}

class _ClientDarOpenScreenState extends State<ClientDarOpenScreen> {
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        selectedDate = picked;
      }
    });
  }

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
            text: "widget.guardName",
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: SizedBox(
                        width: 140.w,
                        child: IconTextWidget(
                          icon: Icons.calendar_today,
                          text: selectedDate != null
                              ? "${selectedDate!.toLocal()}".split(' ')[0]
                              : 'Select Date',
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color
                              as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  height: 130.h,
                  margin: EdgeInsets.only(top: 10.h),
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 5.h),
                              Container(
                                height: 30.h,
                                width: 4.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.r),
                                    bottomRight: Radius.circular(10.r),
                                  ),
                                  color: isDark
                                      ? DarkColor.Primarycolor
                                      : LightColor.Primarycolor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 14.w),
                          SizedBox(
                            width: 190.w,
                            child: InterSemibold(
                              text: 'Employee Name',
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color,
                              fontsize: 18.sp,
                            ),
                          )
                        ],
                      ),
                      // SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                InterRegular(
                                  text: 'Location',
                                  fontsize: 14.sp,
                                  color: isDark
                                      ? DarkColor.color21
                                      : LightColor.color2,
                                ),
                                SizedBox(width: 60.w),
                                InterRegular(
                                  text: 'Location',
                                  fontsize: 14.sp,
                                  color: isDark
                                      ? DarkColor.color21
                                      : LightColor.color2,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            InterMedium(
                              text:
                                  '2972 Westheimer Rd. Santa Ana, Illinois... ',
                              fontsize: 14.sp,
                              maxLines: 1,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                InterBold(text: 'Place/Spot', fontsize: 18.sp,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
