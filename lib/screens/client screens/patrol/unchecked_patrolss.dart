import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../fonts/inter_medium.dart';

FireStoreService fireStoreService = FireStoreService();

class UncheckedPatrolScreen extends StatefulWidget {
  final String ShiftId;
  final String EmployeeID;
  final String PatrolID;

  UncheckedPatrolScreen(
      {super.key,
      required this.ShiftId,
      required this.EmployeeID,
      required this.PatrolID});

  @override
  State<UncheckedPatrolScreen> createState() => _UncheckedPatrolScreenState();
}

class _UncheckedPatrolScreenState extends State<UncheckedPatrolScreen> {
  @override
  void initState() {
    //fetch the unchecked checkpoints and display it
    _getUserInfo();
    super.initState();
  }

  void _getUserInfo() async {
    var patrolInfoList = await fireStoreService.getAllPatrolsByPatrolId(
        widget.ShiftId, widget.PatrolID);

    List<Patrol> patrols = [];
    for (var patrol in patrolInfoList) {
      Map<String, dynamic> data = patrol as Map<String, dynamic>;
      print("Patrol Data : ${data["PatrolCurrentStatus"]}");
      String patrolCompanyId = data['PatrolCompanyId'];
      String patrolLocationName = data['PatrolLocationName'];
      String patrolName = data['PatrolName'];
      String patrolId = data['PatrolId'];
      String patrolClientId = data['PatrolClientId'];
      // String patrolTime = data['PatrolTime'];
      // int requiredCount = data['LinkedPatrolReqHitCount'];
      List<dynamic>? patrolStatusDynamic =
          data['PatrolCurrentStatus'] is List<dynamic>
              ? data['PatrolCurrentStatus'] as List<dynamic>?
              : null;
      if (patrolStatusDynamic != null) {
        List<Map<String, dynamic>> patrolStatus =
            patrolStatusDynamic.cast<Map<String, dynamic>>();

        int getCompletedCount(
            List<Map<String, dynamic>> patrolCurrentStatus, String emplid) {
          List<Map<String, dynamic>> statusList =
              patrolCurrentStatus.cast<Map<String, dynamic>>();

          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          bool _isSameDay(DateTime date1, DateTime date2) {
            return date1.year == date2.year &&
                date1.month == date2.month &&
                date1.day == date2.day;
          }

          DateTime _parseTimestamp(Timestamp timestamp) {
            return timestamp.toDate();
          }

          List<Map<String, dynamic>> filteredStatusList = patrolCurrentStatus
              .where((status) =>
                  status['StatusReportedById'] == emplid &&
                  status['StatusReportedTime'] != null &&
                  // _isSameDay(
                  //     _parseTimestamp(status['StatusReportedTime']), today)
                  status['StatusShiftId'] == widget.ShiftId)
              .toList();

          int completedCount = filteredStatusList.fold(
              0,
              (sum, status) =>
                  sum + (status['StatusCompletedCount'] as int? ?? 0));

          return completedCount;
        }

        void getCurrentPatrolStatus(
            List<Map<String, dynamic>> patrolCurrentStatus, String emplid) {
          List<Map<String, dynamic>> statusList =
              patrolCurrentStatus.cast<Map<String, dynamic>>();

          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);

          bool _isSameDay(DateTime date1, DateTime date2) {
            return date1.year == date2.year &&
                date1.month == date2.month &&
                date1.day == date2.day;
          }

          DateTime _parseTimestamp(Timestamp timestamp) {
            return timestamp.toDate();
          }

          List<Map<String, dynamic>> filteredStatusList = patrolCurrentStatus
              .where((status) =>
                  status['StatusReportedById'] == emplid &&
                  status['StatusReportedTime'] != null &&
                  // _isSameDay(
                  //     _parseTimestamp(status['StatusReportedTime']), today)
                  status['StatusShiftId'] == widget.ShiftId)
              .toList();
          String currentStatus = filteredStatusList
              .map((status) => status['Status'] as String)
              .join(", ");
          List<DateTime> statusTimes = filteredStatusList
              .map((status) => _parseTimestamp(status['StatusReportedTime']))
              .toList();
          Timestamp? statusTime = filteredStatusList
              .map((status) => status['StatusReportedTime'])
              .cast<Timestamp>() // Cast to List<DateTime>
              .firstOrNull; // Get the first element or null if empty
          // if (statusTime != null) {
          //   StatusPatrolTime = statusTime;
          // }
          print("Status times: $statusTimes");
          print("========>>>>>>>==========================");
          print("Current Patrol Status ${currentStatus.toString()}");
          print("Current Patrol Time ${statusTime}");
          if (currentStatus.isNotEmpty || currentStatus != null) {
            setState(() {
              // CurrentPatrolStatus = currentStatus;
            });
          }
        }

        int completedCount = getCompletedCount(patrolStatus, widget.EmployeeID);
        getCurrentPatrolStatus(patrolStatus, widget.EmployeeID);
        setState(() {
          // totalCount = completedCount;
        });

        // print('Completed count for  ${_PatrolId}: $completedCount');
      } else {
        print('Patrol status is null or not a List<dynamic>');
      }

      setState(() {
        // _PatrolId = patrolId;
      });
      List<Category> categories = [];
      bool allChecked = false;
      String _parseTimestamp(Timestamp timestamp) {
        DateTime dateTime = timestamp.toDate();
        return DateFormat.Hms()
            .format(dateTime); // This will return time in 'HH:mm:ss' format
      }

      for (var checkpoint in data['PatrolCheckPoints']) {
        String checkpointCategory = checkpoint['CheckPointCategory'] ?? "";
        String checkpointId = checkpoint['CheckPointId'];
        String checkpointName = checkpoint['CheckPointName'];
        // String checkpointtimestamp =
        //     checkpoint['StatusReportedTime']?.toString() ?? "";

        String? reportedTime;
        List<CheckPointStatus> checkPointStatuses =
            (checkpoint['CheckPointStatus'] as List<dynamic> ?? [])
                .map((status) {
          List<dynamic> checkPointStatuses =
              checkpoint['CheckPointStatus'] ?? [];

          if (checkPointStatuses == null ||
              checkPointStatuses.isEmpty ||
              checkPointStatuses.any((status) {
                if (status['Status'] == 'unchecked' &&
                    status['StatusReportedById'] == widget.EmployeeID &&
                    status['StatusShiftId'] == widget.ShiftId) {
                  // reportedTime = _parseTimestamp(status['StatusReportedTime']);
                  return true;
                }
                return false;
              }) ||
              checkPointStatuses.any((status) {
                if (status['Status'] != 'unchecked' &&
                    checkPointStatuses.every((s) =>
                        s['StatusReportedById'] != widget.EmployeeID &&
                        s['StatusShiftId'] == widget.ShiftId)) {
                  reportedTime = _parseTimestamp(status['StatusReportedTime']);
                  return true;
                }
                return false;
              })) {
            setState(() {
              allChecked =
                  false; // At least one checkpoint is not checked or does not have the specified 'empid'
            });
          } else {
            setState(() {
              allChecked =
                  true; // All checkpoints have at least one status and all statuses are checked
            });
          }
          if (checkPointStatuses == null ||
              checkPointStatuses.isEmpty ||
              checkPointStatuses.any((status) {
                if (status['Status'] == 'checked' &&
                    status['StatusReportedById'] == widget.EmployeeID &&
                    status['StatusShiftId'] == widget.ShiftId) {
                  reportedTime = _parseTimestamp(status['StatusReportedTime']);
                  return true;
                }
                return false;
              })) ;

          // ... rest of the code
          // List<Map<String, dynamic>> filteredStatusList = checkpoint
          //     .where(
          //         (status) => status['StatusReportedById'] == widget.EmployeeID)
          //     .toList();
          return CheckPointStatus(
            status: status['Status'],
            StatusCompletedCount: status['StatusCompletedCount'],
            reportedTime: status['StatusReportedTime'],
            reportedById: status['StatusReportedById'],
            reportedByName: status['StatusReportedByName'],
            statusShiftId: status['StatusShiftId'],
          );
        }).toList();
        Category category = categories.firstWhere(
            (element) => element.title == checkpointCategory, orElse: () {
          Category newCategory =
              Category(title: checkpointCategory, checkpoints: []);
          categories.add(newCategory);
          return newCategory;
        });

        category.checkpoints.add(Checkpoint(
          title: checkpointName,
          description: checkpointName,
          id: checkpointId,
          checkPointStatus: checkPointStatuses,
          patrolId: patrolId,
          timestamp: reportedTime?.toString() ?? "",
        ));
      }

      patrols.add(
        Patrol(
          title: patrolName,
          description: patrolLocationName,
          categories: categories,
          // time: patrolTime,
          PatrolId: widget.PatrolID,
          EmpId: widget.EmployeeID,
          EmployeeName: "",
          PatrolRequiredCount: 0,
          CompletedCount: 0,
          Allchecked: allChecked,
          PatrolCompanyID: patrolCompanyId,
          PatrolClientID: patrolClientId,
          ShiftDate: "",
          ShiftId: widget.ShiftId,
          LocationId: "",
          patrolClientId: patrolClientId,
          ShiftName: "",
          CurrentStatus: "",
          PatrolStartedTIme: Timestamp.now(),
        ),
      );
    }
    print("Patrol on unchecked Screen ${patrolInfoList}");
    setState(() {
      patrolsData = patrols;
      // patrolsData1 = patrols;
    });
    print("Patrol on unchecked Screen ${patrolsData}");
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
              InterBold(
                  text: 'Let us know why you have missed?', fontsize: 18.sp),
              SizedBox(height: 20.h),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: patrolsData.length,
                itemBuilder: (context, index) {
                  Patrol patrol = patrolsData[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: InterMedium(
                          text: patrol.title,
                          fontsize: 18.sp,
                        ),
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: patrolsData.length,
                        itemBuilder: (context, index) {
                          Patrol patrol = patrolsData[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Padding(
                              //   padding: EdgeInsets.symmetric(vertical: 10.h),
                              //   child: InterMedium(
                              //     text: patrol.title,
                              //     fontsize: 18.sp,
                              //   ),
                              // ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: patrol.categories.length,
                                itemBuilder: (context, categoryIndex) {
                                  Category category =
                                      patrol.categories[categoryIndex];
                                  List<Checkpoint> uncheckedCheckpoints =
                                      category.checkpoints.where((checkpoint) {
                                    return checkpoint.checkPointStatus.any(
                                        (status) =>
                                            status.status == 'unchecked' &&
                                            status.reportedById ==
                                                widget.EmployeeID &&
                                            status.statusShiftId ==
                                                widget.ShiftId);
                                  }).toList();

                                  // Debugging prints
                                  print(
                                      "Category: ${category.title}, Unchecked Checkpoints: ${uncheckedCheckpoints.length}");

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: InterMedium(
                                          text: category.title,
                                          fontsize: 16.sp,
                                        ),
                                      ),
                                      ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: uncheckedCheckpoints
                                            .length, // Fix here
                                        itemBuilder:
                                            (context, checkpointIndex) {
                                          if (checkpointIndex >=
                                              uncheckedCheckpoints.length) {
                                            print(
                                                "Checkpoint index out of range: $checkpointIndex / ${uncheckedCheckpoints.length}");
                                            return SizedBox
                                                .shrink(); // Return an empty widget to avoid the error
                                          }
                                          Checkpoint checkpoint =
                                              uncheckedCheckpoints[
                                                  checkpointIndex];

                                          return CheckReason(
                                            p: patrol,
                                            checkpoint: checkpoint,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    ));
  }
}

class CheckReason extends StatefulWidget {
  final Patrol p;
  final Checkpoint checkpoint;
  CheckReason({super.key, required this.p, required this.checkpoint});

  @override
  State<CheckReason> createState() => _CheckReasonState();
}

class _CheckReasonState extends State<CheckReason> {
  bool isExpand = false;
  final TextEditingController _reasonController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 46.h),
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
          // SizedBox(height: 10.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    width: 144.w,
                    child: InterMedium(
                      text: widget.checkpoint.title,
                      // color: color21,
                      fontsize: 16.sp,
                    ),
                  )
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  print('clicked');

                  setState(() {
                    isExpand = !isExpand;
                  });
                },
                icon: Transform.rotate(
                  angle: isExpand ? 30 : -30, //set the angel
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 24.sp,
                  ),
                ),
              )
            ],
          ),
          Visibility(
            visible: isExpand,
            child: TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Enter failure reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: null, // Allow multiple lines
              style: TextStyle(
                fontSize: 16.sp,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Patrol {
  final String title;
  final String description;

  // final String time;
  final String PatrolId;
  final String EmpId;
  final String PatrolCompanyID;
  final String PatrolClientID;

  final String EmployeeName;

  final int PatrolRequiredCount;
  final int CompletedCount;
  final bool Allchecked;
  final List<Category> categories;
  final String ShiftDate;
  final String ShiftId;
  final String LocationId;
  final String ShiftName;

  final String patrolClientId;
  final String CurrentStatus;
  final Timestamp? PatrolStartedTIme;

  Patrol({
    required this.title,
    required this.PatrolCompanyID,
    required this.PatrolClientID,
    required this.description,
    required this.categories,
    required this.patrolClientId,
    // required this.time,
    required this.PatrolId,
    required this.EmpId,
    required this.EmployeeName,
    required this.PatrolRequiredCount,
    required this.CompletedCount,
    required this.Allchecked,
    required this.ShiftDate,
    required this.ShiftId,
    required this.LocationId,
    required this.ShiftName,
    required this.CurrentStatus,
    required this.PatrolStartedTIme,
  });
}

class Category {
  final String title;
  final List<Checkpoint> checkpoints;

  Category({required this.title, required this.checkpoints});
}

class Checkpoint {
  final String patrolId;
  final String title;
  final String description;
  final String timestamp;
  final String id;
  final List<CheckPointStatus> checkPointStatus;

  Checkpoint({
    required this.title,
    required this.patrolId,
    required this.description,
    required this.id,
    required this.checkPointStatus,
    required this.timestamp,
  });

  bool isSameDay(Timestamp? timestamp1, Timestamp timestamp2) {
    if (timestamp1 == null) {
      return false; // or handle the case when timestamp1 is null
    }
    DateTime dateTime1 = timestamp1.toDate();
    DateTime dateTime2 = timestamp2.toDate();
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  String? getFirstStatus(String empId, String ShiftId) {
    if (checkPointStatus.isNotEmpty) {
      for (var status in checkPointStatus) {
        if (status.reportedById == empId &&
            // isSameDay(status.reportedTime, Timestamp.now())
            status.statusShiftId == ShiftId) {
          return status.status;
        }
      }
    }
    return null;
  }
}

class CheckPointStatus {
  final String status;
  final String? reportedById;
  final String? statusShiftId;
  final String? reportedByName;
  final Timestamp? reportedTime;
  final String? failureReason;
  final int? StatusCompletedCount;

  CheckPointStatus({
    required this.status,
    this.reportedById,
    this.reportedByName,
    this.reportedTime,
    this.failureReason,
    this.StatusCompletedCount,
    this.statusShiftId,
  });
}

late List<Patrol> patrolsData = [];
