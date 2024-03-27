import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_semibold.dart';

class StartTaskScreen extends StatefulWidget {
  final String ShiftDate;
  final String ShiftEndTime;
  final String ShiftStartTime;
  final String EmployeId;
  final String ShiftId;
  // final String ShiftLocation;
  // final String ShiftName;

  StartTaskScreen({
    required this.ShiftDate,
    required this.ShiftEndTime,
    required this.ShiftStartTime,
    required this.EmployeId,
    required this.ShiftId,

    // required this.ShiftLocation,
    // required this.ShiftName,
  });
  @override
  State<StartTaskScreen> createState() => _StartTaskScreenState();
}

class _StartTaskScreenState extends State<StartTaskScreen> {
  bool clickedIn = false;
  FireStoreService fireStoreService = FireStoreService();
  bool issShift = true;
  late Timer _stopwatchTimer;
  int _stopwatchSeconds = 0;

  bool isPaused = false;
  @override
  void initState() {
    super.initState();
    _stopwatchTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (clickedIn && !isPaused) {
        setState(() {
          _stopwatchSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _stopwatchTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat.jm(); // "h:mm a" format
    DateTime dateTime = format.parse(widget.ShiftStartTime);
    String formattedStopwatchTime =
        '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}';
// Get current time
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(dateTime);
    bool isLate = currentTime.isAfter(dateTime);
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: WidgetColor,
          ),
          padding: EdgeInsets.only(left: 26, top: 10, right: 12),
          child: Column(
            children: [
              Row(
                children: [
                  InterBold(
                    text: widget.ShiftDate,
                    color: color1,
                    fontsize: 18,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.contact_support_outlined,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 98,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: 28,
                          color: color1,
                        ),
                        SizedBox(height: 10),
                        InterRegular(
                          text: widget.ShiftStartTime,
                          fontsize: 19,
                          color: color7,
                        ),
                        SizedBox(height: 20),
                        clickedIn
                            ? InterSemibold(
                                text: isLate
                                    ? '${difference.inMinutes.abs()}m Late'
                                    : '',
                                color: Colors.redAccent,
                                fontsize: 10,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 98,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: 28,
                          color: color1,
                        ),
                        SizedBox(height: 10),
                        InterRegular(
                          text: widget.ShiftEndTime,
                          fontsize: 19,
                          color: color7,
                        ),
                        SizedBox(height: 20),
                        clickedIn
                            ? InterSemibold(
                                text:
                                    '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                                color: color8,
                                fontsize: 14,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 12),
                    height: 74,
                    width: 70,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      image: DecorationImage(
                          image: AssetImage('assets/images/log_book.png'),
                          fit: BoxFit.fitHeight,
                          filterQuality: FilterQuality.high),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 65,
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: WidgetColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!clickedIn) {
                        clickedIn = true;
                        fireStoreService.INShiftLog(widget.EmployeId);
                      } else {
                        print('already clicked');
                      }
                    });
                  },
                  child: Container(
                    color: WidgetColor,
                    child: Center(
                      child: InterBold(
                        text: 'IN',
                        fontsize: 18,
                        color: clickedIn ? Primarycolorlight : Primarycolor,
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                color: Colors.white,
              ),
              /*Button1(
                text: 'OUT',
                fontsize: 18,
                color: clickedIn ? Primarycolor : Primarycolorlight,
                flex: 2,
                onPressed: () {
                  setState(() {
                    if (!clickedIn) {
                      clickedIn = true;
                    } else {
                      print('already clicked');
                    }
                  });
                },
              ),*/
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isPaused = !isPaused;
                    });
                    fireStoreService.EndShiftLog(widget.EmployeId,
                        formattedStopwatchTime, widget.ShiftId);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  child: Container(
                    color: WidgetColor,
                    child: Center(
                      child: InterBold(
                        text: 'OUT',
                        fontsize: 18,
                        color: clickedIn ? Primarycolor : Primarycolorlight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        clickedIn
            ? Container(
                height: 65,
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
                    fontsize: 18,
                    color: Primarycolor,
                  ),
                ),
              )
            : const SizedBox(),
        issShift
            ? const SizedBox()
            : Button1(
                text: 'Check Patrolling',
                fontsize: 18,
                color: color5,
                backgroundcolor: WidgetColor,
                onPressed: () {},
              ),
      ],
    );
  }
}
