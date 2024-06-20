import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
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
  final List<dynamic> reportImages;
  final String reportFollowUpId;

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
    required this.reportImages,
    required this.reportFollowUpId,
  });

  @override
  State<ClientOpenReport> createState() => _ClientOpenReportState();
}

class _ClientOpenReportState extends State<ClientOpenReport> {
  bool isLoading = true;
  List<Map<String, dynamic>> followUp = [];
bool loading = false;
  @override
  void initState() {
    super.initState();
    if (widget.reportFollowUpId != "Not Found") {
      fetchFollowUp();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFollowUp() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Reports')
          .where('ReportId', isEqualTo: widget.reportFollowUpId)
          .get();

      List<Map<String, dynamic>> fetchedFollowUp =
          querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
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
              ? List<String>.from(data['ReportImage'])
              : [],
        };
      }).toList();

      setState(() {
        followUp = fetchedFollowUp;
        isLoading = false;
      });
      print("FOLLOW UP DATA HERE IT'S  :$followUp");
    } catch (e) {
      print("Error fetching follow up: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> generateReportPdf(
    String reportName,
    String reportCategory,
    String reportFollowUp,
    String reportData,
    String reportStatus,
    String GuardName,
    String reportDate,
    String reportLocation,
    List<dynamic> reportImages,
  ) async {
    final htmlcontent = """
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Report</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              margin: 0;
              padding: 0;
              box-sizing: border-box;
              background-color: #f4f4f4;
          }
          .report-container {
              max-width: 800px;
              margin: 20px auto;
              background: white;
              padding: 20px;
              box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
          }
          .report-header, .report-section {
              width: 100%;
              border-collapse: collapse;
          }
          .report-header td {
              border: 1px solid #ddd;
              padding: 8px;
              text-align: left;
          }
          .report-header td.title {
              text-align: center;
              font-weight: bold;
              background-color: #f4b400;
              color: white;
          }
          .report-section th, .report-section td {
              border: 1px solid #ddd;
              padding: 8px;
          }
          .report-section th {
              background-color: #f4b400;
              color: white;
          }
          .report-section td {
              vertical-align: top;
          }
          .report-section td img {
              width: 100px;
              height: auto;
          }
          .report-title {
              text-align: center;
              margin-bottom: 20px;
          }
          .report-title img {
              width: 100px;
          }
      </style>
  </head>
  <body>
      <div class="report-container">
          <div class="report-title">
              <img src="logo.png" alt="TPS Logo">
              <h1>Report</h1>
          </div>
          <table class="report-header">
              <tr>
                  <td class="title">Employee Name: ${GuardName}</td>
                  <td>Date: ${reportDate}</td>
              </tr>
          </table>
          <table class="report-section">
             <tr>
                  <td>Report Name: ${reportName}</td>
              </tr>
              <tr>
                  <td>Report Category: ${reportCategory}</td>
              </tr>
              <tr>
                  <td>Report Follow Up Required: ${reportFollowUp}</td>
              </tr>
              <tr>
                  <td>Report Data: ${reportData}</td>
              </tr>
              <tr>
                  <td>Report Status: ${reportStatus}</td>
              </tr>
              <tr>
                  <td>Report Location: ${reportLocation}</td>
              </tr>
              <tr>
                <td>
                 Report Images:
                 ${reportImages.map((imageUrl) => '<img src="$imageUrl" alt="Report Image" width="100" height="100">').join('')}
                </td>
              </tr>
          </table>
      </div>
  </body>
  </html>
  """;

    // Generate the PDF
    final pdfResponse = await http.post(
      Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'html': htmlcontent,
        'file_name': 'security_report.pdf',
      }),
    );

    if (pdfResponse.statusCode == 200) {
      print('PDF generated successfully');
      final pdfBase64 = base64Encode(pdfResponse.bodyBytes);
      savePdfLocally(pdfBase64, 'security_report.pdf');
      return pdfBase64;
    } else {
      print('Failed to generate PDF. Status code: ${pdfResponse.statusCode}');
      throw Exception('Failed to generate PDF');
    }
  }

  Future<File> savePdfLocally(String pdfBase64, String fileName) async {
    final pdfBytes = base64Decode(pdfBase64);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file;
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
          title: InterBold(
            text: 'Report',
            letterSpacing: -.3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                generateReportPdf(
                    widget.reportName,
                    widget.reportCategory,
                    widget.reportFollowUpRequire,
                    widget.reportData,
                    widget.reportStatus,
                    widget.reportEmployeeName,
                    widget.reportDate,
                    widget.reportLocation,
                    widget.reportImages);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.download_for_offline_sharp,
                    size: 24.sp,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  InterMedium(
                    text: 'PDF',
                    color: Theme.of(context).textTheme.bodyMedium!.color,
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
        body: Stack(
          children: [
            Padding(
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
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(width: 20.h),
                        Flexible(
                          child: InterMedium(
                            text: widget.reportName,
                            fontsize: 14.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Report Data:',
                          fontsize: 18.sp,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(width: 20.h),
                        Flexible(
                          child: InterMedium(
                            text: widget.reportData,
                            fontsize: 14.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                        widget.reportFollowUpId == "Not Found"
                            ? InterMedium(
                                text: 'NOT FOUND',
                                fontsize: 14.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  if (followUp.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClientOpenReport(
                                          reportName: followUp[0]['ReportName'],
                                          reportCategory: followUp[0]
                                              ['ReportCategory'],
                                          reportDate: followUp[0]['ReportDate']
                                              .toString(),
                                          reportFollowUpRequire: followUp[0]
                                                  ['ReportFollowUpRequire']
                                              .toString(),
                                          reportData: followUp[0]['ReportData'],
                                          reportStatus: followUp[0]
                                              ['ReportStatus'],
                                          reportEmployeeName: followUp[0]
                                              ['ReportEmployeeName'],
                                          reportLocation: followUp[0]
                                              ['ReportLocation'],
                                          reportImages:
                                              followUp[0]['ReportImages'] ?? [],
                                          reportFollowUpId: followUp[0]
                                              ['ReportFollowedUp'],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text('See Report'),
                              ),
                      ],
                    ),
                    SizedBox(height: 50.h),
                    widget.reportImages == null || widget.reportImages.isEmpty
                        ? Center(
                            child: Text(
                              "No Images Associated",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8.0,
                              crossAxisSpacing: 8.0,
                            ),
                            itemCount: widget.reportImages.length,
                            itemBuilder: (context, index) {
                              String imageUrl = widget.reportImages[index];
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(imageUrl),
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
            Center(
                child: SizedBox(
              child: Visibility(
                visible: loading,
                child: CircularProgressIndicator(),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
