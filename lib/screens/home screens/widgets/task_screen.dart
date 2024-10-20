import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/shift_task_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/start_task_screen.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/LocationChecker/LocationCheckerFucntions.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../feature screens/petroling/patrolling.dart';

class TaskScreen extends StatefulWidget {
  final String ShiftDate;
  final String ShiftEndTime;
  final String ShiftStartTime;
  final String ShiftLocation;
  final String ShiftCompanyId;
  final String ShiftBranchId;
  final String ShiftName;
  final String ShiftClientId;
  final String Branchid;
  final String ShiftLocationId;
  final String cmpId;
  bool isWithINRadius;
  final String empId;
  final String shiftId;
  final String patrolDate;
  final String patrolTime;
  final String patrollocation;
  final bool issShiftFetched;
  final double ShiftLatitude;
  final double shiftLongitude;
  final int ShiftRadius;
  final bool CheckUserRadius;
  final String EmpEmail;
  final String EmpName;
  final String ShiftLocationName;
  final Function() onRefreshHomeScreen;
  final Function() onEndTask;
  final VoidCallback onRefreshStartTaskScreen;
  final String ShiftStatus;

  DateTime shiftStartedTime;

  TaskScreen({
    required this.ShiftDate,
    required this.ShiftEndTime,
    required this.ShiftStartTime,
    required this.ShiftLocation,
    required this.ShiftName,
    required this.isWithINRadius,
    required this.empId,
    required this.shiftId,
    required this.patrolDate,
    required this.patrolTime,
    required this.patrollocation,
    required this.issShiftFetched,
    required this.EmpEmail,
    required this.Branchid,
    required this.cmpId,
    required this.EmpName,
    required this.ShiftLatitude,
    required this.shiftLongitude,
    required this.ShiftRadius,
    required this.CheckUserRadius,
    required this.ShiftCompanyId,
    required this.ShiftBranchId,
    required this.ShiftLocationId,
    required this.ShiftClientId,
    required this.ShiftLocationName,
    required this.onRefreshHomeScreen,
    required this.onEndTask,
    required this.onRefreshStartTaskScreen,
    required this.ShiftStatus,
    required this.shiftStartedTime,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

void showCustomDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          content,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

class _TaskScreenState extends State<TaskScreen> {
  bool ShiftStarted = false;
  bool ShiftIn = false;

  // bool issShift = false;
  FireStoreService fireStoreService = FireStoreService();
  UserLocationChecker locationChecker = UserLocationChecker();

  @override
  void initState() {
    super.initState();
    // isShiftStartTimeWithinRange(widget.ShiftStartTime);
    _loadShiftStartedState();
    // issShift = widget.issShiftFetched;
  }

  void reload() async {
    _loadShiftStartedState();
  }

  void refreshStartTaskScreen() {
    widget.onRefreshStartTaskScreen;
  }

  // bool isShiftStartTimeWithinRange(String shiftStartTime) {
  //   // Get the current time
  //   DateTime currentTime = DateTime.now();

  //   // Parse the shift start time
  //   DateFormat format = DateFormat('HH:mm');
  //   DateTime parsedShiftStartTime = format.parse(shiftStartTime);

  //   // Calculate the difference in minutes between the current time and shift start time
  //   int differenceInMinutes =
  //       parsedShiftStartTime.difference(currentTime).inMinutes;
  //   print("Shift Start TIme :${shiftStartTime}");
  //   print("parsedShiftStartTime :${parsedShiftStartTime}");
  //   print("differenceInMinutes :${differenceInMinutes}");

  //   // Check if the difference is less than or equal to 10 minutes
  //   return differenceInMinutes <= 10 && differenceInMinutes >= 0;
  // }
  // DateTime now = DateTime.now();
  // bool isShiftStartTimeWithinRange(String shiftStartTime) {
  //   // Get the current date and time

  //   // Parse the shift start time
  //   DateFormat format = DateFormat('HH:mm');
  //   DateTime parsedShiftStartTime = format.parse(shiftStartTime);

  //   // Calculate the difference in minutes between the current time and shift start time
  //   int differenceInMinutes = parsedShiftStartTime.difference(now).inMinutes;
  //   print("Shift Start TIme :${shiftStartTime}");
  //   print("parsedShiftStartTime :${parsedShiftStartTime}");
  //   print("differenceInMinutes :${differenceInMinutes}");

  //   // Check if the difference is less than or equal to 10 minutes
  //   return differenceInMinutes >= -10 && differenceInMinutes <= 0;
  // }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Shift Start Status ${widget.ShiftStatus}");
    // if (widget.ShiftStatus == 'started') {
    //   setState(() {
    //     ShiftStarted = true;
    //   });
    // }

    bool? ShiftStus = prefs.getBool('ShiftStarted') ?? false;
    setState(() {
      ShiftStarted = ShiftStus;
    });
    bool? savedClickedIn = prefs.getBool('clickedIn') ?? false;
    setState(() {
      ShiftIn = savedClickedIn;
    });
  }

  void resetShiftStarted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ShiftStarted = false;
      prefs.setBool('ShiftStarted', ShiftStarted);
    });
  }

  List<Map<String, dynamic>>? data;

  void fetchData() async {
    List<Map<String, dynamic>>? fetchedData =
        await fireStoreService.fetchShiftTask(widget.shiftId);
    if (fetchedData != null) {
      setState(() {
        data = fetchedData;
      });
    }
  }

  Future<void> _refreshData() async {
    fetchData();
    widget.onRefreshHomeScreen();
    // Fetch patrol data from Firestore (assuming your logic exists)
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    UserLocationChecker locationChecker = UserLocationChecker();

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          ShiftStarted
              ? FutureBuilder(
                  future: Future.delayed(Duration(seconds: 2)),
                  builder: (c, s) => s.connectionState == ConnectionState.done
                      ? StartTaskScreen(
                          ShiftDate: widget.ShiftDate,
                          ShiftStartTime: widget.ShiftStartTime,
                          ShiftEndTime: widget.ShiftEndTime,
                          EmployeId: widget.empId,
                          ShiftId: widget.shiftId,
                          ShiftAddressName: widget.ShiftLocationName,
                          ShiftCompanyId: widget.ShiftCompanyId,
                          ShiftBranchId: widget.ShiftBranchId,
                          EmployeeName: widget.EmpName,
                          ShiftLocationId: widget.ShiftLocationId,
                          ShiftClientID: widget.ShiftClientId,
                          resetShiftStarted: resetShiftStarted,
                          ShiftIN: ShiftIn,
                          onRefresh: refreshStartTaskScreen,
                          ShiftName: widget.ShiftName,
                          ShiftStatus: widget.ShiftStatus,
                          shiftStartedTime: widget.shiftStartedTime,
                          photoUploadInterval: 0,
                          // onRefreshStartTaskScreen: widget.onRefreshStartTaskScreen,
                        )
                      : Center(
                          child: InterMedium(
                            text: 'Loading...',
                            color: Theme.of(context).primaryColor,
                            fontsize: width / width14,
                          ),
                        ),
                )
              : Column(
                  children: [
                    widget.ShiftDate.isNotEmpty
                        ? FutureBuilder(
                            future: Future.delayed(Duration(seconds: 1)),
                            builder: (c, s) => s.connectionState ==
                                    ConnectionState.done
                                ? Container(
                                    constraints: BoxConstraints(),
                                    height: height / height242,
                                    color: Theme.of(context).cardColor,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: height / height20,
                                                left: width / width26,
                                              ),
                                              width: width / width200,
                                              height: height / height96,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  InterBold(
                                                    text:
                                                        widget.ShiftDate ?? "",
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color,
                                                    fontsize: width / width18,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InterMedium(
                                                        text: 'In time',
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color,
                                                        fontsize:
                                                            width / width18,
                                                      ),
                                                      InterMedium(
                                                        text: widget
                                                            .ShiftStartTime,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color,
                                                        fontsize:
                                                            width / width16,
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InterMedium(
                                                        text: 'Out time',
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color,
                                                        fontsize:
                                                            width / width18,
                                                      ),
                                                      InterMedium(
                                                        text:
                                                            widget.ShiftEndTime,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color,
                                                        fontsize:
                                                            width / width16,
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                right: 12.w,
                                              ),
                                              height: 74.h,
                                              width: width / width70,
                                              decoration: BoxDecoration(
                                                // color: Colors.redAccent,
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/log_book.png'),
                                                  fit: BoxFit.fitHeight,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        widget.ShiftLocation.isNotEmpty
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        width / width26),
                                                height: height / height90,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? DarkColor.colorRed
                                                    : LightColor.colorRed,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color:
                                                              Colors.redAccent,
                                                          size: width / width20,
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              height / height10,
                                                        ),
                                                        InterMedium(
                                                          text: 'Location',
                                                          color: Colors.white,
                                                          fontsize:
                                                              width / width16,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        width: width / width38),
                                                    Flexible(
                                                      child: InterRegular(
                                                        text: widget
                                                            .ShiftLocation,
                                                        fontsize:
                                                            width / width16,
                                                        color: Colors.white,
                                                        maxLines: 2,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: InterMedium(
                                      text: 'Loading...',
                                      color: Theme.of(context).primaryColor,
                                      fontsize: 14.sp,
                                    ),
                                  ),
                          )
                        : Center(
                            child: InterMedium(
                              text: 'No Shifts',
                              textAlign: TextAlign.center,
                              color: DarkColor.color2,
                              fontsize: width / width18,
                            ),
                          ),
                    SizedBox(
                      height: height / height22,
                    ),
                    if (widget.ShiftDate.isNotEmpty)
                      Button1(
                        text: 'Start Shift',
                        fontsize: 18.sp,
                        color: Colors.white,
                        backgroundcolor:
                            Theme.of(context).brightness == Brightness.dark
                                ? DarkColor.WidgetColor
                                : LightColor.Primarycolor /*.withOpacity(50)*/,
                        onPressed: () async {
                          print(widget.CheckUserRadius);
                          // if (isShiftStartTimeWithinRange(
                          //     widget.ShiftStartTime)) {
                          if (widget.CheckUserRadius == true) {
                            bool status = await locationChecker.checkLocation(
                                widget.ShiftLatitude,
                                widget.shiftLongitude,
                                widget.ShiftRadius);
                            bool? taskStatus =
                                await fireStoreService.checkShiftTaskStatus(
                                    widget.empId, widget.shiftId);
                            print("Status :$status");
                            if (status == true) {
                              //CHeck the Time here
                              if (taskStatus == false) {
                                print("taskStaus ${taskStatus}");
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShiftTaskScreen(
                                              shiftId: widget.shiftId,
                                              Name: "Shift Task",
                                              EmpId: widget.empId,
                                              EmpName: widget.EmpName,
                                            )));
                              } else {
                                setState(() {
                                  ShiftStarted = true;
                                  fireStoreService.startShiftLog(widget.empId,
                                      widget.shiftId, widget.EmpName);
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool('ShiftStarted', ShiftStarted);
                              }
                            } else {
                              showCustomDialog(context, "Location",
                                  "Move into Shift Radius to continue");
                            }
                          } else {
                            List<String> StartTimeParts =
                                widget.ShiftStartTime.split(':');
                            print("Shift Date : ${widget.ShiftDate}");
                            DateTime shiftDate = DateFormat('MMMM d, yyyy')
                                .parse(widget.ShiftDate);
                            DateTime shiftEndDateTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                int.parse(StartTimeParts[0]),
                                int.parse(StartTimeParts[1]));
                            print(
                                "Formatted SHiftEnd time ${shiftEndDateTime}");
                            DateTime currentTime = DateTime.now();
                            Duration bufferDuration = Duration(minutes: 10);

// Calculate the time ranges for the buffer period
                            DateTime bufferStart =
                                shiftEndDateTime.subtract(bufferDuration);
                            // DateTime bufferEnd = shiftEndDateTime.add(bufferDuration);

                            print("Buffer Start Time: $bufferStart");
                            // print("Buffer End Time: $bufferEnd");
                            if (currentTime.isBefore(bufferStart)) {
                              showErrorToast(context, "Start shift on Time");
                            } else {
                              bool? taskStatus =
                                  await fireStoreService.checkShiftTaskStatus(
                                      widget.empId, widget.shiftId);
                              if (taskStatus == false) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ShiftTaskScreen(
                                              shiftId: widget.shiftId,
                                              Name: "Shift Task",
                                              EmpId: widget.empId,
                                              EmpName: widget.EmpName,
                                            )));
                                print("Task Status false");
                                setState(() {
                                  // ShiftStarted = true;
                                  fireStoreService.startShiftLog(widget.empId,
                                      widget.shiftId, widget.EmpName);
                                });
                              } else {
                                bool? taskStatus =
                                    await fireStoreService.checkShiftTaskStatus(
                                        widget.empId, widget.shiftId);

                                if (taskStatus == false) {
                                  print("taskStaus ${taskStatus}");
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShiftTaskScreen(
                                          shiftId: widget.shiftId,
                                          Name: "Shift Task",
                                          EmpId: widget.empId,
                                          EmpName: widget.EmpName,
                                        ),
                                      ));
                                } else {
                                  setState(() {
                                    ShiftStarted = true;
                                    fireStoreService.startShiftLog(widget.empId,
                                        widget.shiftId, widget.EmpName);
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('ShiftStarted', ShiftStarted);
                                }
                                Map<String, dynamic> emailParams = {
                                  'to_email': 'sutarvaibhav37@gmail.com',
                                  'from_name': 'Your Name',
                                  'reply_to': 'sutarvaibhav37@gmail.com',
                                  'subject':
                                      'Your Shift has been Started ${widget.ShiftLocation}',
                                  'message': 'Your Message',
                                };
                              }

                              //if the check user radius is off we can start the shift
                            }
                          }
                        },
                      )
                    else
                      const SizedBox(),
                    SizedBox(
                      height: 10.h,
                    ),
                    /*GestureDetector(
                      onTap: () {
                        setState(() {
                          ShiftStarted = true;
                        });
                      },
                      child: Container(
                        height: 65,
                        color: WidgetColor,
                        child: Center(
                          child: InterBold(
                            text: 'Start Shift',
                            fontsize: 18,
                            color: color5,
                          ),
                        ),
                      ),
                    )*/
                  ],
                )
        ],
      ),
    );
  }
}
