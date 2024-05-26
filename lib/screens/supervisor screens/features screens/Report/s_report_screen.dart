import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/Report/s_create_report_screen.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SReportScreen extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String companyId;
  final String empId;
  final String empName;
  final String clientId;

  const SReportScreen(
      {super.key,
      required this.locationId,
      required this.locationName,
      required this.companyId,
      required this.empId,
      required this.empName,
      required this.clientId});

  @override
  State<SReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<SReportScreen> {
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
    reportData = await fireStoreService.getReportWithCompanyID(
        widget.companyId, widget.locationId);
    groupedReportData.clear(); // Clear existing data before adding new data
    reportData.forEach((report) {
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
              .where((report) => report['ReportCategoryName'] == selectedTitle)
              .toList();
        });
      }
    });

    print("Report Data $groupedReportData");
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: width / width24,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Report',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        backgroundColor: Secondarycolor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SCreateReportScreen(
                          locationId: widget.locationId,
                          companyID: widget.companyId,
                          locationName: widget.locationName,
                          empId: widget.empId,
                          empName: widget.empName,
                          ClientId: widget.clientId,
                          reportId: "",
                        ))).then((value) {
              if (value == true) {
                getAllReports();
                getAllTitles();
              }
            });
          },
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Column(
            children: [
              SizedBox(height: height / height30),
              SizedBox(
                height: height / height40,
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
                      child: AnimatedContainer(
                        margin: EdgeInsets.only(right: width / width10),
                        padding:
                            EdgeInsets.symmetric(horizontal: width / width20),
                        constraints: BoxConstraints(
                          minWidth: width / width70,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width / width20),
                          color: currentIndex == index
                              ? Primarycolor
                              : WidgetColor,
                        ),
                        duration: const Duration(microseconds: 500),
                        child: Center(
                          child: InterRegular(
                            text: tittles[index],
                            fontsize: width / width16,
                            color: color18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: height / height20),
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
                            color: Primarycolor,
                            fontsize: width / width20,
                          ),
                        SizedBox(height: height / height30),
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

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SCreateReportScreen(
                                      locationId: widget.locationId,
                                      locationName: widget.locationName,
                                      companyID: widget.companyId,
                                      // companyId: widget.companyId,
                                      empId: widget.empId,
                                      empName: widget.empName,
                                      // clientId: widget.clientId,
                                      ClientId: widget.clientId,
                                      reportId: report['ReportId'],
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      bottom: height / height10,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width / width20,
                                    ),
                                    height: height / height100,
                                    decoration: BoxDecoration(
                                      color: WidgetColor,
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            right: width / width20,
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/images/report_icon.svg',
                                            height: height / height24,
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
                                                  fontSize: width / width20,
                                                  color: color2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: height / height10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      InterMedium(
                                                        text: 'CATEGORY: ',
                                                        fontsize:
                                                            width / width14,
                                                        color: color32,
                                                      ),
                                                      InterRegular(
                                                        text: report[
                                                            'ReportCategoryName'],
                                                        fontsize:
                                                            width / width14,
                                                        color: color26,
                                                      ),
                                                    ],
                                                  ),
                                                  InterRegular(
                                                    text: formattedTime,
                                                    color: color26,
                                                    fontsize: width / width14,
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
                                    height: height / height20,
                                  )
                                ],
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
