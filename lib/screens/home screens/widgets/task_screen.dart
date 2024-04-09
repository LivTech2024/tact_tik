import 'package:flutter/material.dart';
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

  // bool issShift = false;
  FireStoreService fireStoreService = FireStoreService();
  UserLocationChecker locationChecker = UserLocationChecker();

  @override
  void initState() {
    super.initState();
    // issShift = widget.issShiftFetched;
  }

  Future<void> _refreshData() async {
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
              ? StartTaskScreen(
                  ShiftDate: widget.ShiftDate,
                  ShiftStartTime: widget.ShiftStartTime,
                  ShiftEndTime: widget.ShiftEndTime,
                  EmployeId: widget.empId,
                  ShiftId: widget.shiftId,
                  ShiftAddressName: widget.ShiftName,
                  ShiftCompanyId: widget.ShiftCompanyId,
                  ShiftBranchId: widget.ShiftBranchId,
                  EmployeeName: widget.EmpName,
                  ShiftLocationId: widget.ShiftLocationId,
                )
              : Column(
                  children: [
                    widget.ShiftDate.isNotEmpty
                        ? Container(
                            height: height / height242,
                            color: WidgetColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InterBold(
                                            text: widget.ShiftDate,
                                            color: Colors.white,
                                            fontsize: width / width18,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InterMedium(
                                                text: 'In time',
                                                color: Colors.white,
                                                fontsize: width / width18,
                                              ),
                                              InterMedium(
                                                text: widget.ShiftStartTime,
                                                color: Colors.white,
                                                fontsize: width / width16,
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InterMedium(
                                                text: 'Out time',
                                                color: Colors.white,
                                                fontsize: width / width18,
                                              ),
                                              InterMedium(
                                                text: widget.ShiftEndTime,
                                                color: Colors.white,
                                                fontsize: width / width16,
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        right: width / width12,
                                      ),
                                      height: height / height74,
                                      width: width / width70,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / width26),
                                  height: height / height90,
                                  color: colorRed,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.redAccent,
                                            size: width / width20,
                                          ),
                                          SizedBox(
                                            height: height / height10,
                                          ),
                                          InterMedium(
                                            text: 'Location',
                                            color: Colors.white,
                                            fontsize: width / width16,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: width / width38),
                                      Flexible(
                                        child: InterRegular(
                                          text: widget.ShiftLocation,
                                          fontsize: width / width16,
                                          color: Colors.white,
                                          maxLines: 2,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: InterMedium(
                              text: 'No Shifts',
                              textAlign: TextAlign.center,
                              color: color2,
                              fontsize: width / width18,
                            ),
                          ),
                    SizedBox(
                      height: height / height22,
                    ),
                    widget.ShiftDate.isNotEmpty
                        ? Button1(
                            text: 'Start Shift',
                            fontsize: width / width18,
                            color: color5,
                            backgroundcolor: WidgetColor /*.withOpacity(50)*/,
                            onPressed: () async {
                              print(widget.CheckUserRadius);
                              if (widget.CheckUserRadius == true) {
                                bool status =
                                    await locationChecker.checkLocation(
                                        widget.ShiftLatitude,
                                        widget.shiftLongitude,
                                        widget.ShiftRadius);
                                print("Status :$status");
                                if (status == true) {
                                  setState(() {
                                    ShiftStarted = true;
                                    fireStoreService.startShiftLog(
                                        widget.empId, widget.shiftId);
                                  });
                                } else {
                                  showCustomDialog(context, "Location",
                                      "Move into Shift Radius to continue");
                                }
                              } else {
                                Map<String, dynamic> emailParams = {
                                  'to_email': 'recipient@example.com',
                                  'from_name': 'Your Name',
                                  'reply_to': 'your_email@example.com',
                                  'subject': 'Your Subject',
                                  'message': 'Your Message',
                                };
                                // bool result = await sendEmail(emailParams);
                                // print('Email sent: $result');s
                                setState(() {
                                  ShiftStarted = true;
                                });

                                //if the check user radius is off we can start the shift
                              }

                              // bool isWithInRaius = locationChecker.checkLocation();
                            },
                          )
                        : SizedBox(),
                    SizedBox(
                      height: height / height10,
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
