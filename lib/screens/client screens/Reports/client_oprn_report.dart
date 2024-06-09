import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/main.dart';

import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ClientOpenReport extends StatefulWidget {
  final String reportName;
  final String reportCategory;
  final String reportDate;
  final String reportFollowUpRequire;
  final String reportData;
  final String reportStatus;
  final String reportEmployeeName;
  final String reportLocation;

  const ClientOpenReport({super.key,
    required this.reportName,
    required this.reportCategory,
    required this.reportDate,
    required this.reportFollowUpRequire,
    required this.reportData,
    required this.reportStatus,
    required this.reportEmployeeName,
    required this.reportLocation,});

  @override
  State<ClientOpenReport> createState() => _ClientOpenReportState();
}

class _ClientOpenReportState extends State<ClientOpenReport> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
        appBar: AppBar(
         
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
             
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterBold(
            text: 'Report',
         
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Name:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color ,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportName,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Category:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportCategory,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Date:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportDate,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Follow Up Required:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportFollowUpRequire,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Data:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportData,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Status:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportStatus,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Employee Name:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportEmployeeName,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Location:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportLocation,
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Followed Up Report:',
                      fontsize: 18.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'NOT FOUND?',
                      fontsize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
