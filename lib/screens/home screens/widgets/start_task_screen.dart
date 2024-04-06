import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/eg_patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
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
  final String ShiftAddressName;
  final String ShiftCompanyId;
  final String ShiftBranchId;
  final String EmployeeName;
  final String ShiftLocationId;

  // final String ShiftLocation;
  // final String ShiftName;

  StartTaskScreen({
    required this.ShiftDate,
    required this.ShiftEndTime,
    required this.ShiftStartTime,
    required this.EmployeId,
    required this.ShiftId,
    required this.ShiftAddressName,
    required this.ShiftCompanyId,
    required this.ShiftBranchId,
    required this.EmployeeName,
    required this.ShiftLocationId,

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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    DateFormat format = DateFormat.jm(); // "h:mm a" format
    DateTime dateTime = format.parse(widget.ShiftStartTime);

    String formattedStopwatchTime =
        '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}';
// Get current time
    DateTime currentTime = DateTime.now();
    // Duration difference = currentTime.difference(dateTime);
    // bool isLate = currentTime.isAfter(dateTime);

    DateTime shiftStartTime = format.parse(widget.ShiftStartTime);
    Duration difference = currentTime.difference(shiftStartTime);
    bool isLate = currentTime.isAfter(shiftStartTime);
    String lateTime = isLate ? '${difference.inMinutes.abs()}m Late' : '';
    String employeeCurrentStatus = "";
    return Column(
      children: [
        Container(
          height: height / height242,
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
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.contact_support_outlined,
                      size: width / width20,
                    ),
                    padding: EdgeInsets.zero,
                  )
                ],
              ),
              SizedBox(height: height / height10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width / width80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: width / width28,
                          color: color1,
                        ),
                        SizedBox(height: height / height10),
                        InterRegular(
                          text: widget.ShiftStartTime,
                          fontsize: width / width19,
                          color: color7,
                        ),
                        SizedBox(height: height / height20),
                        clickedIn
                            ? InterSemibold(
                                text: lateTime,
                                color: Colors.redAccent,
                                fontsize: width / width10,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width / width70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'Out time',
                          fontsize: width / width20,
                          color: color1,
                        ),
                        SizedBox(height: height / height10),
                        InterRegular(
                          text: widget.ShiftEndTime,
                          fontsize: width / width19,
                          color: color7,
                        ),
                        SizedBox(height: height / height20),
                        clickedIn
                            ? InterSemibold(
                                text:
                                    '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                                color: color8,
                                fontsize: width / width14,
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
                  )
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
                        fontsize: width / width18,
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
                    fireStoreService.EndShiftLog(
                        widget.EmployeId,
                        formattedStopwatchTime,
                        widget.ShiftId,
                        widget.ShiftAddressName,
                        widget.ShiftBranchId,
                        widget.ShiftCompanyId,
                        widget.EmployeeName);
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
                        fontsize: width / width18,
                        color: clickedIn ? Primarycolor : Primarycolorlight,
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
                text: isPaused ? 'Resume' : 'Break',
                fontsize: width / width18,
                color: color5,
                backgroundcolor: WidgetColor,
                onPressed: () {
                  setState(() {
                    isPaused = !isPaused;
                  });
                  if (isPaused) {
                    fireStoreService.BreakShiftLog(widget.EmployeId);
                  } else {
                    fireStoreService.ResumeShiftLog(widget.EmployeId);
                  }
                },
              )
            : const SizedBox(),
        issShift
            ? const SizedBox()
            : Button1(
                text: 'Check Patrolling',
                fontsize: width / width18,
                color: color5,
                backgroundcolor: WidgetColor,
                onPressed: () {},
              ),
        Button1(
          text: 'Check Patrolling',
          fontsize: width / width18,
          color: color5,
          backgroundcolor: WidgetColor,
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyPatrolsList(
                          ShiftLocationId: widget.ShiftLocationId,
                        )));
          },
        )
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
