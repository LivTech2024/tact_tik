import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/button1.dart';

import '../../fonts/inter_medium.dart';
import '../../fonts/inter_regular.dart';
import '../feature screens/widgets/custome_textfield.dart';

class EndShiftScreen extends StatelessWidget {
  EndShiftScreen({super.key});

  TextEditingController CommentController = TextEditingController();

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
              Button1(
                height: 50.h,
                fontsize: 14.sp,
                borderRadius: 10.r,
                backgroundcolor: Theme.of(context).primaryColor,
                text: 'Submit',
                onPressed: () {
                  /*SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();

                                          if (CommentController
                                              .text.isNotEmpty) {
                                            widget.onRefresh();
                                            print("Ending the shift here");
                                            await homeScreenController
                                                .stopBgLocationService();

                                            QuerySnapshot routeSnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'EmployeeRoutes')
                                                    .where('EmpRouteEmpId',
                                                        isEqualTo:
                                                            widget.EmployeId)
                                                    .where(
                                                        'EmpRouteShiftStatus',
                                                        isEqualTo: 'started')
                                                    .get();

                                            if (routeSnapshot.docs.isNotEmpty) {
                                              // Assuming you only get one active route document per employee
                                              DocumentReference routeDocRef =
                                                  routeSnapshot
                                                      .docs.first.reference;

                                              // Update the EmpRouteShiftStatus to "completed"
                                              await routeDocRef.update({
                                                'EmpRouteShiftStatus':
                                                    'completed',
                                                'EmpRouteCompletedAt':
                                                    Timestamp.now(),
                                              });
                                              print(
                                                  'Shift ended for employee: ${widget.EmployeId}');
                                            } else {
                                              print(
                                                  'No active route found for employee:  ${widget.EmployeId}');
                                            }

                                            // send_mail_onOut(data); //Do not uncomment this

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
                                            print("Reached Here");
                                            Navigator.pop(context);
                                            // if (mounted) {
                                            widget.onRefresh();
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
                                          }*/
                },
              )
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
