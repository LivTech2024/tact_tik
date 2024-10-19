import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../widgets/custome_textfield.dart';

class CreateLeaveRequest extends StatefulWidget {
  final String LeaveReqCompanyId;
  final String LeaveReqCompanyBranchId;
  final String LeaveReqEmpId;
  final String LeaveReqEmpName;
  const CreateLeaveRequest({
    Key? key,
    required this.LeaveReqCompanyId,
    required this.LeaveReqCompanyBranchId,
    required this.LeaveReqEmpId,
    required this.LeaveReqEmpName,
  }) : super(key: key);

  @override
  State<CreateLeaveRequest> createState() => _CreateLeaveRequestState();
}

class _CreateLeaveRequestState extends State<CreateLeaveRequest> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _requestFrom;
  DateTime? _requestTo;
  bool _isLoading = false;

  /// Function to handle leave request creation
  Future<void> createLeaveRequest() async {
    if (_requestFrom == null || _requestTo == null) {
      showErrorToast(context, 'Select both dates');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final leaveRequestId =
        FirebaseFirestore.instance.collection('LeaveRequests').doc().id;
    final leaveData = {
      'LeaveReqId': leaveRequestId,
      'LeaveReqCompanyId': widget.LeaveReqCompanyId,
      'LeaveReqCompanyBranchId': widget.LeaveReqCompanyBranchId,
      'LeaveReqSupervisorId': '',
      'LeaveReqEmpId': widget.LeaveReqEmpId,
      'LeaveReqEmpName': widget.LeaveReqEmpName,
      'LeaveReqFromDate': _requestFrom,
      'LeaveReqToDate': _requestTo,
      'LeaveReqReason': _reasonController.text,
      'LeaveReqStatus': 'pending',
      'LeaveReqCreatedAt': FieldValue.serverTimestamp(),
      'LeaveReqModifiedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('LeaveRequests')
          .doc(leaveRequestId)
          .set(leaveData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting request: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Function to open the date picker and assign selected date
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _requestFrom = picked;
        } else {
          _requestTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const InterMedium(text: 'Leave Request'),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  children: [
                    SizedBox(height: 30.h),
                    // Request From Date Picker
                    GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: _buildDateField(
                        label: 'Request From',
                        date: _requestFrom,
                        iconColor: Colors.green,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Request To Date Picker
                    GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: _buildDateField(
                        label: 'Request To',
                        date: _requestTo,
                        iconColor: Colors.red,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    // Reason Text Field
                    CustomeTextField(
                      hint: 'Write Reason Here ...',
                      controller: _reasonController,
                      isExpanded: true,
                    ),
                    SizedBox(height: 30.h),
                    // Submit Button
                    Button1(
                      text: 'Request',
                      color: Colors.white,
                      backgroundcolor: const Color(0xFFBE9D5F),
                      borderRadius: 10.r,
                      onPressed: createLeaveRequest,
                    ),
                  ],
                ),
              ),
            ),
            // Loading Indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build the date picker fields
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
          // color: Colors.grey[900],
          // borderRadius: BorderRadius.circular(10.r),

          ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: iconColor),
          SizedBox(width: 10.w),
          Text(
            date != null ? '${date.day}/${date.month}/${date.year}' : label,
            style: TextStyle(
                color: ThemeMode.dark == themeManager.themeMode
                    ? DarkColor.color18
                    : LightColor.color3,
                fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}
