import 'dart:async';
import 'dart:isolate';

import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/common/widgets/customToast.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/MapScreen/map_screen.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/eg_patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/widgets/custome_textfield.dart';
import 'package:tact_tik/screens/home%20screens/controller/home_screen_controller.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/shift_return_task_screen.dart';
import 'package:tact_tik/screens/home%20screens/shift_task_screen.dart';
import 'package:tact_tik/screens/home%20screens/wellness_check_screen.dart';
import 'package:tact_tik/services/DAR/darFucntions.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_semibold.dart';

class StartTaskScreen extends StatefulWidget {
  final String ShiftDate;
  final String ShiftEndTime;
  final String ShiftStartTime;
  final String EmployeId;
  final String ShiftId;
  final String ShiftClientID;
  final String ShiftAddressName;
  final String ShiftCompanyId;
  final String ShiftBranchId;
  final String EmployeeName;
  final String ShiftLocationId;
  final String ShiftName;

  final bool ShiftIN;
  final VoidCallback resetShiftStarted;
  final VoidCallback onRefresh;

  // final String ShiftLocation;
  final String ShiftStatus;

  StartTaskScreen({
    required this.ShiftDate,
    required this.ShiftClientID,
    required this.ShiftEndTime,
    required this.ShiftStartTime,
    required this.EmployeId,
    required this.ShiftId,
    required this.ShiftAddressName,
    required this.ShiftCompanyId,
    required this.ShiftBranchId,
    required this.EmployeeName,
    required this.ShiftLocationId,
    required this.resetShiftStarted,
    required this.ShiftIN,
    required this.onRefresh,
    required this.ShiftName,
    required this.ShiftStatus, //refresh the homescreen

    // required this.ShiftLocation,
    // required this.ShiftName,
  });

  @override
  State<StartTaskScreen> createState() => _StartTaskScreenState();
}

// final taskScreenProvider = StateNotifierProvider((ref) => TaskScreenState());
FireStoreService fireStoreService = FireStoreService();
DarFunctions darFunctions = DarFunctions();

class _StartTaskScreenState extends State<StartTaskScreen> {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  bool clickedIn = false;
  bool issShift = true;
  late Timer _stopwatchTimer;
  int _stopwatchSeconds = 0;
  String stopwatchtime = "";
  bool isPaused = false;
  bool onBreak = false;
  DateTime inTime = DateTime.now();
  int _elapsedTime = 0;
  bool _isLoading = false;
  bool buttonClicked = true;
  bool isLate = false;
  String lateTime = "";
  String remainingTimeFormatted = "";
  Timer? _timer;
  Duration remainingTime = Duration.zero;

  // late SharedPreferences prefs;
  void send_mail_onOut(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //fetch all the patrol ids assigned to him using
    List<String> emails = [];
    var ClientEmail =
        await fireStoreService.getClientEmail(widget.ShiftClientID);
    var AdminEmail =
        await fireStoreService.getAdminEmail(widget.ShiftCompanyId);
    var TestinEmail = "pankaj.kumar1312@yahoo.com";
    var defaultEmail = "tacttikofficial@gmail.com";
    var ClientName = await fireStoreService.getClientName(widget.ShiftClientID);
    // emails.add(ClientEmail!);
    emails.add("sutarvaibhav37@gmail.com");
    var testEmail3 = "sales@tpssolution.com";
    // var testEmail5 = "pankaj.kumar1312@yahoo.com";
    int? savedInTimeMillis = prefs.getInt('InTime');
    DateTime.fromMillisecondsSinceEpoch(savedInTimeMillis!);
    DateTime savedDateTime =
        DateTime.fromMillisecondsSinceEpoch(savedInTimeMillis);
    String formattedDateTime = DateFormat('HH:mm:ss').format(savedDateTime);
    // var testEmail4 = "ys146228@gmail.com";
    // var TestinEmail = "sutarvaibhav37@gmail.com";
    DateFormat dateFormat = DateFormat("HH:mm:ss");
    String formattedStartDate = dateFormat.format(DateTime.now());
    String formattedEndDate = dateFormat.format(DateTime.now());
    String formattedEndTime = dateFormat.format(DateTime.now());
    await fireStoreService.fetchPatrolData(widget.ShiftId, widget.EmployeId);

    if (ClientEmail != null && AdminEmail != null) {
      emails.add(AdminEmail);
      emails.add(TestinEmail);
      // emails.add(testEmail3);
      // emails.add(testEmail5);

      await sendShiftEmail(
        ClientName,
        emails,
        'Tacttik Shift Report',
        "Tacttik Shift Report",
        data,
        "Shift",
        widget.ShiftDate,
        widget.EmployeeName,
        widget.ShiftStartTime,
        widget.ShiftEndTime,
        widget.ShiftAddressName,
        "completed",
        formattedDateTime,
        formattedEndTime,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // inTime = DateTime.now();
    // startStopwatch();
    initPrefs();
    // initStopwatch();
    // startStopwatch();

    // clickedIn update this status
    checkWellnessReport(); // Call the wellness check function
  }

  void reload() {
    initPrefs();
    initState();
    // _loadState();
  }

  void initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final homeScreenController = HomeScreenController.instance;
    print("Shift Status at StartTask Screen ${widget.ShiftStatus}");

    print("Clicked Saved PRef ${clickedIn}");

    // if (widget.ShiftStatus == 'started') {
    //   setState(() {
    //     clickedIn = true;
    //     prefs.setBool('clickedIn', clickedIn);
    //   });
    // await homeScreenController.startBgLocationService();
    // updateLateTimeAndStartTimer();
    // } else {
    //   setState(() {
    //     prefs.setBool('clickedIn', clickedIn);
    //     clickedIn = false;
    //   });
    // }
    bool? savedClickedIn = prefs.getBool('clickedIn');
    print("saved Clicked in values: ${savedClickedIn}");
    bool? pauseState = prefs.getBool('paused');
    bool? breakState = prefs.getBool('onBreak');

    setState(() {
      clickedIn = savedClickedIn!;
    });
    if (clickedIn == true) {
      updateLateTimeAndStartTimer();
    }
    if (pauseState != null) {
      setState(() {
        isPaused = pauseState;
      });
    }
    if (breakState != null) {
      // Add this block
      setState(() {
        onBreak = breakState;
      });
      if (!onBreak) {
        // startStopwatch();
        _startTimer();
        updateLateTimeAndStartTimer();
      }
    }
    int? savedSeconds = prefs.getInt('stopwatchSeconds');
    int? savedInTimeMillis = prefs.getInt('savedInTime');

    if (savedSeconds != null) {
      setState(() {
        _stopwatchSeconds = savedSeconds;
      });
    }
    if (savedInTimeMillis != null) {
      // Change this line
      setState(() {
        inTime = DateTime.fromMillisecondsSinceEpoch(savedInTimeMillis);
      });
    }
  }

  void initStopwatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _elapsedTime = prefs.getInt('elapsedTime') ?? 0;
    });
    print("ELapsedTime: ${_elapsedTime}");
  }

  void startStopwatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (clickedIn && !isPaused) {
      _stopwatchTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {
          _stopwatchSeconds++;
          prefs.setInt('stopwatchSeconds', _stopwatchSeconds);
          prefs.setBool("stopwatchKey", true);
        });
      });
    }
  }

  void resetStopwatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _stopwatchSeconds = 0;
      prefs.setInt('stopwatchSeconds', _stopwatchSeconds);
    });
  }

  void resetClickedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      clickedIn = false;
      prefs.setBool('clickedIn', clickedIn);
      isPaused = false;
      prefs.setBool('pauseState', isPaused);
      _stopwatchSeconds = 0;
      prefs.setInt('savedInTime', _stopwatchSeconds);

      // Reset clickedIn state
      resetStopwatch(); // Reset the stopwatch
    });
  }

  void stopStopwatch() {
    _stopwatchTimer.cancel(); // Stop the stopwatch timer
  }

  @override
  void dispose() {
    _stopwatchTimer.cancel();
    super.dispose();
  }

  Future<void> checkWellnessReport() async {
    print("Company Id ${widget.ShiftCompanyId}");

    final interval =
        await fireStoreService.wellnessFetch(widget.ShiftCompanyId);
    if (interval > 0) {
      Timer.periodic(Duration(minutes: interval), (timer) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Wellness Report',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Please upload your wellness report.',
                style: TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WellnessCheckScreen(
                          EmpId: widget.EmployeId,
                          EmpName: widget.EmployeeName,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        Navigator.pop(context);
                      }
                    });
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  void updateLateTimeAndStartTimer() {
    print('update late time and start timer function');
    DateTime now = DateTime.now();

    /// -- update late time
    DateFormat dateFormat = DateFormat("HH:mm");

    DateTime shiftStartTime = dateFormat.parse(widget.ShiftStartTime);
    shiftStartTime = DateTime(now.year, now.month, now.day, shiftStartTime.hour,
        shiftStartTime.minute);

    DateTime shiftEndTime = dateFormat.parse(widget.ShiftEndTime);
    shiftEndTime = DateTime(
        now.year, now.month, now.day, shiftEndTime.hour, shiftEndTime.minute);

    DateTime deadline = shiftStartTime.add(const Duration(minutes: 10));

    Duration remainingTimeToStart = deadline.difference(now);

    if (remainingTimeToStart.isNegative) {
      print("The user is already late.");
      Duration lateDuration = now.difference(deadline);
      if (!clickedIn) {
        setState(() {
          isLate = true;
          lateTime =
              "${lateDuration.inHours}h : ${lateDuration.inMinutes % 60}m";
          print("Late time: $lateTime");
        });
      }
    } else {
      print(
          "Remaining time to start the shift: ${remainingTimeToStart.inMinutes} minutes.");
    }

    /// -- start timer
    remainingTime = shiftEndTime.difference(now);
    _startTimer();
  }

  void _startTimer() {
    print('start timer');
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - Duration(seconds: 1);
          remainingTimeFormatted =
              "${remainingTime.inHours}h : ${remainingTime.inMinutes % 60}m : ${remainingTime.inSeconds % 60}s";
          print("Timer $remainingTimeFormatted");
        } else {
          _timer!.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenController = HomeScreenController.instance;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    TextEditingController CommentController = TextEditingController();
    // Get the current time

// Convert shift start time to current date for comparison
    String lateTime = ""; // Example start time// Get current time

    print("IN Time : ${inTime}");
    print("Elapsed  : ${_elapsedTime}");
    print("Late Time: ${lateTime}");

    String formattedStopwatchTime =
        '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}';
    setState(() {
      stopwatchtime = formattedStopwatchTime;
    });

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 170.h),
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
          ),
          padding: EdgeInsets.only(left: 26.w, right: 12.47.w, bottom: 10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              InterBold(
                text: widget.ShiftDate,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontsize: 18.sp,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  InterMedium(
                    text: 'location:',
                    fontsize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  SizedBox(width: 10.w),
                  InterRegular(
                    text: widget.ShiftAddressName,
                    fontsize: 14.sp,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  )
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 97.67.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: 28.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 10.h),
                        InterRegular(
                          text: widget.ShiftStartTime,
                          fontsize: 18.99.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 10.h),
                        clickedIn
                            ? InterSemibold(
                                /// Todo isLate Time here
                                text: isLate ? "Late $lateTime" : 'on time',
                                color: isLate
                                    ? Colors.redAccent
                                    : DarkColor.color8,
                                fontsize: 14.sp,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 119.47.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'Out time',
                          fontsize: 28.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 10.h),
                        InterRegular(
                          text: widget.ShiftEndTime,
                          fontsize: 18.99.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 10.h),
                        InterSemibold(
                          text: remainingTimeFormatted,
                          // '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                          color: DarkColor.color8,
                          fontsize: 14.sp,
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 17.66.w),
                    height: 74.81.h,
                    width: 71.68.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/log_book.png'),
                        // fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 65.h,
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 5.h),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              )
            ],
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: clickedIn,
                  child: Bounce(
                    onTap: buttonClicked
                        ? () async {
                            //Check for the current location check for shifttask
                            setState(() {
                              buttonClicked = false;
                            });

                            bool? taskStatus =
                                await fireStoreService.checkShiftTaskStatus(
                                    widget.EmployeId, widget.ShiftId);

                            //CHeck the Time here
                            if (taskStatus == false) {
                              print("taskStatus ${taskStatus}");
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShiftTaskScreen(
                                            shiftId: widget.ShiftId,
                                            Name: "Shift Task",
                                            EmpId: widget.EmployeId,
                                            EmpName: widget.EmployeeName,
                                          )));
                            } else {
                              print('Shift Date ${widget.ShiftDate}');
                              //Check for the late timer or early
                              List<String> StartTimeParts =
                                  widget.ShiftStartTime.split(':');
                              DateTime shiftDate = DateFormat('MMMM d, yyyy')
                                  .parse(widget.ShiftDate);
                              DateTime shiftEndDateTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  int.parse(StartTimeParts[0]),
                                  int.parse(StartTimeParts[1]));
                              print('Shift Date ${widget.ShiftDate}');
                              print(
                                  "Formatted Shift End time $shiftEndDateTime");
                              DateTime currentTime = DateTime.now();
                              Duration bufferDuration =
                                  const Duration(minutes: 10);
                              DateTime bufferStart =
                                  shiftEndDateTime.subtract(bufferDuration);
                              // DateTime bufferEnd = shiftEndDateTime.add(bufferDuration);

                              print("Buffer Start Time: $bufferStart");
                              // print("Buffer End Time: $bufferEnd");
                              if (shiftDate !=
                                  DateTime(currentTime.year, currentTime.month,
                                      currentTime.day)) {
                                print(shiftDate);
                                print(DateTime(currentTime.year,
                                    currentTime.month, currentTime.day));
                                print(shiftDate !=
                                    DateTime(currentTime.year,
                                        currentTime.month, currentTime.day));
                                showErrorToast(context, "Not On SHift Date");
                              } else {
                                // if (currentTime.isAfter(bufferStart)) {
                                //   showErrorToast(context, "Started Late");
                                // }
                                if (currentTime.isBefore(bufferStart)) {
                                  showErrorToast(
                                      context, "Start shift on Time");
                                } else {
                                  updateLateTimeAndStartTimer();

                                  ///TODO paste this code to start timer and start locations fetch before you start to push new locations clear previous locations
                                  // FirebaseFirestore firestore =
                                  //     FirebaseFirestore.instance;
                                  // // Create a new document reference

                                  // DocumentReference docRef = firestore
                                  //     .collection('EmployeeRoutes')
                                  //     .doc();

                                  // Data to be added
                                  // Map<String, dynamic> empRouteData = {
                                  //   'EmpRouteCreatedAt': Timestamp.now(),
                                  //   'EmpRouteDate': Timestamp.now(),
                                  //   'EmpRouteEmpId': widget.EmployeId,
                                  //   'EmployeeName': widget.EmployeeName,
                                  //   'EmpRouteId': docRef.id,
                                  //   'EmpRouteLocations': [],
                                  //   'EmpRouteShiftId': widget.ShiftId,
                                  //   'EmpRouteShiftStatus': 'started',
                                  //   'EmployeeShiftStartTime':
                                  //       widget.ShiftStartTime,
                                  //   'EmployeeShiftEndTime': widget.ShiftEndTime,
                                  //   'EmployeeShiftShiftName': widget.ShiftName,
                                  //   'EmpRouteEmpRole':
                                  //       userStorage.getItem("Role"),
                                  // };
                                  // try {
                                  //   // Add the document to the collection
                                  //   await docRef.set(empRouteData);
                                  //   print(
                                  //       'Employee route created with ID: ${docRef.id}');
                                  // } catch (e) {
                                  //   print('Error creating employee route: $e');
                                  // }

                                  // start stop watch
                                  // await controller.startStopWatch();
                                  _startTimer();
                                  //
                                  // // start bg service that get locations and send it to the firebase
                                  // await homeScreenController
                                  //     .startBgLocationService();

                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await darFunctions
                                      .fetchShiftDetailsAndSubmitDAR();
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await fireStoreService.changePatrolStatus(
                                      widget.ShiftId, widget.EmployeId);
                                  bool? status = await fireStoreService
                                      .checkShiftReturnTaskStatus(
                                          widget.EmployeId, widget.ShiftId);
                                  var clientName = await fireStoreService
                                      .getClientName(widget.ShiftClientID);
                                  await fireStoreService.addToLog(
                                      'shift_start',
                                      widget.ShiftAddressName,
                                      clientName ?? "",
                                      widget.EmployeId,
                                      widget.EmployeeName,
                                      widget.ShiftCompanyId,
                                      widget.ShiftBranchId,
                                      widget.ShiftClientID,
                                      widget.ShiftLocationId,
                                      widget.ShiftName);
                                  fireStoreService.startShiftLog(
                                      widget.EmployeId,
                                      widget.ShiftId,
                                      widget.EmployeeName);
                                  setState(() {
                                    // if (!clickedIn) {
                                    clickedIn = true;
                                    prefs.setBool('clickedIn', clickedIn);
                                    DateTime currentTime = DateTime.now();
                                    inTime = currentTime;
                                    prefs.setInt('InTime',
                                        currentTime.millisecondsSinceEpoch);
                                    prefs.setInt('savedInTime',
                                        currentTime.millisecondsSinceEpoch);
                                    Timestamp.now();
                                    if (status == false) {
                                      print("Staus is false");
                                    } else {
                                      print("Staus is true");
                                    }
                                    fireStoreService
                                        .fetchreturnShiftTasks(widget.ShiftId);
                                    startStopwatch();
                                    // } else {
                                    print('already clicked');
                                    // }
                                  });
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                                showSuccessToast(context, "On current Date");
                              }
                              // setState(() {
                              //   buttonClicked = true;
                              // });
                            }
                          }
                        : () {
                            showErrorToast(
                                context, "Already Clicked please wait");
                          },

                    /// TODO changed here
                    child: Container(
                      color: Theme.of(context).cardColor,
                      child: Center(
                        child: InterBold(
                          text: 'Start Shift',
                          fontsize: 18.sp,
                          color: clickedIn
                              ? (Theme.of(context).textTheme.titleSmall!.color)
                              : (Theme.of(context).textTheme.bodySmall!.color),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              Expanded(
                child: IgnorePointer(
                  ignoring: !clickedIn,
                  child: Bounce(
                    onTap: () async {
                      // if (controller.stopWatchRunning.value) {
                      /// TODO paste this code to end shift
                      // Get.to(() => MapScreen(onDone: (File file) async {
                      //       // Fetch the employee's current route document
                      //       QuerySnapshot routeSnapshot =
                      //           await FirebaseFirestore.instance
                      //               .collection('EmployeeRoutes')
                      //               .where('EmpRouteEmpId',
                      //                   isEqualTo: widget.EmployeId)
                      //               .where('EmpRouteShiftStatus',
                      //                   isEqualTo: 'started')
                      //               .get();

                      //       if (routeSnapshot.docs.isNotEmpty) {
                      //         // Assuming you only get one active route document per employee
                      //         DocumentReference routeDocRef =
                      //             routeSnapshot.docs.first.reference;

                      //         // Update the EmpRouteShiftStatus to "completed"
                      //         await routeDocRef.update({
                      //           'EmpRouteShiftStatus': 'completed',
                      //           'EmpRouteCompletedAt': Timestamp.now(),
                      //         });

                      //         print(
                      //             'Shift ended for employee: ${widget.EmployeId}');
                      //       } else {
                      //         print(
                      //             'No active route found for employee:  ${widget.EmployeId}');
                      //       }

                      //       // await _sendEmailWithScreenshot(file.path);

                      //       await homeScreenController.stopBgLocationService();
                      //     }));

                      // setState(() {
                      //   _isLoading = true;
                      // });
                      List<String> endTimeParts =
                          widget.ShiftEndTime.split(':');
                      DateTime shiftEndDateTime = DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          int.parse(endTimeParts[0]),
                          int.parse(endTimeParts[1]));
                      print("Formatted SHiftEnd time ${shiftEndDateTime}");
                      DateTime currentTime = DateTime.now();

                      Duration bufferDuration = Duration(minutes: 10);

// Calculate the time ranges for the buffer period
                      DateTime bufferStart =
                          shiftEndDateTime.subtract(bufferDuration);
                      DateTime bufferEnd = shiftEndDateTime.add(bufferDuration);

                      print("Buffer Start Time: $bufferStart");
                      print("Buffer End Time: $bufferEnd");

                      if (currentTime.isBefore(bufferStart) ||
                          currentTime.isAfter(bufferEnd)) {
                        bool? status =
                            await fireStoreService.checkShiftReturnTaskStatus2(
                                widget.EmployeId, widget.ShiftId);
                        if (status == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShiftReturnTaskScreen(
                                      shiftId: widget.ShiftId,
                                      Empid: widget.EmployeId,
                                      ShiftName: widget.ShiftAddressName,
                                      EmpName: widget.EmployeeName,
                                    )),
                          );
                        } else {
                          // Current time is before shift end time
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: InterRegular(
                                      text: 'Add Reason',
                                      color: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .color,
                                      fontsize: width / width12,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomeTextField(
                                          hint: 'Add Reason',
                                          showIcon: false,
                                          controller: CommentController,
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                        child: InterRegular(
                                          text: 'Cancel',
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .color,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                          if (CommentController
                                              .text.isNotEmpty) {
                                            // await homeScreenController
                                            //     .stopBgLocationService();
                                            widget.onRefresh();
                                            var data = await fireStoreService
                                                .fetchDataForPdf(
                                                    widget.EmployeId,
                                                    widget.ShiftId);

                                            // send_mail_onOut(data); //Need to uncomment this
                                            setState(() {
                                              // isPaused = !isPaused;
                                              // prefs.setBool("pauseState", isPaused);
                                              clickedIn = false;
                                              resetStopwatch();
                                              resetClickedState();
                                              widget.resetShiftStarted();
                                              prefs.setBool(
                                                  'ShiftStarted', false);
                                            });

                                            var clientName =
                                                await fireStoreService
                                                    .getClientName(
                                                        widget.ShiftClientID);
                                            await fireStoreService.addToLog(
                                                'shift_end',
                                                widget.ShiftAddressName,
                                                clientName ?? "",
                                                widget.EmployeId,
                                                widget.EmployeeName,
                                                widget.ShiftCompanyId,
                                                widget.ShiftBranchId,
                                                widget.ShiftClientID,
                                                widget.ShiftLocationId,
                                                widget.ShiftName);
                                            await fireStoreService
                                                .EndShiftLogComment(
                                                    widget.EmployeId,
                                                    formattedStopwatchTime,
                                                    widget.ShiftId,
                                                    widget.ShiftAddressName,
                                                    widget.ShiftBranchId,
                                                    widget.ShiftCompanyId,
                                                    widget.EmployeeName,
                                                    widget.ShiftClientID,
                                                    CommentController.text);
                                            print("Reached Here");
                                            Navigator.pop(context);
                                            // if (mounted) {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen(),
                                              ),
                                            );
                                            // }
                                          } else {
                                            showErrorToast(context,
                                                "Reason cannot be empty");
                                          }
                                        },
                                        child: InterRegular(
                                            text: 'Submit',
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .color),
                                      ),
                                    ]);
                              });
                          print('Current time is before shift end time');
                        }
                      } else {
                        // Current time i
                        //s after or equal to shift end time

                        print(
                            'Current time is after or equal to shift end time');

                        //Check for the Current time if it is early then the shiftEndTime or more thant the shift endtime return alterbox or else not
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        bool? status =
                            await fireStoreService.checkShiftReturnTaskStatus2(
                                widget.EmployeId, widget.ShiftId);
                        if (status == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShiftReturnTaskScreen(
                                      shiftId: widget.ShiftId,
                                      Empid: widget.EmployeId,
                                      ShiftName: widget.ShiftAddressName,
                                      EmpName: widget.EmployeeName,
                                    )),
                          );
                        } else {
                          widget.onRefresh();
                          var data = await fireStoreService.fetchDataForPdf(
                              widget.EmployeId, widget.ShiftId);

                          // send_mail_onOut(data); //Need to uncomment this too

                          var clientName = await fireStoreService
                              .getClientName(widget.ShiftClientID);
                          await fireStoreService.addToLog(
                              'shift_end',
                              widget.ShiftAddressName,
                              clientName ?? "",
                              widget.EmployeId,
                              widget.EmployeeName,
                              widget.ShiftCompanyId,
                              widget.ShiftBranchId,
                              widget.ShiftClientID,
                              widget.ShiftLocationId,
                              widget.ShiftName);
                          await fireStoreService.EndShiftLog2(
                              widget.EmployeId,
                              formattedStopwatchTime,
                              widget.ShiftId,
                              widget.ShiftAddressName,
                              widget.ShiftBranchId,
                              widget.ShiftCompanyId,
                              widget.EmployeeName,
                              widget.ShiftClientID);

                          String? ClientName = await fireStoreService
                              .getClientName(widget.ShiftClientID);
                          print("Client Name ${ClientName}");
                          var ClientEmail = fireStoreService
                              .getClientEmail(widget.ShiftClientID);
                          print("Client Name ${ClientEmail}");

                          var AdminEmal = fireStoreService
                              .getAdminEmail(widget.ShiftCompanyId);
                          print("Client Name ${AdminEmal}");
                          widget.onRefresh();
                          setState(() {
                            // isPaused = !isPaused;
                            // prefs.setBool("pauseState", isPaused);
                            clickedIn = false;
                            // resetStopwatch();
                            resetClickedState();
                            widget.resetShiftStarted();
                            prefs.setBool('ShiftStarted', false);
                          });
                          // if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                          // }
                        }
                      }

                      // }
                    },
                    child: Container(
                      color: Theme.of(context).cardColor,
                      child: Center(
                        child: InterBold(
                          text: 'End Shift',
                          fontsize: 18.sp,
                          color: clickedIn
                              ? (Theme.of(context).textTheme.bodySmall!.color)
                              : (Theme.of(context).textTheme.titleSmall!.color),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: clickedIn ? 10.h : 0.h),
        clickedIn
            ? Button1(
                height: 65.h,
                // text: controller.isPaused.value ? 'Resume' : 'Break',
                text: true ? 'Resume' : 'Break',
                fontsize: 18.sp,
                color: DarkColor.color5,
                backgroundcolor: DarkColor.WidgetColor,
                onPressed: () async {
                  await fireStoreService.fetchPatrolData(
                      widget.ShiftId, widget.EmployeId);
                  var data = await fireStoreService.fetchDataForPdf(
                      widget.EmployeId, widget.ShiftId);
                  print("Fetched Data for generating pdf: ${data}");
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  setState(() {
                    isPaused = !isPaused;
                    onBreak = false;
                    prefs.setBool('pauseState', isPaused);
                  });
                  // isPaused ? stopStopwatch() : startStopwatch();
                  if (isPaused) {
                    var data = await fireStoreService.fetchDataForPdf(
                        widget.EmployeId, widget.ShiftId);
                    var clientName = await fireStoreService
                        .getClientName(widget.ShiftClientID);
                    print("Fetched Data for generating pdf: ${data}");
                    await fireStoreService.addToLog(
                        'shift_break',
                        widget.ShiftAddressName,
                        clientName ?? "",
                        widget.EmployeId,
                        widget.EmployeeName,
                        widget.ShiftCompanyId,
                        widget.ShiftBranchId,
                        widget.ShiftClientID,
                        widget.ShiftLocationId,
                        widget.ShiftName);
                    // stopStopwatch();
                    setState(() {
                      onBreak = true;
                      prefs.setBool('onBreak', onBreak);
                    });
                    fireStoreService.BreakShiftLog(widget.EmployeId);
                  } else {
                    onBreak = false;
                    var clientName = await fireStoreService
                        .getClientName(widget.ShiftClientID);
                    await fireStoreService.addToLog(
                        'shift_resume',
                        widget.ShiftAddressName,
                        clientName ?? "",
                        widget.EmployeId,
                        widget.EmployeeName,
                        widget.ShiftCompanyId,
                        widget.ShiftBranchId,
                        widget.ShiftClientID,
                        widget.ShiftLocationId,
                        widget.ShiftName);
                    prefs.setBool('onBreak', onBreak);
                    startStopwatch();
                    fireStoreService.ResumeShiftLog(widget.EmployeId);
                  }
                },
              )
            : const SizedBox(),
        SizedBox(height: 10.h),
        // SizedBox(height: height / height10),
        IgnorePointer(
          ignoring: !clickedIn,
          child: Button1(
            text: 'Check Patrolling',
            fontsize: 18.sp,
            color: clickedIn
                ? (Theme.of(context).brightness == Brightness.dark
                    ? DarkColor.color5
                    : LightColor.color1)
                : (Theme.of(context).brightness == Brightness.dark
                    ? DarkColor.color3
                    : LightColor.color5),
            backgroundcolor: Theme.of(context).brightness == Brightness.dark
                ? DarkColor.WidgetColor
                : LightColor.Primarycolor,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyPatrolsList(
                            ShiftLocationId: widget.ShiftLocationId,
                            EmployeeID: widget.EmployeId,
                            EmployeeName: widget.EmployeeName,
                            ShiftId: widget.ShiftId,
                            ShiftDate: widget.ShiftDate,
                            ShiftName: widget.ShiftName,
                          )));
            },
          ),
        ),
        if (_isLoading)
          Align(
            alignment: Alignment.center,
            child: Visibility(
              visible: _isLoading,
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Future<void> generateAndOpenPDF(String? clientName, String adminEmail,
      List<Map<String, dynamic>> patrolData) async {
    try {
      final pdf = pw.Document();

      final ByteData logoImageData1 =
          await rootBundle.load('assets/TPS RGB.png');
      final ByteData logoImageData2 =
          await rootBundle.load('assets/Tactik.jpeg');
      final Uint8List logoImageBytes1 = logoImageData1.buffer.asUint8List();
      final Uint8List logoImageBytes2 = logoImageData2.buffer.asUint8List();
      final logo1 = pw.MemoryImage(logoImageBytes1);
      final logo2 = pw.MemoryImage(logoImageBytes2);

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    left: 0,
                    top: 0,
                    child: pw.Image(logo1, width: 150.w, height: 150.h),
                  ),
                  pw.Positioned(
                    right: 10.w,
                    top: 15.h,
                    child: pw.Image(logo2, width: 100.w, height: 90.h),
                  ),
                ],
              ),
            ),
          ),
          build: (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'SHIFT/PATROL REPORT',
                  style: pw.TextStyle(
                    fontSize: 18.sp,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 50.h),
                pw.Text(
                  'Dear $clientName,\n\nI hope this email finds you well. I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during their shift. Below is a detailed breakdown of the patrols conducted:',
                  style: pw.TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
                pw.SizedBox(height: 40.h),
                pw.Text(
                  '** Shift Information:**',
                  style: pw.TextStyle(
                    fontSize: 16.sp,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8.h),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2.w,
                    ),
                    borderRadius: pw.BorderRadius.circular(8.r),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.sp),
                            child: pw.Text(
                              'Guard Name',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.sp),
                            child: pw.Text(
                              'Shift Time In',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.sp),
                            child: pw.Text(
                              'Shift Time Out',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.sp),
                            child: pw.Text(
                              'Date',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var patrol in patrolData)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.sp),
                              child: pw.Text("Vaibhav"),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.sp),
                              child: pw.Text(
                                  patrol['PatrolId'] as String? ?? 'N/A'),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.sp),
                              child: pw.Text(
                                  patrol['PatrolLogPatrolCount'] as String? ??
                                      'N/A'),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.sp),
                              child: pw.Text(patrol['PatrolLogFeedbackComment']
                                      as String? ??
                                  'N/A'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      final output = await getExternalStorageDirectory();
      if (output != null) {
        final downloadsDirectory = Directory('${output.path}/Download');
        await downloadsDirectory.create(recursive: true);
        final file = File('${downloadsDirectory.path}/shift_patrol_report.pdf');
        final Uint8List pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
        print('PDF Generated');
        print('PDF Generated at: ${file.path}');
        // Open the PDF file
        OpenFile.open(file.path);
      } else {
        print('Error: Unable to get external storage directory.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

/*Container(
                  height: height / height65,
                  color: WidgetColor,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPaused = !isPaused;
                      });
                      if (isPaused) {
                        fireStoreService.BreakShiftLog(widget.EmployeIad);
                      } else {
                        fireStoreService.ResumeShiftLog(widget.EmployeId);
                      }
                    },
                    child: InterBold(
                      text: isPaused ? 'Resume' : 'Break',
                      fontsize: width / width18,
                      color: Primarycolor,
                    ),
                  ),
                )*/

/*() {
                      setState(() {
                        isPaused = !isPaused;
                      });
                      if (isPaused) {
                        fireStoreService.BreakShiftLog(widget.EmployeId);
                      } else {
                        fireStoreService.ResumeShiftLog(widget.EmployeId);
                      }
                    }*/
}
