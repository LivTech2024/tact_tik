import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';
import 'create_shedule_screen.dart';

class AllSchedulesScreen extends StatefulWidget {
  final String BranchId;
  final String CompanyId;

  AllSchedulesScreen({
    Key? key,
    required this.CompanyId,
    required this.BranchId,
  }) : super(key: key);

  @override
  _AllSchedulesScreenState createState() => _AllSchedulesScreenState();
}

class _AllSchedulesScreenState extends State<AllSchedulesScreen> {
  Map<DateTime, List<DocumentSnapshot>> groupedSchedules = {};

  @override
  void initState() {
    super.initState();
    _getShift();
  }

  void _getShift() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime today = DateTime.now();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    try {
      QuerySnapshot schedulesSnapshot = await firestore
          .collection('Shifts')
          .where('ShiftCompanyBranchId', isEqualTo: widget.BranchId)
          .orderBy('ShiftDate', descending: true)
          .get();

      List<QueryDocumentSnapshot> schedules = schedulesSnapshot.docs;

      setState(() {
        groupedSchedules.clear();

        for (var schedule in schedules) {
          DateTime? shiftDate = (schedule['ShiftDate'] as Timestamp?)?.toDate();
          if (shiftDate == null) {
            schedule.reference.update({'ShiftDate': 'No Data Found'});
            continue;
          }

          DateTime shiftDateWithoutTime =
              DateTime(shiftDate.year, shiftDate.month, shiftDate.day);

          if (!groupedSchedules.containsKey(shiftDateWithoutTime)) {
            groupedSchedules[shiftDateWithoutTime] = [];
          }
          groupedSchedules[shiftDateWithoutTime]!.add(schedule);
        }
      });

      await _fetchEmployeeImages();

      print("Grouped Schedules: $groupedSchedules");
    } catch (e) {
      print("Error fetching schedules: $e");
    }
  }

  Future<void> _fetchEmployeeImages() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (var date in groupedSchedules.keys) {
      for (var schedule in groupedSchedules[date]!) {
        List<dynamic> assignedUserIds = List<dynamic>.from(
            schedule['ShiftAssignedUserId'] ?? 'NO DATA FOUND');
        List<dynamic> employeeImages = [];

        try {
          QuerySnapshot employeesSnapshot = await firestore
              .collection('Employees')
              .where('EmployeeId', whereIn: assignedUserIds)
              .get();

          for (var employee in employeesSnapshot.docs) {
            String? employeeImg = employee['EmployeeImg'] as String?;
            if (employeeImg == null || employeeImg.isEmpty) {
              employeeImages.add('No Data Found');
            } else {
              employeeImages.add(employeeImg);
            }
          }

          Map<String, dynamic> scheduleData =
              schedule.data() as Map<String, dynamic>;
          scheduleData['EmployeeImages'] = employeeImages;

          schedule.reference.update(
              scheduleData); // Update the schedule document in Firestore
        } catch (e) {
          print("Error fetching employee images: $e");
        }
      }
    }

    setState(() {});
  }

  void NavigateScreen(BuildContext context, Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SHomeScreen()));
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SHomeScreen()));
            },
          ),
          title: InterMedium(
            text: 'All Schedule',
          ),
          centerTitle: true,
        ),
        floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor:
                isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => CreateSheduleScreen(
                            BranchId: widget.BranchId,
                            GuardId: '',
                            GuardName: '',
                            GuardImg: '',
                            CompanyId: widget.CompanyId,
                            supervisorEmail: '',
                            shiftId: '',
                          )));
            },
            child: Icon(
              Icons.add,
              color: isDark ? DarkColor.color15 : LightColor.color1,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Padding(
          padding: EdgeInsets.only(left: 30.w, right: 30.w),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    InterBold(
                      text: 'Search',
                      fontsize: 20.sp,
                      color: isDark ? Colors.white : LightColor.color3,
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      height: 64.h,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.transparent
                                : LightColor.color3.withOpacity(.05),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          )
                        ],
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(13.w),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w300,
                                fontSize: 18.sp,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.r),
                                  ),
                                ),
                                focusedBorder: InputBorder.none,
                                hintStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18.sp,
                                  color: isDark
                                      ? Colors.white
                                      : LightColor
                                          .color3, // Change text color to white
                                ),
                                hintText: 'Search',
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.Primarycolor,
                            ),
                          ),
                          Container(
                            height: 44.h,
                            width: 44.w,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.Primarycolor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.search,
                                size: 20.w,
                                color: isDark
                                    ? DarkColor.Secondarycolor
                                    : LightColor.color1,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    DateTime date = groupedSchedules.keys.elementAt(index);
                    List<DocumentSnapshot> schedulesForDate =
                        groupedSchedules[date]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        InterBold(
                          text: date ==
                                  DateTime.now()
                                      .toLocal()
                                      .toIso8601String()
                                      .split('T')
                                      .first
                              ? 'Today'
                              : '${date.toLocal().toIso8601String().split('T').first}',
                          fontsize: 20.sp,
                          color: isDark ? DarkColor.color1 : LightColor.color3,
                        ),
                        SizedBox(height: 24.h),
                        ...schedulesForDate.map((schedule) {
                          String shiftName =
                              schedule['ShiftName'] ?? 'NO DATA FOUND';
                          String shiftLocation =
                              schedule['ShiftLocationAddress'] ??
                                  'NO DATA FOUND';
                          String shiftStartTime =
                              schedule['ShiftStartTime'] ?? 'NO DATA FOUND';
                          String shiftEndTime =
                              schedule['ShiftEndTime'] ?? 'NO DATA FOUND';
                          String shiftId = schedule['ShiftId'];

                          Map<String, dynamic>? scheduleData =
                              schedule.data() as Map<String, dynamic>?;
                          List<dynamic> employeeImages =
                              scheduleData?['EmployeeImages'] ?? [];

                          return Container(
                            height: 160.h,
                            margin: EdgeInsets.only(top: 10.h),
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
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
                                    SizedBox(width: 14.w),
                                    SizedBox(
                                      width: 190.w,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InterSemibold(
                                            text: shiftName,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                            fontsize: 14.sp,
                                          ),
                                          SizedBox(height: 5.h),
                                          InterRegular(
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                            text: shiftLocation,
                                            maxLines: 1,
                                            fontsize: 14.sp,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 18.w,
                                    right: 24.w,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterRegular(
                                              text: 'Guards',
                                              fontsize: 14.sp,
                                              color: isDark
                                                  ? DarkColor.color1
                                                  : LightColor.color3,
                                            ),
                                            SizedBox(height: 12.h),
                                            Wrap(
                                              spacing: -5.0,
                                              children: [
                                                for (int i = 0;
                                                    i <
                                                        (employeeImages.length >
                                                                3
                                                            ? 3
                                                            : employeeImages
                                                                .length);
                                                    i++)
                                                  CircleAvatar(
                                                    radius: 10.r,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            employeeImages[i]),
                                                  ),
                                                if (employeeImages.length > 3)
                                                  CircleAvatar(
                                                    radius: 10.r,
                                                    backgroundColor: isDark
                                                        ? DarkColor.color1
                                                        : LightColor.color3,
                                                    child: InterMedium(
                                                      text:
                                                          '+${employeeImages.length - 3}',
                                                      fontsize: 12.sp,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterRegular(
                                              text: 'Shift',
                                              color: isDark
                                                  ? DarkColor.color1
                                                  : LightColor.color3,
                                              fontsize: 14.sp,
                                            ),
                                            SizedBox(height: 5.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      height: 14.h,
                                                      width: 14.w,
                                                      child: SvgPicture.asset(
                                                          'assets/images/calendar_line.svg'),
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    InterMedium(
                                                      color: isDark
                                                          ? DarkColor.color1
                                                          : LightColor.color3,
                                                      text:
                                                          '$shiftStartTime - $shiftEndTime',
                                                      fontsize: 14.sp,
                                                    ),
                                                  ],
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CreateSheduleScreen(
                                                          GuardId: '',
                                                          GuardName: '',
                                                          GuardImg: '',
                                                          CompanyId:
                                                              widget.CompanyId,
                                                          BranchId: '',
                                                          supervisorEmail: '',
                                                          shiftId: shiftId,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: SvgPicture.asset(
                                                    'assets/images/edit_square.svg',
                                                    width: 20.w,
                                                    height: 20.h,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                  childCount: groupedSchedules.keys.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
