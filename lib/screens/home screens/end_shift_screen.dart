import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/screens/home%20screens/controller/home_screen_controller.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../fonts/inter_medium.dart';
import '../../fonts/inter_regular.dart';
import '../feature screens/widgets/custome_textfield.dart';

// widget.EmployeId,
//                       widget.EmployeeName,
//                       widget.ShiftCompanyId,
//                       widget.ShiftBranchId,
//                       widget.ShiftClientID,
//                       widget.ShiftLocationId,
// formattedStopwatchTime,
//                       widget.ShiftId,
//                       widget.ShiftAddressName,
//                       widget.ShiftLocationId
class EndShiftScreen extends StatefulWidget {
  final String ShiftClientID;
  final String EmployeId;
  final String EmployeeName;
  final String ShiftCompanyId;
  final String ShiftBranchId;
  final String ShiftLocationId;
  final String formattedStopwatchTime;
  final String ShiftId;
  final String ShiftAddressName;
  final String ShiftName;

  EndShiftScreen(
      {super.key,
      required this.ShiftClientID,
      required this.EmployeId,
      required this.EmployeeName,
      required this.ShiftCompanyId,
      required this.ShiftBranchId,
      required this.ShiftLocationId,
      required this.formattedStopwatchTime,
      required this.ShiftId,
      required this.ShiftAddressName,
      required this.ShiftName});

  @override
  State<EndShiftScreen> createState() => _EndShiftScreenState();
}

class _EndShiftScreenState extends State<EndShiftScreen> {
  TextEditingController CommentController = TextEditingController();
  FireStoreService fireStoreService = FireStoreService();
  bool _isLoading = false;
  final homeScreenController = HomeScreenController.instance;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'End Screen',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              InterRegular(
                text: 'Add Reason',
                color: Theme.of(context).textTheme.titleSmall!.color,
                fontsize: 12.sp,
              ),
              SizedBox(height: 20.h),
              CustomeTextField(
                hint: 'Add Reason',
                showIcon: false,
                controller: CommentController,
              ),
              SizedBox(height: 20.h),
              IgnorePointer(
                ignoring: _isLoading,
                child: Button1(
                  height: 50.h,
                  fontsize: 14.sp,
                  borderRadius: 10.r,
                  backgroundcolor: Theme.of(context).primaryColor,
                  text: 'Submit',
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    if (CommentController.text.isNotEmpty) {
                      setState(() {
                        _isLoading = true;
                      });
                      // widget.onRefresh();
                      print("Ending the shift here");
                      await homeScreenController.stopBgLocationService();

                      QuerySnapshot routeSnapshot = await FirebaseFirestore
                          .instance
                          .collection('EmployeeRoutes')
                          .where('EmpRouteEmpId', isEqualTo: widget.EmployeId)
                          .where('EmpRouteShiftStatus', isEqualTo: 'started')
                          .get();

                      if (routeSnapshot.docs.isNotEmpty) {
                        // Assuming you only get one active route document per employee
                        DocumentReference routeDocRef =
                            routeSnapshot.docs.first.reference;

                        // Update the EmpRouteShiftStatus to "completed"
                        await routeDocRef.update({
                          'EmpRouteShiftStatus': 'completed',
                          'EmpRouteCompletedAt': Timestamp.now(),
                        });
                        print('Shift ended for employee: ${widget.EmployeId}');
                      } else {
                        print(
                            'No active route found for employee:  ${widget.EmployeId}');
                      }

                      // send_mail_onOut(data); //Do not uncomment this

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
                          widget.ShiftName,
                          null,
                          null);
                      await fireStoreService.EndShiftLogComment(
                          widget.EmployeId,
                          widget.formattedStopwatchTime,
                          widget.ShiftId,
                          widget.ShiftAddressName,
                          widget.ShiftBranchId,
                          widget.ShiftCompanyId,
                          widget.EmployeeName,
                          widget.ShiftClientID,
                          CommentController.text);
                      // setState(() {
                      //   // isPaused = !isPaused;
                      //   // prefs.setBool("pauseState", isPaused);
                      //   clickedIn = false;
                      //   // resetStopwatch();
                      //   // resetClickedState();
                      //   widget.resetShiftStarted();
                      //   prefs.setBool(
                      //       'ShiftStarted', false);
                      // });
                      setState(() {
                        _isLoading = false;
                      });
                      print("Reached Here");
                      // Navigator.pop(context);
                      // if (mounted) {
                      // widget.onRefresh();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                  key: ValueKey('HomeScreen'),
                                  refreshCallback: () {
                                    print("Callback Called");
                                    // Perform any additional actions if needed
                                  },
                                ),
                            fullscreenDialog: true),
                        (route) => false,
                      );

                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => HomeScreen(),
                      //   ),
                      //   (Route<dynamic> route) => route
                      //       .isFirst, // Remove all routes until the first one
                      // );
                      // }
                    } else {
                      showErrorToast(context, "Reason cannot be empty");
                    }
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
          ),
        ),
      ),
    );
  }
}

// <<<<<<<<<<<<<<<<<<< Dialog code
/*showDialog(
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
                                        onPressed: () async ,
                                        child: InterRegular(
                                            text: 'Submit',
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .color),
                                      ),
                                    ]);
                              });*/
// <<<<<<<<<<<<<<<<<<< Dialog code
