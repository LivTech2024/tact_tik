import 'dart:async';
import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/home%20screens/controller/home_screen_controller.dart';
import 'package:tact_tik/screens/home%20screens/wellness_check_screen.dart';
import 'package:tact_tik/services/DAR/darFucntions.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:workmanager/workmanager.dart';
import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_semibold.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "timerTask") {
      String callOutId = inputData!['callOutId'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int elapsedSeconds = prefs.getInt('elapsedSeconds_$callOutId') ?? 0;
      bool onBreak = prefs.getBool('onBreak_$callOutId') ?? false;
      int lastEmailSentAt = prefs.getInt('lastEmailSentAt_$callOutId') ?? 0;

      if (!onBreak) {
        elapsedSeconds++;
        await prefs.setInt('elapsedSeconds_$callOutId', elapsedSeconds);

        if (elapsedSeconds >= 1800 &&
            (elapsedSeconds - lastEmailSentAt >= 3600 ||
                lastEmailSentAt == 0)) {
          //TODO Call sendDAREmail function
          // await sendDAREmail();
          await prefs.setInt('lastEmailSentAt_$callOutId', elapsedSeconds);
        }
      }
    }
    return Future.value(true);
  });
}

class CallOutScreen extends StatefulWidget {
  final String callOutDate;
  final String callOutTime;
  final String EmployeeId;
  final String EmployeeName;
  final String callOutId;
  String callOutStatus;
  final String callOutAddressName;
  final String callOutCompanyId;
  final VoidCallback onRefresh;

  CallOutScreen({
    super.key,
    required this.callOutDate,
    required this.callOutId,
    required this.callOutTime,
    required this.EmployeeId,
    required this.callOutAddressName,
    required this.callOutStatus,
    required this.callOutCompanyId,
    required this.EmployeeName,
    required this.onRefresh, //refresh the homescreen
  });

  @override
  State<CallOutScreen> createState() => _CallOutScreenState();
}

FireStoreService fireStoreService = FireStoreService();
DarFunctions darFunctions = DarFunctions();

class _CallOutScreenState extends State<CallOutScreen> {
  bool clickedIn = false;
  bool issShift = true;
  Timer _stopwatchTimer = Timer(Duration.zero, () {});
  int _stopwatchSeconds = 0;
  String stopwatchtime = "";
  bool isPaused = false;
  bool onBreak = false;
  DateTime inTime = DateTime.now();
  bool _isLoading = false;
  bool buttonClicked = true;
  bool isLate = false;
  String lateTime = "";
  String remainingTimeFormatted = "";
  Timer? _timer;
  Duration remainingTime = Duration.zero;
  bool isTimerRunning = false;
  Duration timerDuration = Duration.zero;
  DateTime? startTime;
  int elapsedSeconds = 0;
  Timer? timer;
  int lastEmailSentAt = 0;

  @override
  void initState() {
    super.initState();
    Workmanager().initialize(callbackDispatcher);
    initPrefs();

    if (widget.callOutStatus == 'started') {
      checkWellnessReport();
    }
  }

  void loadTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      elapsedSeconds = prefs.getInt('elapsedSeconds_${widget.callOutId}') ?? 0;
      onBreak = prefs.getBool('onBreak_${widget.callOutId}') ?? false;
      lastEmailSentAt =
          prefs.getInt('lastEmailSentAt_${widget.callOutId}') ?? 0;
    });
    if (widget.callOutStatus == 'started' && !onBreak) {
      startTimer();
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
      checkAndSendEmail();
      saveTimerState();
    });
    Workmanager().registerOneOffTask(
      "timerTask_${widget.callOutId}",
      "timerTask",
      inputData: {'callOutId': widget.callOutId},
    );
  }

  void checkAndSendEmail() async {
    if (elapsedSeconds >= 1800 &&
        (elapsedSeconds - lastEmailSentAt >= 3600 || lastEmailSentAt == 0)) {
      //TODO Call sendDAREmail function
      // await sendDAREmail();
      lastEmailSentAt = elapsedSeconds;
      saveTimerState();
    }
  }

  void pauseTimer() {
    timer?.cancel();
    saveTimerState();
  }

  void saveTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsedSeconds_${widget.callOutId}', elapsedSeconds);
    await prefs.setBool('onBreak_${widget.callOutId}', onBreak);
    await prefs.setInt('lastEmailSentAt_${widget.callOutId}', lastEmailSentAt);
  }

  void toggleBreakStatus() {
    setState(() {
      onBreak = !onBreak;
      if (onBreak) {
        pauseTimer();
      } else {
        startTimer();
      }
    });
    saveTimerState();
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadBreakStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      onBreak =
          prefs.getBool('${widget.callOutId}_${widget.EmployeeId}_onBreak') ??
              false;
    });
  }

  void reload() {
    initPrefs();
    initState();
  }

  void initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final HomeScreenController homeScreenController =
        Get.put(HomeScreenController());
    await _loadBreakStatus();
    loadTimerState();
    bool? savedClickedIn = prefs.getBool('clickedIn');
    setState(() {
      clickedIn = savedClickedIn!;
    });
    if (clickedIn == true) {
      print("Clicked in is true Start Screem");
      _startTimer();
      await homeScreenController.startBgLocationService();
    } else {}
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

  @override
  void dispose() {
    _stopwatchTimer.cancel();
    timer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkWellnessReport() async {
    final interval =
        await fireStoreService.wellnessFetch(widget.callOutCompanyId);

    if (interval > 0) {
      // Get the current time
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();

      // Retrieve the last notification time from SharedPreferences
      final lastNotificationTimeMillis =
          prefs.getInt('lastWellnessNotificationTime') ?? 0;
      final lastNotificationTime =
          DateTime.fromMillisecondsSinceEpoch(lastNotificationTimeMillis);

      // Calculate the time difference in minutes
      final differenceInMinutes =
          now.difference(lastNotificationTime).inMinutes;

      // Show the dialog if the interval has passed
      if (differenceInMinutes >= interval) {
        Timer.periodic(Duration(minutes: interval), (timer) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Wellness Report',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                content: Text(
                  'Please upload your wellness report.',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Open'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WellnessCheckScreen(
                            EmpId: widget.EmployeeId,
                            EmpName: widget.EmployeeName,
                          ),
                        ),
                      ).then((value) async {
                        if (value == true) {
                          // Save the current time as the last notification time
                          await prefs.setInt('lastWellnessNotificationTime',
                              now.millisecondsSinceEpoch);
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
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && clickedIn == true) {
        setState(() {
          if (remainingTime.inSeconds > 0) {
            remainingTime = remainingTime - Duration(seconds: 1);
            remainingTimeFormatted =
                "${remainingTime.inHours}h : ${remainingTime.inMinutes % 60}m : ${remainingTime.inSeconds % 60}s";
          } else {
            _timer!.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
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
                text: widget.callOutDate,
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
                  SizedBox(
                    // location overflow solved
                    width: 260.w,
                    child: InterRegular(
                      text: widget.callOutAddressName,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
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
                          text: widget.callOutTime,
                          fontsize: 18.99.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          formatTime(elapsedSeconds),
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      InterSemibold(
                        text: onBreak ? 'In Break' : '',
                        color: Colors.redAccent,
                        fontsize: 14.sp,
                      )
                    ],
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
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: widget.callOutStatus == 'started',
                  child: Bounce(
                    onTap: () async {
                      try {
                        DocumentReference calloutDoc = FirebaseFirestore
                            .instance
                            .collection('Callouts')
                            .doc(widget.callOutId);
                        DocumentSnapshot calloutSnapshot =
                            await calloutDoc.get();
                        if (calloutSnapshot.exists) {
                          List<dynamic> calloutStatus =
                              calloutSnapshot['CalloutStatus'];
                          int empIndex = calloutStatus.indexWhere((element) =>
                              element['StatusEmpId'] == widget.EmployeeId);

                          if (empIndex != -1) {
                            calloutStatus[empIndex]['Status'] = 'started';
                            await calloutDoc.update({
                              'CalloutStatus': calloutStatus,
                              'CalloutStartTime': DateTime.now(),
                            });
                            widget.onRefresh();
                            startTimer();
                          }
                        } else {
                          showErrorToast(context, "Callout not found");
                        }
                      } catch (e) {
                        showErrorToast(context,
                            "Error updating callout status. Try again");
                      }
                    },
                    child: Container(
                      color: widget.callOutStatus == 'started'
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? DarkColor.WidgetColorLigth
                              : LightColor.WidgetColorLigth)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? DarkColor.WidgetColor
                              : LightColor.WidgetColor),
                      child: Center(
                        child: InterBold(
                          text: 'Start Shift',
                          fontsize: 18.sp,
                          color: widget.callOutStatus == 'started'
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? DarkColor.textLigth
                                  : LightColor.color2)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? DarkColor.color5
                                  : LightColor.color3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: IgnorePointer(
                  ignoring: widget.callOutStatus != 'started',
                  child: Bounce(
                    onTap: () async {
                      try {
                        DocumentReference calloutDoc = FirebaseFirestore
                            .instance
                            .collection('Callouts')
                            .doc(widget.callOutId);
                        DocumentSnapshot calloutSnapshot =
                            await calloutDoc.get();
                        if (calloutSnapshot.exists) {
                          List<dynamic> calloutStatus =
                              calloutSnapshot['CalloutStatus'];
                          int empIndex = calloutStatus.indexWhere((element) =>
                              element['StatusEmpId'] == widget.EmployeeId);

                          if (empIndex != -1) {
                            calloutStatus[empIndex]['Status'] = 'completed';
                            await calloutDoc.update({
                              'CalloutStatus': calloutStatus,
                              'CallOutEndTime': DateTime.now(),
                            });
                            pauseTimer();
                            Workmanager().cancelByUniqueName(
                                "timerTask_${widget.callOutId}");
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs
                                .remove('elapsedSeconds_${widget.callOutId}');
                            await prefs.remove('onBreak_${widget.callOutId}');
                            await prefs
                                .remove('lastEmailSentAt_${widget.callOutId}');
                            setState(() {
                              widget.callOutStatus == 'completed';
                            });
                            widget.onRefresh();
                          }
                        } else {
                          showErrorToast(context, "Callout not found");
                        }
                      } catch (e) {
                        showErrorToast(context,
                            "Error updating callout status. Try again");
                      }
                    },
                    child: Container(
                      color: widget.callOutStatus == 'started'
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? DarkColor.WidgetColor
                              : LightColor.WidgetColor)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? DarkColor.WidgetColorLigth
                              : LightColor.WidgetColorLigth),
                      child: Center(
                        child: InterBold(
                          text: 'End Shift',
                          fontsize: 18.sp,
                          color: widget.callOutStatus == 'started'
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? DarkColor.color5
                                  : LightColor.color3)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? DarkColor.textLigth
                                  : LightColor.color2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: widget.callOutStatus == 'started' ? 10.h : 0.h),
        widget.callOutStatus == 'started'
            ? Button1(
                height: 65.h,
                text: !onBreak ? 'Break' : 'Resume',
                fontsize: 18.sp,
                color: Theme.of(context).textTheme.titleSmall!.color,
                backgroundcolor: widget.callOutStatus == 'started'
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? DarkColor.WidgetColor
                        : LightColor.WidgetColor)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? DarkColor.WidgetColorLigth
                        : LightColor.WidgetColorLigth),
                onPressed: toggleBreakStatus,
              )
            : const SizedBox(),
        SizedBox(height: 10.h),
        SizedBox(height: height / height10),
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
}
