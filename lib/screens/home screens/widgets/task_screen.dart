import 'package:flutter/material.dart';
import 'package:tact_tik/screens/home%20screens/widgets/start_task_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

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
  final String ShiftName;
  bool isWithINRadius;
  final String empId;
  final String shiftId;
  final String patrolDate;
  final String patrolTime;
  final String patrollocation;
  final bool issShiftFetched;

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
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool ShiftStarted = false;
  bool issShift = false;
  FireStoreService fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    issShift = widget.issShiftFetched;
  }

  Future<void> _refreshData() async {
    // Fetch patrol data from Firestore (assuming your logic exists)
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          ShiftStarted
              ? StartTaskScreen(
                  ShiftDate: widget.ShiftDate,
                  ShiftStartTime: widget.ShiftStartTime,
                  ShiftEndTime: widget.ShiftEndTime,
                  EmployeId: widget.empId,
                  ShiftId: widget.shiftId,
                )
              : Column(
                  children: [
                    Container(
                      height: 242,
                      color: WidgetColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 20, left: 26),
                                width: 200,
                                height: 96,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InterBold(
                                      text: widget.ShiftDate,
                                      color: Colors.white,
                                      fontsize: 18,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InterMedium(
                                          text: 'In time',
                                          color: Colors.white,
                                          fontsize: 18,
                                        ),
                                        InterMedium(
                                          text: widget.ShiftStartTime,
                                          color: Colors.white,
                                          fontsize: 16,
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InterMedium(
                                          text: 'In time',
                                          color: Colors.white,
                                          fontsize: 18,
                                        ),
                                        InterMedium(
                                          text: widget.ShiftEndTime,
                                          color: Colors.white,
                                          fontsize: 16,
                                        )
                                      ],
                                    ),
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
                                      image: AssetImage(
                                          'assets/images/log_book.png'),
                                      fit: BoxFit.fitHeight,
                                      filterQuality: FilterQuality.high),
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 26.0),
                            height: 90,
                            color: colorRed,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InterMedium(
                                      text: 'Location',
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 38),
                                Flexible(
                                  child: InterRegular(
                                    text: widget.ShiftLocation,
                                    fontsize: 16,
                                    color: Colors.white,
                                    maxLines: 2,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    Button1(
                      text: 'Start Shift',
                      fontsize: 18,
                      color: issShift ? color5 : color12,
                      backgroundcolor:
                          issShift ? WidgetColor : color11 /*.withOpacity(50)*/,
                      onPressed: () {
                        setState(() {
                          ShiftStarted = true;
                          fireStoreService.startShiftLog(
                              widget.empId, widget.shiftId);
                        });
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    issShift
                        ? SizedBox()
                        : Button1(
                            text: 'Check Patrolling',
                            fontsize: 18,
                            color: color5,
                            backgroundcolor: WidgetColor,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OpenPatrollingScreen(
                                            empId: widget.empId,
                                          )));
                            },
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
