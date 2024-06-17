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
  final String empName;
  final List<dynamic> tileReport;
  final List<dynamic> tilePatrol;
  final List<dynamic> tileImages;

  const ClientOpenDarScreen({
    super.key,
    required this.tileLocation,
    required this.tileTime,
    required this.tileDescription,
    required this.empName,
    required this.tilePatrol,
    required this.tileReport,
    required this.tileImages,
  });

  @override
  State<ClientOpenDarScreen> createState() => _ClientOpenDarScreenState();
}

class _ClientOpenDarScreenState extends State<ClientOpenDarScreen> {
  List<dynamic> combinedImages = [];

  @override
  void initState() {
    super.initState();
    getCombinedImages();
  }

  Future<String> getReportCreatedAtTime(String reportId) async {
    final reportSnapshot = await FirebaseFirestore.instance
        .collection('Reports')
        .where('ReportId', isEqualTo: reportId)
        .get();

    if (reportSnapshot.docs.isNotEmpty) {
      final reportData =
      reportSnapshot.docs.first.data() as Map<String, dynamic>;
      final reportCreatedAt =
      (reportData['ReportCreatedAt'] as Timestamp).toDate();
      final formattedTime = DateFormat('hh:mm a').format(reportCreatedAt);
      return formattedTime;
    } else {
      return 'N/A';
    }
  }

  List<dynamic> getCombinedImages() {
    for (var patrol in widget.tilePatrol) {
      combinedImages.addAll(patrol['TilePatrolImage']);
    }
    combinedImages.addAll(widget.tileImages);

    return combinedImages;
  }


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
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Theme.of(context).cardColor,
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
                itemCount: widget.tilePatrol.length,
                itemBuilder: (context, index) {
                  final patrol = widget.tilePatrol[index];
                  final patrolName = patrol['TilePatrolName'] ?? 'No Data Found';
                  final patrolData = patrol['TilePatrolData'] ?? 'No Data Found, No Data Found';
                  final patrolDetails = patrolData.split(',');

                  return GestureDetector(
                    onTap: () {},
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InterBold(
                                      text: 'Patrol Name: $patrolName',
                                      fontsize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InterBold(
                                      text: '${patrolDetails[0].trim()}',
                                      fontsize: 12.sp,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InterBold(
                                      text: '${patrolDetails[1].trim()}',
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
                widget.tileReport.isEmpty
                    ? Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: InterRegular(
                    text: 'No Reports Found',
                    fontsize: 16.sp,
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.tileReport.length,
                  itemBuilder: (context, index) {
                    final report = widget.tileReport[index];
                    final reportName = report['TileReportName'] ?? 'No Data Found';

                    return FutureBuilder<String>(
                      future: getReportCreatedAtTime(report['TileReportId']),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        final reportCreatedAt = snapshot.data!;

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
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Column(
                                    children: [
                                      InterBold(
                                        text: reportName,
                                        fontsize: 12.sp,
                                        color: Colors.white,
                                      ),
                                      InterBold(
                                        text: reportCreatedAt,
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
                SizedBox(height: 20.h),
                InterBold(
                  text: 'Images',
                  fontsize: 20.sp,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: combinedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(combinedImages[index]),
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
