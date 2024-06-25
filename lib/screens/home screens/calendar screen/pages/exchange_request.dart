import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/widgets/button1.dart';
import '../../../../common/widgets/customToast.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';

class ExchangeRequest extends StatefulWidget {
  const ExchangeRequest({
    super.key,
    this.isRequest = true,
    this.toAccept = false,
    required this.exchangeId,
  });

  final String exchangeId;
  final bool? toAccept;
  final bool isRequest;

  @override
  State<ExchangeRequest> createState() => _ExchangeRequestState();
}

class _ExchangeRequestState extends State<ExchangeRequest> {
  // Initialize local variables for storing retrieved information
  String receiverName = '';
  String receiverSupervisorId = '';
  String senderName = '';
  String senderSupervisorId = '';
  String receiverShiftName = '';
  String receiverShiftDescription = '';
  String receiverShiftLocationAddress = '';
  String senderShiftName = '';
  String senderShiftDescription = '';
  String senderShiftLocationAddress = '';
  String senderShiftStartTime = '';
  String senderShiftEndTime = '';
  String receiverShiftStartTime = '';
  String receiverShiftEndTime = '';
  String senderSupervisorIdName = '';
  String receiverSupervisorName = '';
  bool _isLoading = false;
  bool _isTransactionLoading = false;
  String receiverShiftId = '';
  String receiverId = '';
  String senderId = '';
  String senderShiftId = '';
  bool isAlreadyAcknowledged = false;

  @override
  void initState() {
    print('exchange request screen');
    super.initState();
    if (widget.isRequest) {
      print('exchange id ${widget.exchangeId}');
      getShiftExchangeInfo(widget.exchangeId);
    } else {
      print('exchange id ${widget.exchangeId}');
      getShiftRequestInfo(widget.exchangeId);
    }
  }

  findTheShiftIsAlreadyAckoleded(String receiverId, String shiftId) async {
    isAlreadyAcknowledged = await isReceiverAlreadyAcknowledgedShift(
      receiverId: receiverId,
      shiftId: shiftId,
    );
    print('isAlreadyAcknowledged: $isAlreadyAcknowledged');
  }

  Future<bool> isReceiverAlreadyAcknowledgedShift({
    required String receiverId,
    required String shiftId,
  }) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Fetch the document from the Shifts collection with the given shiftId
      DocumentSnapshot shiftDoc =
          await firestore.collection('Shifts').doc(shiftId).get();

      if (shiftDoc.exists) {
        // Extract the ShiftAcknowledgedByEmpId list from the document
        List<dynamic> acknowledgedByList = shiftDoc['ShiftAcknowledgedByEmpId'];

        // Check if the receiverId is already in the ShiftAcknowledgedByEmpId list
        bool isReceiverAvailable = acknowledgedByList.contains(receiverId);

        // Print or return the result as needed
        print('Is receiver available: $isReceiverAvailable');

        // You can also return the result if needed
        return isReceiverAvailable;
      } else {
        print('Shift document does not exist.');
        return false;
      }
    } catch (e) {
      print('Error fetching shift document: $e');
      return false;
    }
  }

  Future<void> getShiftExchangeInfo(String exchangeId) async {
    setState(() {
      _isLoading = true;
    });
    // Initialize Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Query ShiftExchange collection
      DocumentSnapshot shiftExchangeDoc =
          await firestore.collection('ShiftExchange').doc(exchangeId).get();

      if (!shiftExchangeDoc.exists) {
        print('No ShiftExchange document found for the given exchangeId');
        return;
      }

      // Step 2: Extract relevant fields from the ShiftExchange document
      var shiftExchangeData = shiftExchangeDoc.data() as Map<String, dynamic>;
      receiverShiftId = shiftExchangeData['ShiftExchReceiverShiftId'];
      receiverId = shiftExchangeData['ShiftExchReqReceiverId'];
      senderId = shiftExchangeData['ShiftExchReqSenderId'];
      senderShiftId = shiftExchangeData['ShiftExchSenderShiftId'];

      await findTheShiftIsAlreadyAckoleded(senderId, senderShiftId);

      // Step 3: Query Employees collection for Receiver information
      DocumentSnapshot receiverDoc =
          await firestore.collection('Employees').doc(receiverId).get();

      if (receiverDoc.exists) {
        var receiverData = receiverDoc.data() as Map<String, dynamic>;
        receiverName = receiverData['EmployeeName'] ?? '';
        receiverSupervisorId = receiverData['EmployeeSupervisorId'][0] ?? '';
      }

      if (receiverSupervisorId.isNotEmpty) {
        DocumentSnapshot supervisorSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(receiverSupervisorId)
            .get();
        if (supervisorSnapshot.exists) {
          receiverSupervisorName = supervisorSnapshot['EmployeeName'] ?? '';
        }
      }

      // Step 3: Query Employees collection for Sender information
      DocumentSnapshot senderDoc =
          await firestore.collection('Employees').doc(senderId).get();

      if (senderDoc.exists) {
        var senderData = senderDoc.data() as Map<String, dynamic>;
        senderName = senderData['EmployeeName'] ?? '';
        senderSupervisorId = senderData['EmployeeSupervisorId'][0] ?? '';
      }

      if (senderSupervisorId.isNotEmpty) {
        DocumentSnapshot supervisorSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(senderSupervisorId)
            .get();
        if (supervisorSnapshot.exists) {
          senderSupervisorIdName = supervisorSnapshot['EmployeeName'] ?? '';
        }
      }

      // Step 4: Query Shifts collection for ReceiverShift information
      DocumentSnapshot receiverShiftDoc =
          await firestore.collection('Shifts').doc(receiverShiftId).get();

      if (receiverShiftDoc.exists) {
        var receiverShiftData = receiverShiftDoc.data() as Map<String, dynamic>;
        receiverShiftName = receiverShiftData['ShiftName'] ?? '';
        receiverShiftDescription =
            receiverShiftData['ShiftDescription'] ?? 'No details found.';
        receiverShiftLocationAddress =
            receiverShiftData['ShiftLocationAddress'] ?? '';
        receiverShiftStartTime = receiverShiftData['ShiftStartTime'] ?? '';
        receiverShiftEndTime = receiverShiftData['ShiftEndTime'] ?? '';
      }

      // Step 4: Query Shifts collection for SenderShift information
      DocumentSnapshot senderShiftDoc =
          await firestore.collection('Shifts').doc(senderShiftId).get();

      if (senderShiftDoc.exists) {
        var senderShiftData = senderShiftDoc.data() as Map<String, dynamic>;
        senderShiftName = senderShiftData['ShiftName'] ?? '';
        senderShiftDescription =
            senderShiftData['ShiftDescription'] ?? 'No details found.';
        senderShiftLocationAddress =
            senderShiftData['ShiftLocationAddress'] ?? '';
        senderShiftStartTime = senderShiftData['ShiftStartTime'] ?? '';
        senderShiftEndTime = senderShiftData['ShiftEndTime'] ?? '';
      }

      if (senderSupervisorId.isNotEmpty) {
        DocumentSnapshot supervisorSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(senderSupervisorId)
            .get();
        if (supervisorSnapshot.exists) {
          senderSupervisorIdName = supervisorSnapshot['EmployeeName'] ?? '';
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = true;
      });
      print('Error retrieving shift exchange info: $e');
    }
  }

  ///==============================================================///
  Future<void> getShiftRequestInfo(String exchangeId) async {
    setState(() {
      _isLoading = true;
    });
    // Initialize Firestore instance
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Query ShiftExchange collection
      DocumentSnapshot shiftExchangeDoc =
          await firestore.collection('ShiftRequests').doc(exchangeId).get();

      if (!shiftExchangeDoc.exists) {
        print('No ShiftExchange document found for the given exchangeId');
        return;
      }
      // Step 2: Extract relevant fields from the ShiftExchange document
      var shiftExchangeData = shiftExchangeDoc.data() as Map<String, dynamic>;
      receiverId = shiftExchangeData['ShiftReqReceiverId'];
      senderId = shiftExchangeData['ShiftReqSenderId'];
      senderShiftId = shiftExchangeData['ShiftReqShiftId'];

      await findTheShiftIsAlreadyAckoleded(senderId, senderShiftId);

      // Step 3: Query Employees collection for Sender information
      DocumentSnapshot senderDoc =
          await firestore.collection('Employees').doc(senderId).get();

      if (senderDoc.exists) {
        var senderData = senderDoc.data() as Map<String, dynamic>;
        senderName = senderData['EmployeeName'];
        senderSupervisorId = senderData['EmployeeSupervisorId'][0] ?? '';
      }
      if (senderSupervisorId.isNotEmpty) {
        DocumentSnapshot supervisorSnapshot = await FirebaseFirestore.instance
            .collection('Employees')
            .doc(senderSupervisorId)
            .get();
        if (supervisorSnapshot.exists) {
          senderSupervisorIdName = supervisorSnapshot['EmployeeName'] ?? '';
        }
      }
      // Step 4: Query Shifts collection for SenderShift information
      DocumentSnapshot senderShiftDoc =
          await firestore.collection('Shifts').doc(senderShiftId).get();

      if (senderShiftDoc.exists) {
        var senderShiftData = senderShiftDoc.data() as Map<String, dynamic>;
        senderShiftName = senderShiftData['ShiftName'] ?? '';
        senderShiftDescription =
            senderShiftData['ShiftDescription'] ?? 'No details found.';
        senderShiftLocationAddress =
            senderShiftData['ShiftLocationAddress'] ?? '';
        senderShiftStartTime = senderShiftData['ShiftStartTime'] ?? '';
        senderShiftEndTime = senderShiftData['ShiftEndTime'] ?? '';
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error retrieving shift exchange info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SafeArea(
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : SafeArea(
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      InterBold(
                        text: widget.isRequest
                            ? "Request From: $senderName"
                            : "Exchange Request From: $senderName",
                        fontsize: 18.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 30.h),
                      InterBold(
                        text: 'Shift Name : $senderShiftName',
                        fontsize: 18.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 30.h),
                      InterBold(
                        text: 'Details',
                        fontsize: 16.sp,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      ),
                      SizedBox(height: 14.h),
                      InterRegular(
                        text: senderShiftDescription,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(width: 4.w),
                          InterRegular(
                            text: senderSupervisorIdName,
                            fontsize: 14.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(width: 4.w),
                          InterRegular(
                            text: '$senderShiftStartTime-$senderShiftEndTime',
                            fontsize: 14.sp,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
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
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: InterRegular(
                              maxLines: 2,
                              text: senderShiftLocationAddress,
                              fontsize: 14.sp,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),
                        ],
                      ),
                      if (widget.isRequest!)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 50.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50.h,
                                  width: 110.w,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/images/exchange.svg',
                                      width: 20.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 50.h),
                            InterBold(
                              text: widget.isRequest
                                  ? "Request to: $receiverName"
                                  : "Exchange Request From: guardName",
                              fontsize: 18.sp,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                            SizedBox(height: 30.h),
                            InterBold(
                              text: 'Shift Name : $receiverShiftName',
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
                              text: receiverShiftDescription,
                              fontsize: 14.sp,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color,
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
                                  text: receiverSupervisorName,
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
                                  text:
                                      '$receiverShiftStartTime-$receiverShiftEndTime',
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
                                Expanded(
                                  child: InterRegular(
                                    maxLines: 2,
                                    text: receiverShiftLocationAddress,
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 30.h,
                      ),
                      IgnorePointer(
                        ignoring:
                            _isTransactionLoading || isAlreadyAcknowledged,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Button1(
                              text: widget.isRequest ? 'Exchange' : 'Accept',
                              onPressed: () {
                                if (!widget.isRequest) {
                                  onShiftRequestAccept(
                                    senderId: senderId,
                                    receiverId: receiverId,
                                    shiftId: senderShiftId,
                                    shiftRequestId: widget.exchangeId,
                                  );
                                } else {
                                  onAccept(
                                    exchangeId: widget.exchangeId,
                                    senderId: senderId,
                                    senderShiftId: senderShiftId,
                                    receiverId: receiverId,
                                    receiverShiftId: receiverShiftId,
                                  );
                                }
                              },
                              backgroundcolor:
                                  _isTransactionLoading || isAlreadyAcknowledged
                                      ? Theme.of(context).primaryColorLight
                                      : Theme.of(context).primaryColor,
                              borderRadius: 10.r,
                              fontsize: 18.sp,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                            ),
                            SizedBox(height: 20.h),
                            Button1(
                              text: 'Reject',
                              onPressed: () {
                                if (!widget.isRequest) {
                                  onShiftRequestReject(
                                    exchangeId: widget.exchangeId,
                                  );
                                } else {
                                  onCancel(exchangeId: widget.exchangeId);
                                }
                              },
                              backgroundcolor:
                                  _isTransactionLoading || isAlreadyAcknowledged
                                      ? Theme.of(context).primaryColorLight
                                      : Theme.of(context).primaryColor,
                              borderRadius: 10.r,
                              fontsize: 18.sp,
                              color:
                                  Theme.of(context).textTheme.bodyMedium!.color,
                              useBorder: true,
                            ),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> onShiftRequestReject({
    required String exchangeId,
  }) async {
    setState(() {
      _isTransactionLoading = true;
    });
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Reference to the ShiftExchange document
      DocumentReference shiftExchangeDocRef =
          firestore.collection('ShiftRequests').doc(exchangeId);

      // Update the ShiftExchReqStatus to cancelled
      await shiftExchangeDocRef.update({'ShiftReqStatus': 'cancelled'});

      showSuccessToast(
          context, 'Shift exchange request cancelled successfully');

      setState(() {
        _isTransactionLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTransactionLoading = false;
      });
      print('Error cancelling shift exchange request: $e');
    }
  }

  Future<void> onShiftRequestAccept({
    required String senderId,
    required String receiverId,
    required String shiftId,
    required String shiftRequestId,
  }) async {
    try {
      setState(() {
        _isTransactionLoading = true;
      });
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Reference to the shift document
      DocumentReference shiftRef = _firestore.collection('Shifts').doc(shiftId);

      // Get the shift document
      DocumentSnapshot shiftDoc = await shiftRef.get();

      if (shiftDoc.exists) {
        // Get the current lists
        List<dynamic> shiftAcknowledgedByEmpId =
            shiftDoc['ShiftAcknowledgedByEmpId'] ?? [];
        List<dynamic> shiftAssignedUserId =
            shiftDoc['ShiftAssignedUserId'] ?? [];

        // Ensure these lists are mutable
        List<String> updatedShiftAcknowledgedByEmpId =
            List<String>.from(shiftAcknowledgedByEmpId);
        List<String> updatedShiftAssignedUserId =
            List<String>.from(shiftAssignedUserId);

        // Add senderId to both lists if it's not already present
        if (!updatedShiftAssignedUserId.contains(senderId)) {
          updatedShiftAssignedUserId.add(senderId);
        }

        // Remove receiverId from both lists if present
        updatedShiftAcknowledgedByEmpId.remove(receiverId);
        updatedShiftAssignedUserId.remove(receiverId);

        // Update the shift document with the modified lists
        await shiftRef.update({
          'ShiftAcknowledgedByEmpId': updatedShiftAcknowledgedByEmpId,
          'ShiftAssignedUserId': updatedShiftAssignedUserId,
        });

        // Reference to the ShiftExchange document
        DocumentReference shiftExchangeDocRef =
            _firestore.collection('ShiftRequests').doc(shiftRequestId);

        // Update the ShiftExchReqStatus to cancelled
        await shiftExchangeDocRef.update({'ShiftReqStatus': 'completed'});

        showSuccessToast(context, "Shift request accepted successfully");
        print('Shift document updated successfully.');
      } else {
        print('Shift document does not exist.');
      }
      setState(() {
        _isTransactionLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTransactionLoading = false;
      });
    }
  }

  Future<void> onCancel({
    required String exchangeId,
  }) async {
    setState(() {
      _isTransactionLoading = true;
    });
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Reference to the ShiftExchange document
      DocumentReference shiftExchangeDocRef =
          firestore.collection('ShiftExchange').doc(exchangeId);

      // Update the ShiftExchReqStatus to cancelled
      await shiftExchangeDocRef.update({'ShiftExchReqStatus': 'cancelled'});

      showSuccessToast(
          context, 'Shift exchange request cancelled successfully');

      setState(() {
        _isTransactionLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTransactionLoading = false;
      });
      print('Error cancelling shift exchange request: $e');
    }
  }

  Future<void> onAccept({
    required String exchangeId,
    required String senderId,
    required String senderShiftId,
    required String receiverId,
    required String receiverShiftId,
  }) async {
    setState(() {
      _isTransactionLoading = true;
    });
    print('senderId: $senderId');
    print('senderShiftId: $senderShiftId');
    print('receiverId: $receiverId');
    print('receiverShiftId: $receiverShiftId');
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Update the shift document for receiverShiftId with senderId
      await updateShiftDocument(
          receiverShiftId, senderId, receiverId, firestore);

      // Update the shift document for senderShiftId with receiverId
      await updateShiftDocument(senderShiftId, receiverId, senderId, firestore);

      // Reference to the ShiftExchange document
      DocumentReference shiftExchangeDocRef =
          firestore.collection('ShiftExchange').doc(exchangeId);

      // Update the ShiftExchReqStatus to cancelled
      await shiftExchangeDocRef.update({'ShiftExchReqStatus': 'completed'});

      print('Shift documents updated successfully');
      showSuccessToast(context, "Shift exchange accepted successfully");
      setState(() {
        _isTransactionLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTransactionLoading = false;
      });
      print('Error updating shift documents: $e');
    } // Function to update a shift document
  }

  Future<void> updateShiftDocument(String shiftId, String addId,
      String removeId, FirebaseFirestore firestore) async {
    try {
      final DocumentReference shiftDocRef =
          firestore.collection('Shifts').doc(shiftId);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot shiftDocSnapshot = await transaction.get(shiftDocRef);

        if (shiftDocSnapshot.exists) {
          var shiftData = shiftDocSnapshot.data() as Map<String, dynamic>;

          List<dynamic> acknowledgedByEmpIds =
              List.from(shiftData['ShiftAcknowledgedByEmpId'] ?? []);
          List<dynamic> assignedUserIds =
              List.from(shiftData['ShiftAssignedUserId'] ?? []);

          // Add the new user ID

          if (!assignedUserIds.contains(addId)) {
            assignedUserIds.add(addId);
          }

          // Remove the old user ID
          acknowledgedByEmpIds.remove(removeId);
          assignedUserIds.remove(removeId);

          // Update the document
          transaction.update(shiftDocRef, {
            'ShiftAcknowledgedByEmpId': acknowledgedByEmpIds,
            'ShiftAssignedUserId': assignedUserIds,
          });
        }
      });
    } catch (e) {
      print('Error updating shift document: $e');
    }
  }
}
