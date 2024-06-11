import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/utils/colors.dart';

class ClientOpenDarScreen extends StatefulWidget {
  final String tileLocation;
  final String tileTime;
  final String tileDescription;
  final String tileReportSearchId;
  final String empName;

  const ClientOpenDarScreen({
    super.key,
    required this.tileLocation,
    required this.tileTime,
    required this.tileDescription,
    required this.tileReportSearchId,
    required this.empName,
  });

  @override
  State<ClientOpenDarScreen> createState() => _ClientOpenDarScreenState();
}

class _ClientOpenDarScreenState extends State<ClientOpenDarScreen> {
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
          title: InterRegular(
            text: "Dar Data: " + widget.empName,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                InterBold(
                  text: widget.tileLocation == ''
                      ? 'Not Defined'
                      : widget.tileLocation,
                  fontsize: 18.sp,
                ),
                SizedBox(height: 20.h),
                InterSemibold(
                  text: 'Time: ' + widget.tileTime,
                  fontsize: 14.sp,
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Description',
                  fontsize: 18.sp,
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  constraints: BoxConstraints(),
                  decoration: BoxDecoration(
                    color: DarkColor.WidgetColor,
                    borderRadius: BorderRadius.circular(13.85.r),
                  ),
                  child: InterRegular(
                    text: widget.tileDescription,
                    fontsize: 14.sp,
                    maxLines: 80,
                  ),
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Patrol',
                  fontsize: 20.sp,
                ),
                SizedBox(height: 10.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // print("TIle Patrol Data ${TilePatrolData}");
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30.h),
                        height: 70.h,
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            Container(
                              width: 15.w,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InterBold(
                                        text: 'Patrol Name',
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                      InterBold(
                                        text: '',
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InterBold(
                                        text: 'Started',
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                      InterBold(
                                        text: '',
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InterBold(
                                        text: 'Ended',
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                      InterBold(
                                        text: '',
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                InterBold(
                  text: 'Reports',
                  fontsize: 20.sp,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
                widget.tileReportSearchId == 'Not Defined'
                    ? Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: InterRegular(
                          text: 'No Reports Found',
                          fontsize: 16.sp,
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Reports')
                            .where('ReportSearchId',
                                isEqualTo: widget.tileReportSearchId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }

                          final reports = snapshot.data!.docs;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final report =
                                  reports[index].data() as Map<String, dynamic>;
                              final reportData = report['ReportData'];
                              final reportCreatedAt =
                                  (report['ReportCreatedAt'] as Timestamp)
                                      .toDate();
                              final formattedTime =
                                  DateFormat('hh:mm a').format(reportCreatedAt);

                              return GestureDetector(
                                onTap: () {
                                  // Handle report tap
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30.h),
                                  height: 35.h,
                                  color: Theme.of(context).cardColor,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 15.w,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            InterBold(
                                              text: reportData,
                                              fontsize: 12.sp,
                                              color: Colors.white,
                                            ),
                                            InterBold(
                                              text: formattedTime,
                                              fontsize: 12.sp,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
