import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/sizes.dart';
import '../../../../common/widgets/customToast.dart';

class ShiftInformation extends StatefulWidget {
  const ShiftInformation(
      {super.key,
      this.toRequest = false,
      required this.empId,
      required this.shiftId,
      required this.startTime,
      required this.endTime,
      required this.currentUserId});
  final bool toRequest;
  final String empId;
  final String shiftId;
  final String startTime;
  final String endTime;
  final String currentUserId;

  @override
  State<ShiftInformation> createState() => _ShiftInformationState();
}

class _ShiftInformationState extends State<ShiftInformation> {
  String guardName = '';
  String shiftDetails = '';
  String shiftName = '';
  String supervisorName = '';
  String location = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUsersAndShiftInfo(widget.empId, widget.shiftId);
  }

  Future<void> _getUsersAndShiftInfo(String empId, String shiftId) async {
    try {
      // Fetch user info from Employees collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('Employees').doc(empId).get();
      if (userSnapshot.exists) {
        guardName = userSnapshot['EmployeeName'];
        final supervisorId = userSnapshot['EmployeeSupervisorId'][0];
        if (supervisorId != null) {
          DocumentSnapshot supervisorSnapshot = await FirebaseFirestore.instance.collection('Employees').doc(supervisorId).get();
          if (supervisorSnapshot.exists) {
            supervisorName = supervisorSnapshot['EmployeeName'];
          }
        }
      }

      // Fetch shift info from Shifts collection
      DocumentSnapshot shiftSnapshot = await FirebaseFirestore.instance.collection('Shifts').doc(shiftId).get();
      if (shiftSnapshot.exists) {
        // TODO from employee EmployeeSupervisorId gets name SupervisorName
        shiftName = shiftSnapshot['ShiftName'];
        shiftDetails = shiftSnapshot['ShiftDescription'] ?? "No Description Available";
        location = shiftSnapshot['ShiftLocationName'] ?? "No Location Available";
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: isLoading
          ? Scaffold(
              backgroundColor: Theme.of(context).canvasColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                  ),
                  padding: EdgeInsets.only(left: width / width20),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: InterMedium(
                  text: widget.toRequest ? 'Shift' : 'Shift- $guardName',
                ),
                centerTitle: widget.toRequest,
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height / height30),
                          InterBold(
                            text: "Guard Name : $guardName",
                            fontsize: width / width18,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: height / height30),
                          InterBold(
                            text: 'Shift Name : $shiftName',
                            fontsize: width / width18,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: height / height30),
                          InterBold(
                            text: 'Details',
                            fontsize: width / width16,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: height / height14),
                          InterRegular(
                            text: shiftDetails,
                            fontsize: width / width14,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            maxLines: 3,
                          ),
                          SizedBox(height: height / height30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Supervisor :',
                                fontsize: width / width16,
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                              SizedBox(width: width / width4),
                              InterRegular(
                                text: supervisorName,
                                fontsize: width / width14,
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                              )
                            ],
                          ),
                          SizedBox(height: height / height30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Time :',
                                fontsize: width / width16,
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                              SizedBox(width: width / width4),
                              InterRegular(
                                text: '${widget.startTime}-${widget.endTime}',
                                fontsize: width / width14,
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                            ],
                          ),
                          SizedBox(height: height / height30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: width / width24,
                                color: Theme.of(context).textTheme.bodyMedium!.color,
                              ),
                              SizedBox(width: width / width4),
                              InterRegular(
                                text: location,
                                fontsize: width / width14,
                                color: Theme.of(context).textTheme.bodyLarge!.color,
                              ),
                            ],
                          ),
                          if (widget.toRequest)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height / height50),
                                InterBold(
                                  text: '*Shift already taken',
                                  fontsize: width / width18,
                                  color: Theme.of(context).textTheme.bodyMedium!.color,
                                ),
                                SizedBox(height: height / height30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InterBold(
                                      text: 'Time:',
                                      fontsize: width / width16,
                                      color: Theme.of(context).textTheme.bodyMedium!.color,
                                    ),
                                    SizedBox(width: width / width4),
                                    InterRegular(
                                      text: '${widget.startTime}-${widget.endTime}',
                                      fontsize: width / width14,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button1(
                          text: widget.toRequest ? 'Exchange' : 'Accept',
                          onPressed: () {
                            if (widget.toRequest) {
                              onExchangeShift(widget.empId, widget.shiftId);
                            } else {
                              onAcceptShift(widget.empId, widget.shiftId);
                            }
                          },
                          backgroundcolor: Theme.of(context).primaryColor,
                          borderRadius: 10.r,
                          fontsize: 18.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: height / height100),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> onAcceptShift(String empId, String shiftId) async {
    try {
      final shiftsCollection = FirebaseFirestore.instance.collection('Shifts');
      final shiftDoc = shiftsCollection.doc(shiftId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(shiftDoc);

        if (!snapshot.exists) {
          throw Exception("Shift does not exist!");
        }

        List<String> acknowledgedByEmpIds = List<String>.from(snapshot['ShiftAcknowledgedByEmpId']);

        if (!acknowledgedByEmpIds.contains(empId)) {
          acknowledgedByEmpIds.add(empId);
          transaction.update(shiftDoc, {'ShiftAcknowledgedByEmpId': acknowledgedByEmpIds});
        }
      });

      showSuccessToast(context, "Shift accepted successfully");

      print("Shift acknowledged successfully by $empId");
    } catch (e) {
      print("Failed to acknowledge shift: $e");
    }
  }

  Future<void> onExchangeShift(String empId, String shiftId) async {
    try {
      final shiftsCollection = FirebaseFirestore.instance.collection('Shifts');
      final exchangeCollection = FirebaseFirestore.instance.collection('ShiftExchange');

      final shiftDoc = shiftsCollection.doc(shiftId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(shiftDoc);

        if (!snapshot.exists) {
          throw Exception("Shift does not exist!");
        }

        final exchangeDoc = exchangeCollection.doc();
        transaction.set(exchangeDoc, {
          'ShiftExchReqId': exchangeDoc.id,
          'ShiftExchReqSenderId': empId,
          'ShiftExchReqReceiverId': widget.currentUserId,
          'ShiftExchReqShiftId': shiftId,
          'ShiftExchReqStatus': 'pending',
          'ShiftExchReqCreatedAt': DateTime.now(),
          'ShiftExchReqModifiedAt': DateTime.now(),
        });
      });

      showSuccessToast(context, "Shift exchange request sent successfully");

      print("Shift exchange request successfully by $empId");
    } catch (e) {
      print("Failed to shift exchange request: $e");
    }
  }
}
