import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/end_checkpoint_screen.dart';
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../fonts/inter_medium.dart';

FireStoreService fireStoreService = FireStoreService();
final Map<String, String> _checkpointReasons = {};

class UncheckedPatrolScreen extends StatefulWidget {
  final String ShiftId;
  final String EmployeeID;
  final String PatrolID;
  final String EmployeeName;
  final int CompletedCount;

  final int PatrolRequiredCount;
  final String PatrolCompanyID;
  final String PatrolClientID;
  final String LocationId;
  final String description;
  final String ShiftDate;
  final Timestamp? PatrolStartedTIme;
  final String ShiftName;
  final String PatrolName;

  UncheckedPatrolScreen({
    super.key,
    required this.ShiftId,
    required this.EmployeeID,
    required this.PatrolID,
    required this.EmployeeName,
    required this.CompletedCount,
    required this.PatrolRequiredCount,
    required this.PatrolCompanyID,
    required this.PatrolClientID,
    required this.LocationId,
    required this.description,
    required this.ShiftDate,
    required this.PatrolStartedTIme,
    required this.ShiftName,
    required this.PatrolName,
  });

  @override
  State<UncheckedPatrolScreen> createState() => _UncheckedPatrolScreenState();
}

class _UncheckedPatrolScreenState extends State<UncheckedPatrolScreen> {
  bool _isloading = false;
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.h),
                  InterBold(
                      text: 'Let us know why you have missed?',
                      fontsize: 18.sp),
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
                                          category.checkpoints
                                              .where((checkpoint) {
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
                                              vertical: 10.h,
                                            ),
                                            child: InterMedium(
                                              text: category.title,
                                              fontsize: 16.sp,
                                            ),
                                          ),
                                          ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
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
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Button1(
                        borderRadius: 10.r,
                        height: 70.h,
                        backgroundcolor: Theme.of(context).primaryColor,
                        color: Colors.white,
                        text: 'Next',
                        onPressed: () async {
                          setState(() {
                            _isloading = true;
                          });
                          print(_checkpointReasons);
                          for (var entry in _checkpointReasons.entries) {
                            print(
                                'FailureTest Checkpoint: ${entry.key}, Reason1: ${entry.value}');
                          }
                          print("checkpointreason $_checkpointReasons");
                          if (_checkpointReasons.isEmpty ||
                              _checkpointReasons.values
                                  .any((reason) => reason.isEmpty)) {
                            showErrorToast(
                                context, "All reasons should be filled");
                          }
                          bool allReasonsFilled = true;
                          for (var patrol in patrolsData) {
                            for (var category in patrol.categories) {
                              for (var checkpoint in category.checkpoints) {
                                if (checkpoint.checkPointStatus.any((status) =>
                                    status.status == 'unchecked' &&
                                    status.reportedById == widget.EmployeeID &&
                                    status.statusShiftId == widget.ShiftId)) {
                                  // Check if the reason is provided for this checkpoint
                                  if (_checkpointReasons[checkpoint.id]
                                          ?.isEmpty ??
                                      true) {
                                    allReasonsFilled = false;
                                    break;
                                  }
                                }
                              }
                            }
                          }
                          // if (_checkpointReasons.values
                          //         .any((reason) => reason.isEmpty) ||
                          //     _checkpointReasons.isEmpty) {
                          //   print("checkpointReasonisempty");

                          //   return;
                          // }
                          // if (_checkpointReasons.isEmpty) {
                          //   // print("checkpointReasonisempty");
                          // }

                          if (!allReasonsFilled) {
                            showErrorToast(context,
                                "Please provide reasons for all unchecked checkpoints.");
                          } else {
                            await fireStoreService
                                .addFailureReasonToPatrol(
                                    _checkpointReasons,
                                    widget.PatrolID,
                                    widget.EmployeeID,
                                    widget.ShiftId)
                                .then((_) {
                              showSuccessToast(context, "Updated");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EndCheckpointScreen(
                                          EmpId: widget.EmployeeID,
                                          PatrolID: widget.PatrolID,
                                          ShiftId: widget.ShiftId,
                                          EmpName: widget.EmployeeName,
                                          CompletedCount: widget.CompletedCount,
                                          PatrolRequiredCount:
                                              widget.PatrolRequiredCount,
                                          PatrolCompanyID:
                                              widget.PatrolCompanyID,
                                          PatrolClientID: widget.PatrolClientID,
                                          LocationId: widget.LocationId,
                                          ShiftName: widget.ShiftName,
                                          description: widget.description,
                                          ShiftDate: widget.ShiftDate,
                                          PatrolStatusTime:
                                              widget.PatrolStartedTIme,
                                          PatrolName: widget.PatrolName,
                                        )),
                              );
                            }).catchError((error) {
                              // Handle error
                              print('Error: $error');
                            });
                            showSuccessToast(context, "Uploaded");
                            // print(_checkpointReasons);
                          }
                          setState(() {
                            _isloading = false;
                          });
                        }),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _isloading,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
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
  void initState() {
    super.initState();
    _reasonController.text = _checkpointReasons[widget.checkpoint.id] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 46.h),
      width: double.maxFinite,
      margin: EdgeInsets.only(bottom: 10.h),
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
                  angle: isExpand ? 4.7 : -4.7, //set the angel
                  child: Icon(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    Icons.arrow_forward_ios,
                    size: 24.sp,
                  ),
                ),
              ),
              /*  IconButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    print('Reason input for: ${widget.checkpoint.title}'),
                icon: Icon(
                  Icons.send,
                  size: 24.sp,
                ),
              )*/
            ],
          ),
          /*_reasonController    */
          /* print("Widget ${widget.checkpoint.id} = $value");
                _checkpointReasons[widget.checkpoint.id] = value;*/
          Visibility(
            visible: isExpand,
            child: Column(
              children: [
                TextField(
                  // maxLength: maxlength,
                  controller: _reasonController,
                  maxLines: isExpand ? null : 1,
                  // keyboardType: Key,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .color, // Change text color to white
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
                          .bodyLarge!
                          .color, // Change text color to white
                    ),
                    hintText: 'Enter failure reason',
                    contentPadding: EdgeInsets.zero,
                    // Remove padding
                    counterText: '',
                  ),
                  cursorColor: DarkColor.Primarycolor,
                  onChanged: (value) {
                    print("Widget ${widget.checkpoint.id} = $value");
                    _checkpointReasons[widget.checkpoint.id] = value;
                  },
                ),
                SizedBox(height: 10.h)
              ],
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
