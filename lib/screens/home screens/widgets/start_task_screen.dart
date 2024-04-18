import 'dart:async';
import 'dart:isolate';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/riverpod/task_screen_provider.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/eg_patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/shift_return_task_screen.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/backgroundService/countDownTimer.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

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
  final bool ShiftIN;
  final VoidCallback resetShiftStarted;
  final VoidCallback onRefresh;

  // final String ShiftLocation;
  // final String ShiftName;

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

    // required this.ShiftLocation,
    // required this.ShiftName,
  });

  @override
  State<StartTaskScreen> createState() => _StartTaskScreenState();
}

// final taskScreenProvider = StateNotifierProvider((ref) => TaskScreenState());
FireStoreService fireStoreService = FireStoreService();

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

  // late SharedPreferences prefs;
  void send_mail_onOut() async {
    List<String> emails = [];
    var ClientEmail =
        await fireStoreService.getClientEmail(widget.ShiftClientID);
    var AdminEmail =
        await fireStoreService.getAdminEmail(widget.ShiftCompanyId);
    var TestinEmail = "sutarvaibhav37@gmail.com";
    var defaultEmail = "tacttikofficial@gmail.com";
    emails.add(ClientEmail!);
    // var TestinEmail = "sutarvaibhav37@gmail.com";
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String formattedStartDate = dateFormat.format(DateTime.now());
    String formattedEndDate = dateFormat.format(DateTime.now());
    String formattedEndTime = dateFormat.format(DateTime.now());
    if (ClientEmail != null && AdminEmail != null) {
      emails.add(AdminEmail);
      emails.add(TestinEmail);
      Map<String, dynamic> emailParams = {
        'to_email': '$ClientEmail, $AdminEmail ,$defaultEmail',
        // 'to_email': '$TestinEmail',
        "startDate": '${widget.ShiftDate}',
        "endDate": '${widget.ShiftDate}',
        'from_name': '${widget.EmployeeName}',
        'reply_to': '$defaultEmail',
        'type': 'Shift ',
        'Location': '${widget.ShiftAddressName}',
        'Status': 'Completed',
        'GuardName': '${widget.EmployeeName}',
        'StartTime': '${widget.ShiftStartTime}',
        'EndTime': '${stopwatchtime}',
        'CompanyName': 'Tacttik',
      };
      // sendFormattedEmail(emailParams);
    }
  }

  @override
  void initState() {
    super.initState();
    inTime = DateTime.now();

    initPrefs();
    initStopwatch();
    startStopwatch();
  }

  void reload() {
    initPrefs();
    initState();
  }

  void _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedClickedIn = prefs.getBool('clickedIn');
    setState(() {
      clickedIn = savedClickedIn!;
    });
  }

  void initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedClickedIn = prefs.getBool('clickedIn');
    bool? pauseState = prefs.getBool('paused');
    bool? breakState = prefs.getBool('onBreak');
    setState(() {
      clickedIn = savedClickedIn!;
    });
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
        startStopwatch();
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

  int countdownSeconds = 180; //total timer limit in seconds
  late CountdownTimer countdownTimer;
  bool isTimerRunning = false;

  void initTimerOperation() {
//timer callbacks
    countdownTimer = CountdownTimer(
      seconds: countdownSeconds,
      onTick: (seconds) {
        isTimerRunning = true;
        countdownSeconds = seconds; //this will return the timer values
      },
      onFinished: () {
        isTimerRunning = false;
        countdownTimer.stop();
        // Handle countdown finished
      },
    );

//native app life cycle
    SystemChannels.lifecycle.setMessageHandler((msg) {
// On AppLifecycleState: paused
      if (msg == AppLifecycleState.paused.toString()) {
        if (isTimerRunning) {
          countdownTimer.pause(countdownSeconds); //setting end time on pause
        }
      }

// On AppLifecycleState: resumed
      if (msg == AppLifecycleState.resumed.toString()) {
        if (isTimerRunning) {
          countdownTimer.resume();
        }
      }
      return Future(() => null);
    });

//starting timer
    isTimerRunning = true;
    countdownTimer?.start();
  }

  @override
  void dispose() {
    _stopwatchTimer.cancel();
    resetClickedState();
    super.dispose();
  }

  final LocalStorage storage = LocalStorage('ShiftDetails');

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    // Get the current time
    DateTime currentTime = DateTime.now();
    DateFormat format = DateFormat('hh:mm a');
// Parse the shift start time from the widget
    DateTime shiftStartTime = format.parse(widget.ShiftStartTime);

// Convert shift start time to current date for comparison
    String lateTime = "";
    if (inTime != null) {
      DateTime currentTime = DateTime.now();
      DateTime shiftStartTime = format.parse(widget.ShiftStartTime);
      shiftStartTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        shiftStartTime.hour,
        shiftStartTime.minute,
      );
      Duration difference = shiftStartTime.difference(inTime!);
      int differenceInMinutes = difference.inMinutes.abs();
      lateTime = differenceInMinutes > 5 ? '${differenceInMinutes}m Late' : '';
    }
    print("IN Time : ${inTime}");
    print("Elapsed  : ${_elapsedTime}");

    print(lateTime);
    // DateTime dateTime = format.parse(widget.ShiftStartTime);
    String formattedStopwatchTime =
        '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}';
    setState(() {
      stopwatchtime = formattedStopwatchTime;
    });
    String employeeCurrentStatus = "";
    return Column(
      children: [
        Container(
          height: height / height200,
          decoration: const BoxDecoration(
            color: WidgetColor,
          ),
          padding: EdgeInsets.only(
              left: width / width26,
              top: height / height10,
              right: width / width12),
          child: Column(
            children: [
              Row(
                children: [
                  InterBold(
                    text: widget.ShiftDate,
                    color: color1,
                    fontsize: width / width18,
                  ),
                  SizedBox(
                    width: width / width12,
                  ),
                  Bounce(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.contact_support_outlined,
                        size: width / width20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  )
                ],
              ),
              // SizedBox(height: height / height10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width / width100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: width / width14,
                          color: color1,
                        ),
                        SizedBox(height: height / height10),
                        InterRegular(
                          text: widget.ShiftStartTime,
                          fontsize: width / width16,
                          color: color7,
                        ),
                        SizedBox(height: height / height20),
                        clickedIn
                            ? InterSemibold(
                                text: lateTime,
                                color: Colors.redAccent,
                                fontsize: width / width12,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width / width100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'Out time',
                          fontsize: width / width14,
                          color: color1,
                        ),
                        SizedBox(height: height / height10),
                        InterRegular(
                          text: widget.ShiftEndTime,
                          fontsize: width / width16,
                          color: color7,
                        ),
                        SizedBox(height: height / height20),
                        clickedIn
                            ? InterSemibold(
                                text:
                                    '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                                color: color8,
                                fontsize: width / width12,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: width / width12),
                    height: height / height74,
                    width: width / width70,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      image: DecorationImage(
                        image: AssetImage('assets/images/log_book.png'),
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: height / height10),
        Container(
          height: height / height65,
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: height / height5),
          decoration: BoxDecoration(
            color: WidgetColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: clickedIn,
                  child: Bounce(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool? status =
                          await fireStoreService.checkShiftReturnTaskStatus(
                              widget.EmployeId, widget.ShiftId);
                      setState(() {
                        if (!clickedIn) {
                          clickedIn = true;
                          prefs.setBool('clickedIn', clickedIn);
                          DateTime currentTime = DateTime.now();
                          inTime = currentTime;
                          prefs.setInt(
                              'savedInTime', currentTime.millisecondsSinceEpoch);

                          fireStoreService.INShiftLog(widget.EmployeId);
                          if (status == false) {
                            print("Staus is false");
                          } else {
                            print("Staus is true");
                          }
                          fireStoreService.fetchreturnShiftTasks(widget.ShiftId);
                          startStopwatch();
                        } else {
                          print('already clicked');
                        }
                      });
                    },
                    child: Container(
                      color: WidgetColor,
                      child: Center(
                        child: InterBold(
                          text: 'Start Shift',
                          fontsize: width / width18,
                          color: clickedIn ? Primarycolorlight : Primarycolor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                color: Colors.white,
              ),
              Expanded(
                child: IgnorePointer(
                  ignoring: !clickedIn,
                  child: Bounce(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool? status =
                          await fireStoreService.checkShiftReturnTaskStatus(
                              widget.EmployeId, widget.ShiftId);
                      if (status == true) {
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
                        setState(() {
                          // isPaused = !isPaused;
                          // prefs.setBool("pauseState", isPaused);
                          clickedIn = false;
                          resetStopwatch();
                          resetClickedState();
                          widget.resetShiftStarted();
                        });

                        await fireStoreService.EndShiftLog(
                            widget.EmployeId,
                            formattedStopwatchTime,
                            widget.ShiftId,
                            widget.ShiftAddressName,
                            widget.ShiftBranchId,
                            widget.ShiftCompanyId,
                            widget.EmployeeName);
                        send_mail_onOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      }
                    },
                    child: Container(
                      color: WidgetColor,
                      child: Center(
                        child: InterBold(
                          text: 'End Shift',
                          fontsize: width / width18,
                          color: clickedIn ? Primarycolor : Primarycolorlight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height / height10),
        clickedIn
            ? Button1(
                height: height / height65,
                text: isPaused ? 'Resume' : (onBreak ? 'Resume' : 'Break'),
                fontsize: width / width18,
                color: color5,
                backgroundcolor: WidgetColor,
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  setState(() {
                    isPaused = !isPaused;
                    onBreak = false;
                    prefs.setBool('pauseState', isPaused);
                  });
                  // isPaused ? stopStopwatch() : startStopwatch();
                  if (isPaused) {
                    stopStopwatch();
                    setState(() {
                      onBreak = true;
                      prefs.setBool('onBreak', onBreak);
                    });
                    fireStoreService.BreakShiftLog(widget.EmployeId);
                  } else {
                    onBreak = false;

                    prefs.setBool('onBreak', onBreak);
                    startStopwatch();
                    fireStoreService.ResumeShiftLog(widget.EmployeId);
                  }
                },
              )
            : const SizedBox(),
        Button1(
          text: 'Check Patrolling',
          fontsize: width / width18,
          color: color5,
          backgroundcolor: WidgetColor,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyPatrolsList(
                          ShiftLocationId: widget.ShiftLocationId,
                          EmployeeID: widget.EmployeId,
                          EmployeeName: widget.EmployeeName,
                          ShiftId: widget.ShiftId,
                        )));
          },
        ),
      ],
    );
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
                        fireStoreService.BreakShiftLog(widget.EmployeId);
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
