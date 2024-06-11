import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_semibold.dart';
import 'client_oprn_report.dart';

class ClientReportScreen extends StatelessWidget {
  const ClientReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              DateTime reportDate =
              reports[index]['ReportDate'];
              String dateString = (isSameDate(
                  reportDate, DateTime.now()))
                  ? 'Today'
                  : "${reportDate.day} / ${reportDate.month} / ${reportDate.year}";
              print("Report Data : ${reports[index]}");
              return Padding(
                padding: EdgeInsets.only(
                  left: 30.w,
                  right: 30.w,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClientOpenReport(
                              reportName: reports[index]
                              ['ReportEmployeeName'],
                              reportCategory: reports[index]
                              ['ReportCategory'],
                              reportDate: dateString,
                              reportFollowUpRequire: reports[
                              index][
                              'ReportFollowUpRequire']
                                  .toString(),
                              reportData: reports[index]
                              ['ReportData'],
                              reportStatus: reports[index]
                              ['ReportStatus'],
                              reportEmployeeName:
                              reports[index]
                              ['ReportEmployeeName'],
                              reportLocation: reports[index]
                              ['ReportLocation'],
                            ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      InterBold(
                        text: dateString,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .color,
                        fontsize: 14.sp,
                      ),
                      SizedBox(
                        height: 10.sp,
                      ),
                      Column(
                        children: List.generate(
                          1,
                              (innerIndex) => Container(
                            constraints: BoxConstraints(
                              minHeight: 200.h,
                            ),
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              color: Theme.of(context)
                                  .cardColor,
                              borderRadius:
                              BorderRadius.circular(
                                  14.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 18.h,
                              horizontal: 18.w,
                            ),
                            margin: EdgeInsets.only(
                              top: 10.h,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: [
                                InterSemibold(
                                  text: reports[index][
                                  'ReportEmployeeName'],
                                  fontsize: 18.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                ),
                                SizedBox(height: 19.h),
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        InterMedium(
                                          text:
                                          'Report Name:',
                                          fontsize: 16.sp,
                                          color: Theme.of(
                                              context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!,
                                        ),
                                        SizedBox(width: 20.w),
                                        Flexible(
                                          child:
                                          InterMedium(
                                            text: reports[
                                            index]
                                            [
                                            'ReportName'],
                                            fontsize:
                                            16.sp,
                                            color: Theme.of(
                                                context)
                                                .textTheme
                                                .headlineSmall!
                                                .color!,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: 10.h),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        InterMedium(
                                          text:
                                          'Category:',
                                          fontsize: 16.sp,
                                          color: Theme.of(
                                              context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!,
                                        ),
                                        SizedBox(width: 20.w),
                                        Flexible(
                                          child: InterMedium(
                                            text: reports[
                                            index][
                                            'ReportCategory'],
                                            fontsize: 16.sp,
                                            color: Theme.of(
                                                context)
                                                .textTheme
                                                .headlineSmall!
                                                .color!,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: 10.h),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        InterMedium(
                                          text:
                                          'Emp Name:',
                                          fontsize: 16.sp,
                                          color: Theme.of(
                                              context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!,
                                        ),
                                        SizedBox(width: 20.w),
                                        InterMedium(
                                          text: reports[
                                          index][
                                          'ReportEmployeeName'],
                                          fontsize: 16.sp,
                                          color: Theme.of(
                                              context)
                                              .textTheme
                                              .headlineSmall!
                                              .color!,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                        height: 10.h),
                                    Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        InterMedium(
                                          text: 'Status:',
                                          fontsize: 16.sp,
                                          color: Theme.of(
                                              context)
                                              .textTheme
                                              .bodyMedium!
                                              .color!,
                                        ),
                                        SizedBox(width: 20.w),
                                        InterMedium(
                                          text: reports[
                                          index][
                                          'ReportStatus'],
                                          fontsize: 16.sp,
                                          color: Theme.of(
                                              context)
                                              .textTheme
                                              .headlineSmall!
                                              .color!,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: reports.length,
          ),
        )
      ],
    );
  }
}
