import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/screens/client%20screens/Reports/select_location_report.dart';

import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_semibold.dart';
import '../../home screens/widgets/icon_text_widget.dart';
import '../select_client_guards_screen.dart';
import 'client_oprn_report.dart';

class ClientReportScreen extends StatefulWidget {
  final String employeeId;
  final String companyId;

  const ClientReportScreen(
      {super.key, required this.employeeId, required this.companyId});

  @override
  State<ClientReportScreen> createState() => _ClientReportScreenState();
}

class _ClientReportScreenState extends State<ClientReportScreen> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;
  String selectedGuardId = '';
  List<String> selectedLocationId = [];

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  void onGuardSelected(String guardId) {
    setState(() {
      selectedGuardId = guardId;
    });
    print('Selected Guard ID: $selectedGuardId');
    fetchReports();
  }

  void onLocationSelected(List<dynamic> locationId) {
    setState(() {
      selectedLocationId = List<String>.from(locationId);
    });
    print('Selected Location Id: $selectedLocationId');
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Reports')
          .where('ReportClientId', isEqualTo: widget.employeeId)
          .orderBy('ReportCreatedAt', descending: true)
          .get();

      Map<String, List<DocumentSnapshot>> dataByDate = {};
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var date = (data['ReportCreatedAt'] as Timestamp).toDate();
        var formattedDate = DateFormat('dd/MM/yyyy').format(date);

        if (selectedLocationId != null && selectedLocationId.isNotEmpty) {
          var reportLocationId = data['ReportLocationId'] as String?;
          if (reportLocationId == null ||
              !selectedLocationId.contains(reportLocationId)) {
            continue;
          }
        }

        if (selectedGuardId != null && selectedGuardId.isNotEmpty) {
          var reportEmployeeId = data['ReportEmployeeId'] as String?;
          if (reportEmployeeId == null || reportEmployeeId != selectedGuardId) {
            continue;
          }
        }

        if (dataByDate.containsKey(formattedDate)) {
          dataByDate[formattedDate]!.add(doc);
        } else {
          dataByDate[formattedDate] = [doc];
        }
      }

      List<Map<String, dynamic>> fetchedReports = [];
      for (var entry in dataByDate.entries) {
        for (var doc in entry.value) {
          var data = doc.data() as Map<String, dynamic>;
          fetchedReports.add({
            'ReportDate': (data['ReportCreatedAt'] != null)
                ? data['ReportCreatedAt'].toDate()
                : DateTime.now(), // default to now if missing or null
            'ReportName': (data['ReportName'] != null &&
                    data['ReportName'].toString().isNotEmpty)
                ? data['ReportName']
                : 'Not Found',
            'ReportGuardName': (data['ReportEmployeeName'] != null &&
                    data['ReportEmployeeName'].toString().isNotEmpty)
                ? data['ReportEmployeeName']
                : 'Not Found',
            'ReportEmployeeName': (data['ReportEmployeeName'] != null &&
                    data['ReportEmployeeName'].toString().isNotEmpty)
                ? data['ReportEmployeeName']
                : 'Not Found',
            'ReportStatus': (data['ReportStatus'] != null &&
                    data['ReportStatus'].toString().isNotEmpty)
                ? data['ReportStatus']
                : 'Not Found',
            'ReportCategory': (data['ReportCategoryName'] != null &&
                    data['ReportCategoryName'].toString().isNotEmpty)
                ? data['ReportCategoryName']
                : 'Not Found',
            'ReportFollowUpRequire': data['ReportIsFollowUpRequired'] ?? false,
            'ReportData': (data['ReportData'] != null &&
                    data['ReportData'].toString().isNotEmpty)
                ? data['ReportData']
                : 'Not Found',
            'ReportLocation': (data['ReportLocationName'] != null &&
                    data['ReportLocationName'].toString().isNotEmpty)
                ? data['ReportLocationName']
                : 'Not Found',
            'ReportFollowedUp': (data['ReportFollowedUpId'] != null &&
                    data['ReportFollowedUpId'].toString().isNotEmpty)
                ? data['ReportFollowedUpId']
                : 'Not Found',
            'ReportImages': (data['ReportImage'] != null &&
                    data['ReportImage'] is List &&
                    data['ReportImage'].isNotEmpty)
                ? List<dynamic>.from(data['ReportImage'])
                : [],
          });
        }
      }

      setState(() {
        reports = fetchedReports;
        isLoading = false;
      });
      print("REPORT DATA HERE IT'S  :$reports");
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101)
    );
    setState(() {
      if (picked != null) {
        selectedDate = picked;
        // fetchDARData();  // Fetch data for the selected date
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                padding: EdgeInsets.only(left: 20.w),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterMedium(
                text: 'Reports',
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          // onTap: () => _selectDate(context),
                          child: SizedBox(
                            width: 140.w,
                            child: IconTextWidget(
                              icon: Icons.calendar_today,
                              text: selectedDate != null
                                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                                  : 'Select Date',
                              fontsize: 14.sp,
                              color: Theme.of(context).textTheme.bodyMedium!.color
                              as Color,
                              Iconcolor: Theme.of(context).textTheme.bodyMedium!.color as Color,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // SelectLocationDar.showLocationDialog(
                                //   context,
                                //   widget.companyId,
                                //   onLocationSelected,
                                // );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80.w,
                                    child: IconTextWidget(
                                      space: 6.w,
                                      icon: Icons.add,
                                      iconSize: 20.sp,
                                      text: 'Select',
                                      useBold: true,
                                      fontsize: 14.sp,
                                      color: Theme.of(context).textTheme.bodySmall!.color as Color,
                                      Iconcolor:
                                      Theme.of(context).textTheme.bodyMedium!.color as Color,
                                    ),
                                  ),
                                  InterBold(
                                    text: 'Location',
                                    fontsize: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: Platform.isIOS ? 30.w : 10.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => SelectClientGuardsScreen(
                                //       companyId: widget.companyId,
                                //       onGuardSelected: onGuardSelected,
                                //     ),
                                //   ),
                                // );
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 80.w,
                                    child: IconTextWidget(
                                      space: 6.w,
                                      icon: Icons.add,
                                      iconSize: 20.sp,
                                      text: 'Select',
                                      useBold: true,
                                      fontsize: 14.sp,
                                      color: Theme.of(context).textTheme.bodySmall!.color as Color,
                                      Iconcolor:
                                      Theme.of(context).textTheme.bodyMedium!.color as Color,
                                    ),
                                  ),
                                  InterBold(
                                    text: 'Employee',
                                    fontsize: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    )
                  ],
                ),
              )
            ),
            reports.isEmpty
                ? SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: InterMedium(
                  text: 'NO DATA FOUND',
                  fontsize: 16.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color!,
                ),
              ),
            )
            : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  DateTime reportDate = reports[index]['ReportDate'];
                  String dateString = (isSameDate(reportDate, DateTime.now()))
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
                            builder: (context) => ClientOpenReport(
                              reportName: reports[index]['ReportName'],
                              reportCategory: reports[index]['ReportCategory'],
                              reportDate: dateString,
                              reportFollowUpRequire: reports[index]
                              ['ReportFollowUpRequire']
                                  .toString(),
                              reportData: reports[index]['ReportData'],
                              reportStatus: reports[index]['ReportStatus'],
                              reportEmployeeName: reports[index]
                              ['ReportEmployeeName'],
                              reportLocation: reports[index]['ReportLocation'],
                              reportImages: reports[index]['ReportImages'] ?? [],
                              reportFollowUpId: reports[index]['ReportFollowedUp'],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30.h),
                          InterBold(
                            text: dateString,
                            color: Theme.of(context).textTheme.bodySmall!.color,
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
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 18.h,
                                  horizontal: 18.w,
                                ),
                                margin: EdgeInsets.only(
                                  top: 10.h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: reports[index]
                                      ['ReportEmployeeName'],
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
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterMedium(
                                              text: 'Report Name:',
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!,
                                            ),
                                            SizedBox(width: 20.w),
                                            Flexible(
                                              child: InterMedium(
                                                text: reports[index]
                                                    ['ReportName'],
                                                fontsize: 16.sp,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .color!,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterMedium(
                                              text: 'Category:',
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!,
                                            ),
                                            SizedBox(width: 20.w),
                                            Flexible(
                                              child: InterMedium(
                                                text: reports[index]
                                                    ['ReportCategory'],
                                                fontsize: 16.sp,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .color!,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterMedium(
                                              text: 'Emp Name:',
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!,
                                            ),
                                            SizedBox(width: 20.w),
                                            InterMedium(
                                              text: reports[index]
                                                  ['ReportEmployeeName'],
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .color!,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InterMedium(
                                              text: 'Status:',
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .color!,
                                            ),
                                            SizedBox(width: 20.w),
                                            InterMedium(
                                              text: reports[index]
                                                  ['ReportStatus'],
                                              fontsize: 16.sp,
                                              color: Theme.of(context)
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
        ),
      ),
    );
  }
}
