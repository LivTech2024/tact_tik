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
      this.toAccept = false,
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
  final bool? toAccept;

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
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(empId)
          .get();
      print('shift information screen');
      print('empId: $empId');
      print('shiftId: $shiftId');
      if (userSnapshot.exists) {
        guardName = userSnapshot['EmployeeName'];
        final supervisorId = userSnapshot['EmployeeSupervisorId'][0];
        if (supervisorId != null) {
          DocumentSnapshot supervisorSnapshot = await FirebaseFirestore.instance
              .collection('Employees')
              .doc(supervisorId)
              .get();
          if (supervisorSnapshot.exists) {
            supervisorName = supervisorSnapshot['EmployeeName'];
          }
        }
      }

      // Fetch shift info from Shifts collection
      DocumentSnapshot shiftSnapshot = await FirebaseFirestore.instance
          .collection('Shifts')
          .doc(shiftId)
          .get();
      if (shiftSnapshot.exists) {
        // TODO from employee EmployeeSupervisorId gets name SupervisorName
        shiftName = shiftSnapshot['ShiftName'];
        shiftDetails =
            shiftSnapshot['ShiftDescription'] ?? "No Description Available";
        location =
            shiftSnapshot['ShiftLocationName'] ?? "No Location Available";
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
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30.h),
                          InterBold(
                            text: "Guard Name : $guardName",
                            fontsize: 18.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: 30.h),
                          InterBold(
                            text: 'Shift Name : $shiftName',
                            fontsize: 18.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: 30.h),
                          InterBold(
                            text: 'Details',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: 14.h),
                          InterRegular(
                            text: shiftDetails,
                            fontsize: 14.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            maxLines: 3,
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Supervisor :',
                                fontsize: 16.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(width: 4.w),
                              InterRegular(
                                text: supervisorName,
                                fontsize: 14.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              )
                            ],
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Time :',
                                fontsize: 16.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(width: 4.w),
                              InterRegular(
                                text: '${widget.startTime}-${widget.endTime}',
                                fontsize: 14.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ],
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 24.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(width: 4.w),
                              InterRegular(
                                text: location,
                                fontsize: 14.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ],
                          ),
                          if (widget.toRequest)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 50.h),
                                InterBold(
                                  text: '*Shift already taken',
                                  fontsize: 18.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                                SizedBox(height: 30.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InterBold(
                                      text: 'Time:',
                                      fontsize: 16.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                    ),
                                    SizedBox(width: 4.w),
                                    InterRegular(
                                      text:
                                          '${widget.startTime}-${widget.endTime}',
                                      fontsize: 14.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                    IgnorePointer(
                      ignoring: /**condition clicked true* */ false /*Todo pass the bool of true and false*/,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Button1(
                            text: widget.toRequest ? 'Request' : 'Acknowledge ',
                            onPressed: () {
                              if (widget.toRequest) {
                                onExchangeShift(widget.empId, widget.shiftId);
                              } else {
                                onAcceptShift(widget.empId, widget.shiftId);
                              }
                            },
                            backgroundcolor: Theme.of(context).primaryColor,
                            // Todo apply this to the buttons when one of the button is clicked
                            // backgroundcolor: *condition clicked true* ? Theme.of(context).primaryColorLight :Theme.of(context).primaryColor,
                            borderRadius: 10.r,
                            fontsize: 18.sp,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          // SizedBox(height: 50.h),
                          widget.toRequest
                              ?
                              // ? Column(
                              //     children: [
                              // SizedBox(height: 20.h),
                              Button1(
                                  text: 'Exchange',
                                  onPressed: () {},
                                  backgroundcolor: Theme.of(context).primaryColor,
                                  // Todo apply this to the buttons when one of the button is clicked
                                  // backgroundcolor: *condition clicked true* ? Theme.of(context).primaryColorLight :Theme.of(context).primaryColor,
                                  borderRadius: 10.r,
                                  fontsize: 18.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                  useBorder: true,
                                )
                              // ],
                              // )
                              : SizedBox(),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> onExchangeAcceptShift(
      String currentUserId, String empId, String shiftId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Query to find the document with the specified fields
      QuerySnapshot querySnapshot = await firestore
          .collection('ShiftExchange')
          .where('ShiftExchReqReceiverId', isEqualTo: currentUserId)
          .where('ShiftExchReqShiftId', isEqualTo: shiftId)
          .limit(1)
          .get();

      // Check if a document is found
      if (querySnapshot.docs.isNotEmpty) {
        // Get the document id
        DocumentReference documentReference =
            querySnapshot.docs.first.reference;

        // Update the document's status to 'accepted'
        await documentReference.update({
          'ShiftExchReqStatus': 'accepted',
        });

        print('Shift exchange request accepted successfully.');
      } else {
        print('No matching shift exchange request found.');
      }
    } catch (e) {
      print('Error accepting shift exchange request: $e');
    }
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

        List<String> acknowledgedByEmpIds =
            List<String>.from(snapshot['ShiftAcknowledgedByEmpId']);

        if (!acknowledgedByEmpIds.contains(empId)) {
          acknowledgedByEmpIds.add(empId);
          transaction.update(
              shiftDoc, {'ShiftAcknowledgedByEmpId': acknowledgedByEmpIds});
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
      final exchangeCollection =
          FirebaseFirestore.instance.collection('ShiftExchange');

      final shiftDoc = shiftsCollection.doc(shiftId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(shiftDoc);

        if (!snapshot.exists) {
          throw Exception("Shift does not exist!");
        }

        final exchangeDoc = exchangeCollection.doc();
        Map<String, dynamic> dataJson = snapshot.data() ?? {};
        transaction.set(exchangeDoc, {
          'ShiftExchReqId': exchangeDoc.id,
          'ShiftExchReqSenderId': widget.currentUserId,
          'ShiftExchReqReceiverId':
              (dataJson['ShiftAssignedUserId'] ?? []).first,
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
