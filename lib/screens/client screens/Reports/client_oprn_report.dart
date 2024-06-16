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

  const ClientOpenReport({
    super.key,
    required this.reportName,
    required this.reportCategory,
    required this.reportDate,
    required this.reportFollowUpRequire,
    required this.reportData,
    required this.reportStatus,
    required this.reportEmployeeName,
    required this.reportLocation,
  });

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
          actions: [
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.download_for_offline_sharp,
                    size: 24.sp,
                    color: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium!
                        .color,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  InterMedium(
                    text: 'PDF',
                    color: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium!
                        .color,
                    fontsize: 14.sp,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                ],
              ),
            )
          ],
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportName,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportCategory,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportDate,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportFollowUpRequire,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Data:',
                      fontsize: 18.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    Flexible(
                      child: InterMedium(
                        text: widget.reportData,
                        fontsize: 14.sp,
                        color: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium!
                            .color,
                        maxLines: 50,
                      ),
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportStatus,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportEmployeeName,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: widget.reportLocation,
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
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
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'NOT FOUND?', //backend
                      fontsize: 14.sp,
                      color: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              'data:image/jpeg;base64,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'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
