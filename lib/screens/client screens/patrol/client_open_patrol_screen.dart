import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/client%20screens/patrol/view_checkpoint_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import '../select_client_guards_screen.dart';

class ClientOpenPatrolScreen extends StatefulWidget {
  final String guardName;
  final String startDate;
  final String startTime;
  final String endTime;
  final int patrolLogCount;
  final String status;
  final String feedback;
  final List<dynamic> checkpoints;
  final Map<String, dynamic> data;
  ClientOpenPatrolScreen({
    super.key,
    required this.guardName,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.patrolLogCount,
    required this.status,
    required this.feedback,
    required this.checkpoints,
    required this.data,
  });

  @override
  State<ClientOpenPatrolScreen> createState() => _ClientOpenPatrolScreenState();
}

class _ClientOpenPatrolScreenState extends State<ClientOpenPatrolScreen> {
  DateTime? selectedDate;
  bool loading = false;

  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];

  void NavigateScreen(Widget screen, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        selectedDate = picked;
      }
    });
  }

  Future<String> generateShiftReportPdf(
      String guardName,
      Map<String, dynamic> data,
      ) async {
    final dateFormat = DateFormat('HH:mm');
    // Extract patrol information
    String patrolId = data['PatrolId'];
    DateTime patrolDate = data['PatrolDate'].toDate();
    List<dynamic> checkpoints = data['PatrolLogCheckPoints'];
    DateTime startedAt = data['PatrolLogStartedAt'].toDate();
    DateTime endedAt = data['PatrolLogEndedAt'].toDate();
    String patrolStatus = data['PatrolLogStatus'];
    int patrolCount = data['PatrolLogPatrolCount'];

    print('NIG1: $patrolId');
    print('NIG2: $patrolDate');
    print('NIG3: $checkpoints');
    print('NIG4: $startedAt');
    print('NIG5: $endedAt');
    print('NIG6: $patrolStatus');
    print('NIG7: $patrolCount');

    // Generate HTML for checkpoints
    String checkpointInfoHTML = '';
    for (var checkpoint in checkpoints) {
      String checkpointImages = '';
      if (checkpoint['CheckPointImage'] != null) {
        for (var image in checkpoint['CheckPointImage']) {
          checkpointImages += '<img src="$image" alt="Checkpoint Image">';
        }
      }
      DateTime reportedAt = checkpoint['CheckPointReportedAt'].toDate();
      checkpointInfoHTML += '''
      <div>
        <p>Checkpoint Name: ${checkpoint['CheckPointName'] ?? 'N/A'}</p>
        $checkpointImages
        <p>Comment: ${checkpoint['CheckPointComment'] ?? 'N/A'}</p>
        <p>Reported At: ${dateFormat.format(reportedAt)}</p>
        <p>Status: ${checkpoint['CheckPointStatus'] ?? 'N/A'}</p>
      </div>
    ''';
    }

    // Generate patrol info HTML
    String patrolInfoHTML = '''
    <tr>
      <td>$patrolCount</td>
      <td>${dateFormat.format(startedAt)}</td>
      <td>${dateFormat.format(endedAt)}</td>
      <td>$checkpointInfoHTML</td>
    </tr>
  ''';

    final htmlContent = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Security Report</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                display: flex;
                flex-direction: column;
                min-height: 100vh;
            }

            header {
                background-color: #333;
                color: white;
                padding: 20px;
                text-align: center;
            }

            h1 {
                margin: 0;
                font-size: 24px;
            }

            section {
                padding: 20px;
                background-color: #fff;
                margin-bottom: 20px;
                border-radius: 5px;
            }

            table {
                border-collapse: collapse;
                width: 100%;
            }

            th, td {
                border: 1px solid #ddd;
                padding: 8px;
                text-align: left;
            }

            th {
                background-color: #f2f2f2;
            }

            img {
                max-width: 100%;
                height: auto;
                display: block;
                margin-bottom: 10px;
                max-height: 200px;
            }

            footer {
                background-color: #333;
                color: white;
                text-align: center;
                padding: 10px 0;
                margin-top: auto;
            }
        </style>
    </head>
    <body>
        <header>
            <h1>Security Report</h1>
        </header>

        <section>
            <h3>Shift Information</h3>
            <table>
                <tr>
                    <th>Guard Name</th>
                    <th>Patrol Date</th>
                    <th>Patrol ID</th>
                </tr>
                <tr>
                    <td>$guardName</td>
                    <td>${DateFormat('yyyy-MM-dd').format(patrolDate)}</td>
                    <td>$patrolId</td>
                </tr>
            </table>
        </section>

        <section>
            <h3>Patrol Information</h3>
            <table>
                <tr>
                    <th>Patrol Count</th>
                    <th>Patrol Time In</th>
                    <th>Patrol Time Out</th>
                    <th>Checkpoint Details</th>
                </tr>
                $patrolInfoHTML
            </table>
        </section>

        <section>
            <h3>Additional Information</h3>
            <table>
                <tr>
                    <th>Status</th>
                    <th>Feedback Comment</th>
                </tr>
                <tr>
                    <td>$patrolStatus</td>
                    <td>${data['PatrolLogFeedbackComment'] ?? 'N/A'}</td>
                </tr>
            </table>
        </section>

        <footer>
            <p>&copy; 2024 TEAM TACTTIK. All rights reserved.</p>
        </footer>
    </body>
    </html>
  """;

    // Generate the PDF
    final pdfResponse = await http.post(
      Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'html': htmlContent,
        'file_name': 'security_report.pdf',
      }),
    );

    if (pdfResponse.statusCode == 200) {
      print('PDF generated successfully');
      final pdfBase64 = base64Encode(pdfResponse.bodyBytes);
      final file = await savePdfLocally(pdfBase64, 'security_report_${Timestamp.now().toString()}.pdf');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('PDF Viewer')),
            body: PDFView(
              filePath: file.path,
            ),
          ),
        ),
      );
      return pdfBase64;
    } else {
      print('Failed to generate PDF. Status code: ${pdfResponse.statusCode}');
      throw Exception('Failed to generate PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;
    // final String guardName = Data['PatrolLogGuardName'] ?? '';
    // final String startDate = Data['PatrolDate'] ?? '';
    // final String startTime = Data['PatrolLogStartedAt'] != null
    //     ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
    //         Data['PatrolLogStartedAt'].millisecondsSinceEpoch))
    //     : "";
    // final String endTime = Data['PatrolLogEndedAt'] != null
    //     ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
    //         Data['PatrolLogEndedAt'].millisecondsSinceEpoch))
    //     : "";
    // final int patrolLogCount = Data['PatrolLogPatrolCount'] ?? 0;
    // final String status = Data['PatrolLogStatus'] ?? 'N/A';
    // final String feedback =
    //     Data['PatrolLogFeedbackComment'] ?? 'No feedback provided';
    // final List<Map<String, dynamic>> checkpoints =
    //     Data['PatrolLogCheckPoints'] ?? [];

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
            text: "${widget.guardName}",
          ),
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
                    SizedBox(
                      height: 30.h,
                    ),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 140.w,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelectClientGuardsScreen(companyId: '',)));
                            },
                            child: IconTextWidget(
                              space: 6.w,
                              icon: Icons.add,
                              iconSize: 20.sp,
                              text: 'Select Guard',
                              useBold: true,
                              fontsize: 14.sp,
                              color: Theme.of(context).textTheme.bodySmall!.color
                                  as Color,
                              Iconcolor: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color as Color,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: SizedBox(
                            width: 190.w,
                            child: IconTextWidget(
                              icon: Icons.calendar_today,
                              text: selectedDate != null
                                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                                  : 'Display shift Date',
                              fontsize: 14.sp,
                              color: Theme.of(context).textTheme.bodySmall!.color
                                  as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),*/
                    Container(
                      height: 200.h,
                      margin: EdgeInsets.only(top: 10.h,left: 4.w,right: 4.w),
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
                      padding: EdgeInsets.only(top: 20.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: 5.h),
                                  Container(
                                    height: 30.h,
                                    width: 4.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.r),
                                        bottomRight: Radius.circular(10.r),
                                      ),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 14.w),
                              SizedBox(
                                width: 190.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: widget.guardName,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                      fontsize: 18.sp,
                                    ),
                                    // SizedBox(height: height / height5),
                                  ],
                                ),
                              )
                            ],
                          ),
                          // SizedBox(height: height / height10),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 18.w,
                              right: 24.w,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 70.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Started at',
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!,
                                      ),
                                      SizedBox(height: 12.h),
                                      InterMedium(
                                        text: widget.startTime,
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 70.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Ended at',
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!,
                                      ),
                                      SizedBox(height: 12.h),
                                      InterMedium(
                                        text: widget.endTime,
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 40.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Count',
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!,
                                      ),
                                      SizedBox(height: 12.sp),
                                      InterMedium(
                                        text: '${widget.patrolLogCount}',
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 80.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Status',
                                        fontsize: 14.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color!,
                                      ),
                                      SizedBox(height: 12.h),
                                      InterBold(
                                        text: widget.status,
                                        fontsize: 14.sp,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Feedback :',
                                      color: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .color!,
                                      fontsize: 14.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                        child: InterRegular(
                                      text: widget.feedback,
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .color,
                                      fontsize: 14.sp,
                                      maxLines: 3,
                                    )),
                                  ],
                                ),
                                SizedBox(
                                  width: 100.w,
                                  child: TextButton(
                                    clipBehavior: Clip.none,
                                    onPressed: () async {
                                      await generateShiftReportPdf(
                                        "Vaibhav",
                                        widget.data,
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.download_for_offline_sharp,
                                          size: 24.sp,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        InterMedium(
                                          text: 'PDF',
                                          color: Theme.of(context)
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
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    InterBold(
                      text: 'Checkpoints',
                      fontsize: 18.sp,
                      color:
                          Theme.of(context).textTheme.displaySmall!.color as Color,
                    ),
                    SizedBox(height: 20.h),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.checkpoints.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final checkpointData = widget.checkpoints[index];
                        final checkpointName =
                            checkpointData['CheckPointName'] ?? '';
                        final checkpointStatus =
                            checkpointData['CheckPointStatus'] ?? '';
                        final checkpointReportedAt =
                            checkpointData['CheckPointReportedAt'];
                        final checkpointComment =
                            checkpointData['CheckPointComment'] ?? '';
                        final checkpointImages =
                            checkpointData['CheckPointImage'] ?? [];

                        final reportedAtTime = checkpointReportedAt != null
                            ? DateFormat('hh:mm a').format(
                                (checkpointReportedAt as Timestamp).toDate())
                            : '';

                        return GestureDetector(
                          onTap: () {
                            NavigateScreen(
                              ViewCheckpointScreen(
                                reportedAt: reportedAtTime,
                                comment: checkpointComment,
                                images: checkpointImages,
                                GuardName: widget.guardName,
                              ),
                              context,
                            );
                          },
                          child: Container(
                            height: 50.h,
                            width: double.maxFinite,
                            margin: EdgeInsets.only(bottom: 10.h,left: 4.w,right: 4.w),
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
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 12.h,
                                      width: 12.w,
                                      decoration: BoxDecoration(
                                        color: checkpointStatus == 'checked'
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    SizedBox(
                                      width: 120.w,
                                      child: InterMedium(
                                        // text: 'Checkpoint name Checkpoint name..',
                                        color: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .color,
                                        text: checkpointName,
                                        // color: color21,
                                        fontsize: 16.sp,
                                      ),
                                    )
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 24.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .color as Color,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
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
                ),)
          ],
        ),
      ),
    );
  }
}
