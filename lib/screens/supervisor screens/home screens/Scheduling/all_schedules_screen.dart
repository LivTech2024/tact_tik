import 'dart:io';

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
import 'package:tact_tik/screens/new%20guard/personel_details.dart';
import 'package:tact_tik/screens/supervisor%20screens/home%20screens/s_home_screen.dart';
import 'package:tact_tik/screens/supervisor%20screens/schedule_color.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';
import '../../../client screens/Reports/select_location_report.dart';
import '../../../client screens/select_client_guards_screen.dart';
import '../../../home screens/widgets/icon_text_widget.dart';
import 'create_schedule_screen.dart';

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
  List<String> selectedLocationAddress = [];
  String selectedGuardId = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getShift();
  }

  void onLocationSelected(List<dynamic> locationAddresses) {
    setState(() {
      selectedLocationAddress = List<String>.from(locationAddresses);
    });
    print('Selected Location Address: $selectedLocationAddress');
    _getShift();
  }

  void _getShift() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime today = DateTime.now();
    DateTime startOfWeek =
        today.subtract(Duration(days: today.weekday - 1)); // Monday
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // Sunday

    try {
      Query query = firestore
          .collection('Shifts')
          .where('ShiftCompanyId', isEqualTo: widget.CompanyId)
          .where('ShiftDate',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(selectedDate ?? startOfWeek))
          .where('ShiftDate',
              isLessThanOrEqualTo:
                  Timestamp.fromDate(selectedDate ?? endOfWeek))
          .orderBy('ShiftDate', descending: true);

      QuerySnapshot schedulesSnapshot = await query.get();

      List<QueryDocumentSnapshot> schedules = schedulesSnapshot.docs;

      setState(() {
        groupedSchedules.clear();

        for (var schedule in schedules) {
          Map<String, dynamic> data = schedule.data() as Map<String, dynamic>;

          // Filter by location address if selected
          if (selectedLocationAddress.isNotEmpty) {
            String? shiftLocationAddress = data['ShiftLocationId'] as String?;
            if (shiftLocationAddress == null ||
                !shiftLocationAddress
                    .contains(selectedLocationAddress[0].toString())) {
              continue;
            }
          }

          // Filter by guard ID if selected
          if (selectedGuardId.isNotEmpty) {
            List<dynamic>? shiftAssignedUserIds =
                data['ShiftAssignedUserId'] as List<dynamic>?;
            if (shiftAssignedUserIds == null ||
                !shiftAssignedUserIds.contains(selectedGuardId)) {
              continue;
            }
          }

          // Filter by search query if provided
          if (_searchController.text.isNotEmpty) {
            String? shiftName = data['ShiftName'] as String?;
            if (shiftName == null ||
                !shiftName
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase())) {
              continue;
            }
          }

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

  // void onLocationSelected(List<dynamic> locationId) {
  //   setState(() {
  //     // selectedLocationId = List<String>.from(locationId);
  //   });
  //   // print('Selected Location Id: $selectedLocationId');
  //   // fetchReports();
  // }

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
        // fetchReports();
        _getShift();
      }
      // initState();
    });
  }

  void onGuardSelected(String guardId) {
    setState(() {
      selectedGuardId = guardId;
    });
    print('Selected Guard ID: $selectedGuardId');
    _getShift();
  }

  DateTime parseTimeString(String timeString, DateTime referenceDate) {
    final timeParts = timeString.split(':');
    if (timeParts.length != 2) {
      throw FormatException('Invalid time format');
    }
    final hours = int.tryParse(timeParts[0]) ?? 0;
    final minutes = int.tryParse(timeParts[1]) ?? 0;
    return DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      hours,
      minutes,
    );
  }

// Define a function to determine the shift status and color
  Map<String, dynamic> determineShiftStatus(
      DocumentSnapshot<Object?> scheduleDoc, int timeMarginInMins) {
    final schedule = scheduleDoc.data() as Map<String, dynamic>?;
    if (schedule == null) {
      return {
        'status': 'unknown',
        'color': Colors.amber.shade200,
      };
    }

    List<dynamic> shiftStatusArray = schedule['ShiftCurrentStatus'] ?? [];
    if (shiftStatusArray.isEmpty) {
      return {
        'status': 'pending',
        'color': Colors.amber.shade200, // #fed7aa
      };
    }

    Timestamp shiftDateTimestamp = schedule['ShiftDate'];
    DateTime shiftDate = shiftDateTimestamp.toDate();
    String shiftStartTimeString = schedule['ShiftStartTime'] ?? '00:00';
    String shiftEndTimeString = schedule['ShiftEndTime'] ?? '23:59';

    DateTime shiftStartTime =
        _parseShiftDateTime(shiftDate, shiftStartTimeString);
    DateTime shiftEndTime = _parseShiftDateTime(shiftDate, shiftEndTimeString);

    if (shiftEndTime.isBefore(shiftStartTime)) {
      shiftEndTime = shiftEndTime.add(Duration(days: 1));
    }

    Color color = Colors.grey.shade200; // #e5e7eb

    try {
      // *Pending
      if (shiftStatusArray.any((s) => s['Status'] == 'pending')) {
        color = Colors.amber.shade200; // #fed7aa
      }

      // *Started
      if (shiftStatusArray.any((s) => s['Status'] == 'started')) {
        color = Colors.pink.shade100; // #fbcfe8
      }

      // *Completed
      if (shiftStatusArray.every((s) => s['Status'] == 'completed')) {
        color = Colors.green.shade400; // #4ade80
      }

      // *Started Late
      if (shiftStatusArray.any((s) {
        DateTime statusStartedTime =
            (s['StatusStartedTime'] as Timestamp).toDate();
        return _getMinutesDifference(statusStartedTime, shiftStartTime) >
            timeMarginInMins;
      })) {
        color = Colors.purple.shade400; // #a855f7
      }

      // *Ended Early
      if (shiftStatusArray.any((s) {
        if (s['Status'] != 'completed') return false;
        DateTime statusReportedTime =
            (s['StatusReportedTime'] as Timestamp).toDate();
        return _getMinutesDifference(shiftEndTime, statusReportedTime) >
            timeMarginInMins;
      })) {
        color = Colors.red.shade400; // #ef4444
      }

      // *Ended Late
      if (shiftStatusArray.any((s) {
        if (s['Status'] != 'completed') return false;
        DateTime statusReportedTime =
            (s['StatusReportedTime'] as Timestamp).toDate();
        return _getMinutesDifference(statusReportedTime, shiftEndTime) >
            timeMarginInMins;
      })) {
        color = Colors.blue.shade300; // #60a5fa
      }

      return {
        'status': shiftStatusArray.first['Status'] ?? 'unknown',
        'color': color,
      };
    } catch (error) {
      return {
        'status': 'unknown',
        'color': color,
      };
    }
  }

  DateTime _parseShiftDateTime(DateTime date, String time) {
    final timeParts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  int _getMinutesDifference(DateTime time1, DateTime time2) {
    return time1.difference(time2).inMinutes.abs();
  }

  Future<void> _refreshData() async {
    // Fetch patrol data from Firestore (assuming your logic exists)
    _getShift();
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
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => CreateScheduleScreen(
                            BranchId: widget.BranchId,
                            GuardId: '',
                            GuardName: '',
                            GuardImg: '',
                            CompanyId: widget.CompanyId,
                            supervisorEmail: '',
                            shiftId: '',
                            GuardRole: '',
                          )));
            },
            child: Icon(
              Icons.add,
              color: LightColor.color1,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: EdgeInsets.only(left: 30.w, right: 30.w),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color as Color,
                                Iconcolor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color as Color,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  SelectLocationReport.showLocationDialog(
                                    context,
                                    widget.CompanyId,
                                    onLocationSelected,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 80.w,
                                      child: IconTextWidget(
                                        space: 6.w,
                                        icon: Icons.add,
                                        iconSize: 20.sp,
                                        text: 'Select',
                                        useBold: true,
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color as Color,
                                        Iconcolor: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color as Color,
                                      ),
                                    ),
                                    InterBold(
                                      text: 'Location',
                                      fontsize: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: Platform.isIOS ? 30.w : 10.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SelectClientGuardsScreen(
                                        companyId: widget.CompanyId,
                                        onGuardSelected: onGuardSelected,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 80.w,
                                      child: IconTextWidget(
                                        space: 6.w,
                                        icon: Icons.add,
                                        iconSize: 20.sp,
                                        text: 'Select',
                                        useBold: true,
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color as Color,
                                        Iconcolor: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color as Color,
                                      ),
                                    ),
                                    InterBold(
                                      text: 'Employee',
                                      fontsize: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedDate = null;
                            selectedGuardId = "";
                            selectedLocationAddress = [];
                            _getShift();
                          });
                        },
                        child: InterMedium(
                          text: 'clear',
                          color:
                              Theme.of(context).textTheme.headlineSmall!.color,
                          fontsize: 20.sp,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      InterBold(
                        text: 'Search',
                        fontsize: 20.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 24.h),
                      Container(
                        height: 64.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                          borderRadius: BorderRadius.circular(13.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color, // Change text color to white
                                  ),
                                  hintText: 'Search',
                                  contentPadding: EdgeInsets.zero,
                                ),
                                cursorColor: Theme.of(context).primaryColor,
                                onSubmitted: (value) {
                                  _getShift();
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _getShift();
                              },
                              child: Container(
                                height: 44.h,
                                width: 44.w,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.search,
                                    size: 20.w,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? DarkColor.Secondarycolor
                                        : LightColor.color1,
                                  ),
                                ),
                              ),
                            ),
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            // int Interval =  fireStoreService.getIntervalFromSettings(schedule['ShiftStartTime']);
                            Map<String, dynamic> statusInfo =
                                determineShiftStatus(schedule, 10);
                            String status = statusInfo['status'];
                            Color statusColor = statusInfo['color'];
                            print("Status Color ${statusColor}");
                            print("Status${status}");

                            return Container(
                              height: 160.h,
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
                                color: statusColor,
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
                                          color: Theme.of(context).primaryColor,
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
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
                                              fontsize: 14.sp,
                                            ),
                                            SizedBox(height: 5.h),
                                            InterRegular(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color,
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
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              SizedBox(height: 12.h),
                                              Wrap(
                                                spacing: -5.0,
                                                children: [
                                                  for (int i = 0;
                                                      i <
                                                          (employeeImages
                                                                      .length >
                                                                  3
                                                              ? 3
                                                              : employeeImages
                                                                  .length);
                                                      i++)
                                                    CircleAvatar(
                                                      radius: 10.r,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              employeeImages[
                                                                  i]),
                                                    ),
                                                  if (employeeImages.length > 3)
                                                    CircleAvatar(
                                                      radius: 10.r,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .color,
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
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
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
                                                          'assets/images/calendar_line.svg',
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                      SizedBox(width: 6.w),
                                                      InterMedium(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color,
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
                                                              CreateScheduleScreen(
                                                            GuardId: '',
                                                            GuardName: '',
                                                            GuardImg: '',
                                                            CompanyId: widget
                                                                .CompanyId,
                                                            BranchId: '',
                                                            supervisorEmail: '',
                                                            shiftId: shiftId,
                                                            GuardRole: '',
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: SvgPicture.asset(
                                                      themeManager.themeMode ==
                                                              ThemeMode.dark
                                                          ? 'assets/images/edit_square.svg'
                                                          : 'assets/images/edit_square_light.svg',
                                                      width: 20.w,
                                                      height: 20.h,
                                                      color: Theme.of(context)
                                                          .primaryColor,
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
      ),
    );
  }
}
