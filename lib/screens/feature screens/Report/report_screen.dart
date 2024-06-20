import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/Report/create_report_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import 'create_report_screen.dart';

class ReportScreen extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String companyId;
  final String empId;
  final String empName;
  final String clientId;
  final String ShiftId;
  final bool isguard;
  const ReportScreen(
      {super.key,
      required this.locationId,
      required this.locationName,
      required this.companyId,
      required this.empId,
      required this.empName,
      required this.clientId,
      required this.ShiftId,
      required this.isguard});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int currentIndex = 0;
  FireStoreService fireStoreService = FireStoreService();
  List<String> tittles = [];
  List<Map<String, dynamic>> groupedReportData = [];
  List<Map<String, dynamic>> reportData = [];
  @override
  void initState() {
    super.initState();
    getAllTitles();
    getAllReports();
    print("Shift Id ${widget.ShiftId}");
  }

  void getAllTitles() async {
    List<String> data = await fireStoreService.getReportTitles();
    if (data.isNotEmpty) {
      setState(() {
        tittles = ["All", ...data];
      });
    }
    print("Report Titles : $data");
    print("Getting all titles");
  }

  void getAllReports() async {
    try {
      if (widget.companyId.isNotEmpty || widget.locationId.isNotEmpty) {
        reportData = await fireStoreService.getReportWithCompanyID(
            widget.companyId, widget.locationId);
        groupedReportData.clear(); // Clear existing data before adding new data
        reportData.forEach((report) {
          if (report['ReportCreatedAt'] != null) {
            String reportDate =
                DateFormat.yMMMMd().format(report['ReportCreatedAt'].toDate());
            bool found = false;
            for (int i = 0; i < groupedReportData.length; i++) {
              if (groupedReportData[i]['date'] == reportDate) {
                // Check if the report already exists in this group
                if (!groupedReportData[i]['reports'].any((existingReport) =>
                    existingReport['ReportId'] == report['ReportId'])) {
                  // Add the report if it doesn't already exist
                  groupedReportData[i]['reports'].add(report);
                }
                found = true;
                break;
              }
            }
            if (!found) {
              groupedReportData.add({
                'date': reportDate,
                'reports': [report]
              });
            }
          }
        });

        // Sort groupedReportData by date in descending order
        groupedReportData.sort((a, b) => DateFormat.yMMMMd()
            .parse(b['date'])
            .compareTo(DateFormat.yMMMMd().parse(a['date'])));

        setState(() {
          if (currentIndex > 0 && currentIndex < tittles.length) {
            String selectedTitle = tittles[currentIndex];
            groupedReportData.forEach((group) {
              group['reports'] = group['reports']
                  .where(
                      (report) => report['ReportCategoryName'] == selectedTitle)
                  .toList();
            });
          }
        });

        print("Report Data $groupedReportData");
      }
    } catch (e) {}
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
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Report',
          ),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateReportScreen(
                          locationId: widget.locationId,
                          companyID: widget.companyId,
                          locationName: widget.locationName,
                          empId: widget.empId,
                          empName: widget.empName,
                          ClientId: widget.clientId,
                          reportId: "",
                          buttonEnable: true,
                          ShiftId: widget.ShiftId,
                          SearchId: '',
                          isRoleGuard: widget.isguard,
                        ))).then((value) {
              if (value == true) {
                getAllReports();
                getAllTitles();
              }
            });
          },
          // backgroundColor: Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            size: 24.sp,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              SizedBox(
                height: 55.h,
                child: ListView.builder(
                  itemCount: tittles.length,
                  // shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                          getAllReports();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AnimatedContainer(
                          margin: EdgeInsets.only(right: 10.w),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          constraints: BoxConstraints(
                            minWidth: 70.w,
                          ),
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              borderRadius: BorderRadius.circular(20.r),
                              color: currentIndex == index
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor),
                          duration: const Duration(microseconds: 500),
                          child: Center(
                            child: InterRegular(
                              text: tittles[index],
                              fontsize: 16.sp,
                              color: currentIndex == index
                                  ? Theme.of(context).cardColor
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groupedReportData.length,
                  itemBuilder: (context, groupIndex) {
                    final group = groupedReportData[groupIndex];
                    final groupDate = group['date'];
                    final groupReports = group['reports'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (groupReports.isNotEmpty)
                          InterBold(
                            text: groupDate,
                            color: Theme.of(context).primaryColor,
                            fontsize: 20.sp,
                          ),
                        SizedBox(height: 30.h),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: groupReports.length,
                          itemBuilder: (context, index) {
                            final report = groupReports[index];
                            final reportDate =
                                report['ReportCreatedAt'].toDate();
                            final formattedTime =
                                DateFormat.jm().format(reportDate);

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateReportScreen(
                                        locationId: widget.locationId,
                                        locationName: widget.locationName,
                                        companyID: widget.companyId,
                                        // companyId: widget.companyId,
                                        empId: widget.empId,
                                        empName: widget.empName,
                                        // clientId: widget.clientId,
                                        ClientId: widget.clientId,
                                        reportId: report['ReportId'],
                                        buttonEnable: false,
                                        ShiftId: widget.ShiftId, SearchId: '',
                                        isRoleGuard: widget.isguard,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 10.h,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                      ),
                                      height: 100.h,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Theme.of(context).shadowColor,
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                        color: Theme.of(context).cardColor,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              right: 20.w,
                                            ),
                                            child: SvgPicture.asset(
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? 'assets/images/report_icon.svg'
                                                  : 'assets/images/report_icon_light.svg',
                                              height: 24.h,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  report['ReportName'],
                                                  style: TextStyle(
                                                    fontSize: 20.sp,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .color,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        InterMedium(
                                                          text: 'CATEGORY: ',
                                                          fontsize: 14.sp,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .displaySmall!
                                                                  .color,
                                                        ),
                                                        InterRegular(
                                                          text: report[
                                                              'ReportCategoryName'],
                                                          fontsize: 14.sp,
                                                          color: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayMedium!
                                                              .color,
                                                        ),
                                                      ],
                                                    ),
                                                    InterRegular(
                                                      text: formattedTime,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium!
                                                          .color,
                                                      fontsize: 14.sp,
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
