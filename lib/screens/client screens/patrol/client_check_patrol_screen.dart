import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import 'client_open_patrol_screen.dart';

class ClientCheckPatrolScreen extends StatefulWidget {
  final String PatrolIdl;
  ClientCheckPatrolScreen({super.key, required this.PatrolIdl});

  @override
  State<ClientCheckPatrolScreen> createState() =>
      _ClientCheckPatrolScreenState();
}

class _ClientCheckPatrolScreenState extends State<ClientCheckPatrolScreen> {
  void NavigateScreen(Widget screen, BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  DateTime? selectedDate;
  List<Map<String, dynamic>> patrolsList = [];
  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];
  @override
  void initState() {
    FireStoreService fireStoreService = FireStoreService();
    // TODO: implement initState
    super.initState();
    get_PatrolInfo();
  }

  Future<void> _selectDate(
    BuildContext context,
  ) async {
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

  void get_PatrolInfo() async {
    var PatrologsData = await fireStoreService.getPatrolsLogs(widget.PatrolIdl);
    if (PatrologsData != null || PatrologsData.isNotEmpty) {
      setState(() {
        patrolsList = PatrologsData;
      });
    }
    print(PatrologsData);
    try {} catch (error) {
      print("Error ${error}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          shadowColor: isDark ? Colors.transparent: LightColor.color3.withOpacity(.1),
          backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? DarkColor.color1 : LightColor.color3,
               size: 24.sp,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Guards',
            fontsize: 18.sp,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: SizedBox(
                        width: 190.w,
                        child: IconTextWidget(
                          icon: Icons.calendar_today,
                          text: selectedDate != null
                              ? "${selectedDate!.toLocal()}".split(' ')[0]
                              : 'display shift date',
                          fontsize: 14.sp,
                          color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140.w,
                      child: IconTextWidget(
                        space: 6.w,
                        icon: Icons.add,
                        iconSize: 20.sp,
                        text: 'Select Guard',
                        useBold: true,
                       fontsize: 14.sp,
                        color: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                        Iconcolor: DarkColor. color1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
              ListView.builder(
                itemCount: patrolsList.length,
                itemBuilder: (context, index) {
                  final patrol = patrolsList[index];
                  if (selectedDate == null ||
                      (DateTime.fromMillisecondsSinceEpoch(patrol['PatrolLogStartedAt']
                          .millisecondsSinceEpoch)
                          .year ==
                          selectedDate!.year &&
                          DateTime.fromMillisecondsSinceEpoch(patrol['PatrolLogStartedAt']
                              .millisecondsSinceEpoch)
                              .month ==
                              selectedDate!.month &&
                          DateTime.fromMillisecondsSinceEpoch(patrol['PatrolLogStartedAt']
                              .millisecondsSinceEpoch)
                              .day ==
                              selectedDate!.day)) {
                    return GestureDetector(
                      onTap: () {
                        final DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
                            patrol['PatrolLogStartedAt'].millisecondsSinceEpoch);
                        final DateTime endTime = DateTime.fromMillisecondsSinceEpoch(
                            patrol['PatrolLogEndedAt'].millisecondsSinceEpoch);

                        NavigateScreen(
                          ClientOpenPatrolScreen(
                            guardName: patrol['PatrolLogGuardName'] ?? '',
                            startDate: DateFormat('dd/MM/yyyy').format(startTime),
                            startTime: DateFormat('hh:mm a').format(startTime),
                            endTime: DateFormat('hh:mm a').format(endTime),
                            patrolLogCount: patrol['PatrolLogPatrolCount'] ?? 0,
                            status: patrol['PatrolLogStatus'] ?? '',
                            feedback: patrol['PatrolLogFeedbackComment'] ?? '',
                            checkpoints: patrol['PatrolLogCheckPoints'] ?? [],
                          ),
                          context,
                        );
                      },
                      child: Container(
                        height: 140.h,
                        margin: EdgeInsets.only(top: 10.h),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InterSemibold(
                                        text: patrol['PatrolLogGuardName'] ?? "",
                                        color: isDark
                                              ? DarkColor.color21
                                              : LightColor.color3,
                                        fontsize: 18.sp,
                                      ),
                                      // SizedBox(height: height / height5),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            // SizedBox(height: height / height10),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 18.w,
                                right: 24.w,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 80.w,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InterRegular(
                                          text: 'Started at',
                                          fontsize: 12.sp,
                                          color: isDark
                                                ? DarkColor.color21
                                                : LightColor.color3,
                                        ),
                                        SizedBox(height: 12.h),
                                        InterMedium(
                                          text: patrol['PatrolLogStartedAt'] != null
                                              ? DateFormat('hh:mm a').format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                              patrol['PatrolLogStartedAt']
                                                  .millisecondsSinceEpoch))
                                              : "",
                                          fontsize: 12.sp,
                                          color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80.w,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InterRegular(
                                          text: 'Ended at',
                                          fontsize: 12.sp,
                                          color: isDark
                                                ? DarkColor.color21
                                                : LightColor.color3,
                                        ),
                                        SizedBox(height: 12.h),
                                        InterMedium(
                                          text: patrol['PatrolLogEndedAt'] != null
                                              ? DateFormat('hh:mm a').format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                              patrol['PatrolLogEndedAt']
                                                  .millisecondsSinceEpoch))
                                              : "",
                                          fontsize: 12.sp,
                                          color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60.w,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InterRegular(
                                          text: 'Count',
                                          fontsize: 12.sp,
                                          color: isDark
                                                ? DarkColor.color21
                                                : LightColor.color3,
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              color: isDark
                                                    ? DarkColor.Primarycolor
                                                    : LightColor.color3,
                                              size: 16.sp,
                                            ),
                                            SizedBox(
                                              width: 2.w,
                                            ),
                                            InterMedium(
                                              text: patrol['PatrolLogPatrolCount']
                                                  .toString() ??
                                                  "",
                                              fontsize: 12.sp,
                                              color: isDark
                                                    ? DarkColor.color1
                                                    : LightColor.color3,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80.w,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InterRegular(
                                          text: 'Status',
                                          fontsize: 12.sp,
                                          color: isDark
                                                ? DarkColor.color21
                                                : LightColor.color3,
                                        ),
                                        SizedBox(height: 12.h),
                                        InterBold(
                                          text: 'Completed',
                                          fontsize: 12.sp,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  if (patrolsList.isEmpty ||
                      (selectedDate != null &&
                          patrolsList.every((patrol) =>
                          DateTime.fromMillisecondsSinceEpoch(
                              patrol['PatrolLogStartedAt'].millisecondsSinceEpoch)
                              .year !=
                              selectedDate?.year ||
                              DateTime.fromMillisecondsSinceEpoch(
                                  patrol['PatrolLogStartedAt'].millisecondsSinceEpoch)
                                  .month !=
                                  selectedDate?.month ||
                              DateTime.fromMillisecondsSinceEpoch(
                                  patrol['PatrolLogStartedAt'].millisecondsSinceEpoch)
                                  .day !=
                                  selectedDate?.day))) {
                    return Center(
                      child: Text(
                        patrolsList.isEmpty
                            ? 'No Patrols Found'
                            : 'No Patrols Found for Selected Date',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color:isDark? DarkColor.Primarycolor:LightColor.color3,
                        ),
                      ),
                    );
                  }
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
