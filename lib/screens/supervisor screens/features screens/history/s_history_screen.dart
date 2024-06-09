import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

class SHistoryScreen extends StatefulWidget {
  final String empID;
  final String empName;

  const SHistoryScreen({super.key, required this.empID, required this.empName});

  @override
  State<SHistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<SHistoryScreen> {
  @override
  void initState() {
    fetchShiftHistoryDetails();
    super.initState();
  }

  List<Map<String, dynamic>> shiftHistory = [];
  FireStoreService fireStoreService = FireStoreService();
  void fetchShiftHistoryDetails() async {
    print("Emp ID ${widget.empID}");
    var shifthistory = await fireStoreService.getShiftHistory(widget.empID);
    setState(() {
      shiftHistory = shifthistory;
    });
    print('Shift History :  ${shifthistory}');
  }

  String _formatShiftDuration(String startTime, String endTime) {
    final startTimeFormat = DateFormat('HH:mm');
    final endTimeFormat = DateFormat('HH:mm');
    final start = startTimeFormat.parse(startTime);
    final end = endTimeFormat.parse(endTime);

    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}hr ${minutes.toString().padLeft(2, '0')}min';
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(
      child: Scaffold(
        
        body: CustomScrollView(
          // physics: const PageScrollPhysics(),
          slivers: [
            SliverAppBar(
            
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                 
                ),
                padding: EdgeInsets.only(left: 20.w),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterMedium(
                text: '${widget.empName} History',
               
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30.h,
              ),
            ),
            shiftHistory.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: InterMedium(
                  text: 'No Data Found',
                  fontsize: 18.sp,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
                ),
              ),
            ) :
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var shift = shiftHistory[index];
                  DateTime shiftDate =
                      (shift['ShiftDate'] as Timestamp).toDate();
                  String date =
                      '${shiftDate.day}/${shiftDate.month}/${shiftDate.year}';
                  String dayOfWeek = _getDayOfWeek(shiftDate.weekday);
                  return Padding(
                    padding: EdgeInsets.only(
                        left: 30.w,
                        right: 30.w,
                        bottom: 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: "${date}  ${dayOfWeek}",
                          fontsize: 18.sp,
                          color: isDark
                              ? DarkColor.color1
                              : LightColor.color3,
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          height: 340.h,
                          padding: EdgeInsets.only(
                            top: 20.h,
                          ),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10.r),
                            color: isDark
                                ? DarkColor.WidgetColor
                                : LightColor.WidgetColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Shift Name',
                                      fontsize: 16.w,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                    SizedBox(width: 40.w),
                                    Flexible(
                                      child: InterSemibold(
                                        text: shift['ShiftName'],
                                        fontsize: 16.w,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                height: 100.h,
                                color: isDark
                                    ? DarkColor.colorRed
                                    : LightColor.colorRed,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Location',
                                      fontsize: 16.sp,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                    SizedBox(width: 40.w),
                                    Flexible(
                                      child: InterSemibold(
                                        text: shift['ShiftLocationAddress'],
                                        fontsize: 16.w,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w),
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterSemibold(
                                          text: 'Shift Timimg',
                                          fontsize: 16.sp,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        InterSemibold(
                                          text:
                                              '${shift['ShiftStartTime']} to ${shift['ShiftEndTime']}',
                                          fontsize: 16.sp,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: height / height20),
                                    SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterSemibold(
                                            text: 'Total',
                                            fontsize: 16.sp,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          InterSemibold(
                                            text: _formatShiftDuration(shift['ShiftStartTime'], shift['ShiftEndTime']),
                                            fontsize: 16.sp,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Button1(
                                text: 'text',
                                useWidget: true,
                                MyWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_for_offline,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                      size: 24.w,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    InterSemibold(
                                      text: 'Download',
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                      fontsize: 16.sp,
                                    )
                                  ],
                                ),
                                onPressed: () {},
                                backgroundcolor: isDark
                                    ? DarkColor.Primarycolorlight
                                    : LightColor.Primarycolorlight,
                                useBorderRadius: true,
                                MyBorderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.r),
                                  bottomRight: Radius.circular(12.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} /**/
