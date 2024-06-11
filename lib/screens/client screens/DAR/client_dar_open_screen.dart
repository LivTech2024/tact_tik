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
import 'client_open_dar_screen.dart';

class ClientDarOpenScreen extends StatefulWidget {
  final String employeeName;
  final String startTime;
  final List<dynamic> empDarTile;

  const ClientDarOpenScreen({
    super.key,
    required this.employeeName,
    required this.startTime,
    required this.empDarTile,
  });

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
            text: widget.employeeName,
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
                              text: widget.employeeName,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
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
                                  text: 'Started At',
                                  fontsize: 14.sp,
                                  color: isDark
                                      ? DarkColor.color21
                                      : LightColor.color2,
                                ),
                                SizedBox(width: 60.w),
                                // InterRegular(
                                //   text: 'Ended at',
                                //   fontsize: 14.sp,
                                //   color: isDark
                                //       ? DarkColor.color21
                                //       : LightColor.color2,
                                // ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                InterRegular(
                                  text: widget.startTime,
                                  fontsize: 14.sp,
                                  color: isDark
                                      ? DarkColor.color21
                                      : LightColor.color2,
                                ),
                                SizedBox(width: 90.w),
                                // InterRegular(
                                //   text: '16:56',
                                //   fontsize: 14.sp,
                                //   color: isDark
                                //       ? DarkColor.color21
                                //       : LightColor.color2,
                                // ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Place/Spot',
                  fontsize: 18.sp,
                ),
                SizedBox(height: 20.h),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.empDarTile.length,
                  itemBuilder: (context, index) {
                    final tile = widget.empDarTile[index];
                    final tileContent = tile['TileContent'] ?? 'Not Defined';
                    final tileTime = tile['TileTime'];
                    final tileLocation = tile['TileLocation'] ?? "Not Defined";
                    final tileDescription =
                        tile['TileDescription'] ?? 'Not Defined';
                    final tileReportSearchId =
                        tile['TileReportSearchId'] ?? "Not Defined";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientOpenDarScreen(
                              tileLocation: tileLocation,
                              tileTime: tileTime,
                              tileDescription: tileContent,
                              tileReportSearchId: tileReportSearchId,
                              empName: widget.employeeName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 46.h,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: 10.h),
                        decoration: BoxDecoration(
                          color: DarkColor.WidgetColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 150.w,
                              child: InterMedium(
                                text: tileContent == ''
                                    ? 'Not Defined'
                                    : tileContent,
                                fontsize: 16.sp,
                              ),
                            ),
                            Row(
                              children: [
                                InterSemibold(text: tileTime, fontsize: 16.sp),
                                SizedBox(width: 5.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 24.sp,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
