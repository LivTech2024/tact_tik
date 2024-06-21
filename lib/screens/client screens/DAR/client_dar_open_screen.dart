import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../home screens/widgets/icon_text_widget.dart';
import 'client_open_dar_screen.dart';

class ClientDarOpenScreen extends StatefulWidget {
  final String employeeName;
  final String startTime;
  final String startDate;
  final List<dynamic> empDarTile;

  const ClientDarOpenScreen({
    super.key,
    required this.employeeName,
    required this.startTime,
    required this.empDarTile,
    required this.startDate,
  });

  @override
  State<ClientDarOpenScreen> createState() => _ClientDarOpenScreenState();
}

class _ClientDarOpenScreenState extends State<ClientDarOpenScreen> {
  DateTime? selectedDate;
  bool loading = false;

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

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<String> generateDARPdf(
    List<dynamic> Data,
    String GuardName,
    String DARTime,
    String DARDate,
  ) async {
    final dateFormat = DateFormat('HH:mm');

    String generateTableRows(List<dynamic> data) {
      String rows = '';
      for (var item in data) {
        String tileLocation = item['TileLocation'] ?? 'Not Defined';
        String tileContent = item['TileContent'] ?? 'Not Defined';
        List<dynamic> tileImages = item['TileImages'] ?? [];

        String imagesHtml = '';
        for (var image in tileImages) {
          imagesHtml += '<img src="$image" alt="Image">';
        }

        rows += """
      <tr>
        <td>$tileLocation</td>
        <td>$tileContent</td>
        <td>$imagesHtml</td>
      </tr>
      """;
      }
      return rows;
    }

    final htmlcontent = """
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Daily Activity Report</title>
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
              <h1>Daily Activity Report</h1>
          </div>
          <table class="report-header">
              <tr>
                  <td class="title">Employee Name: ${GuardName}</td>
                  <td>Date: ${DARDate}</td>
              </tr>
              <tr>
                  <td>Shift Start Time: ${DARTime}</td>
              </tr>
              <tr>
                  <td>Shift Start Date: ${DARDate}</td>
              </tr>
          </table>
          <table class="report-section">
              ${generateTableRows(Data)}
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
      final file = await savePdfLocally(pdfBase64, 'security_report.pdf');
      openPdf(file);
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
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

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
            text: widget.employeeName,
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: SizedBox(
                            width: 140.w,
                            child: IconTextWidget(
                              icon: Icons.calendar_today,
                              text: selectedDate != null
                                  ? "${selectedDate!.toLocal()}".split(' ')[0]
                                  : 'Select Date',
                              fontsize: 14.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color as Color,
                              Iconcolor: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .color as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      height: 130.h,
                      margin: EdgeInsets.only(top: 10.h),
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
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color: isDark
                                          ? DarkColor.Primarycolor
                                          : LightColor.Primarycolor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 14.w),
                              SizedBox(
                                width: 190.w,
                                child: InterSemibold(
                                  text: widget.employeeName,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                  fontsize: 18.sp,
                                ),
                              )
                            ],
                          ),
                          // SizedBox(height: 10.h),
                          /*Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    InterRegular(
                                      text: 'Started At',
                                      fontsize: 14.sp,
                                      color: isDark
                                          ? DarkColor.color21
                                          : LightColor.color2,
                                    ),
                                    SizedBox(width: 60.w),
                                    // InterRegular(
                                    //   text: 'Ended at',
                                    //   fontsize: 14.sp,
                                    //   color: isDark
                                    //       ? DarkColor.color21
                                    //       : LightColor.color2,
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    InterRegular(
                                      text: widget.startTime,
                                      fontsize: 14.sp,
                                      color: isDark
                                          ? DarkColor.color21
                                          : LightColor.color2,
                                    ),
                                    SizedBox(width: 90.w),
                                    // InterRegular(
                                    //   text: '16:56',
                                    //   fontsize: 14.sp,
                                    //   color: isDark
                                    //       ? DarkColor.color21
                                    //       : LightColor.color2,
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          )*/
                          SizedBox(
                            width: 100.w,
                            child: TextButton(
                              clipBehavior: Clip.none,
                              onPressed: () {
                                setState(() {
                                  loading = true;
                                });
                                generateDARPdf(
                                    widget.empDarTile,
                                    widget.employeeName,
                                    widget.startTime,
                                    widget.startDate);
                                setState(() {
                                  loading = false;
                                });
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
                    ),
                    SizedBox(height: 30.h),
                    InterBold(
                      text: 'Place/Spot',
                      fontsize: 18.sp,
                    ),
                    SizedBox(height: 20.h),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.empDarTile.where((tile) {
                        final tileDate = tile['TileDate'] as Timestamp;
                        final tileDateTime = tileDate.toDate();
                        return selectedDate == null ||
                            _isSameDate(tileDateTime, selectedDate!);
                      }).length,
                      itemBuilder: (context, index) {
                        final filteredTiles = widget.empDarTile.where((tile) {
                          final tileDate = tile['TileDate'] as Timestamp;
                          final tileDateTime = tileDate.toDate();
                          return selectedDate == null ||
                              _isSameDate(tileDateTime, selectedDate!);
                        }).toList();

                        final tile = filteredTiles[index];
                        final tileContent =
                            tile['TileContent'] ?? 'Not Defined';
                        final tileTime = tile['TileTime'];
                        final tileLocation =
                            tile['TileLocation'] ?? 'Not Defined';
                        final tilePatrol = tile['TilePatrol'] ?? [];
                        final tileReport = tile['TileReport'] ?? [];
                        final tileImages = tile['TileImages'] ?? [];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClientOpenDarScreen(
                                  tileLocation: tileLocation,
                                  tileTime: tileTime,
                                  tileDescription: tileContent,
                                  empName: widget.employeeName,
                                  tilePatrol: tilePatrol,
                                  tileReport: tileReport,
                                  tileImages: tileImages,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 46.h,
                            width: double.maxFinite,
                            margin: EdgeInsets.only(bottom: 10.h),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150.w,
                                  child: InterMedium(
                                    text: tileLocation == ''
                                        ? 'Not Defined'
                                        : tileLocation,
                                    fontsize: 16.sp,
                                  ),
                                ),
                                Row(
                                  children: [
                                    InterSemibold(
                                        text: tileTime, fontsize: 16.sp),
                                    SizedBox(width: 5.w),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                      size: 24.sp,
                                    ),
                                  ],
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
              ),
            )
          ],
        ),
      ),
    );
  }

  void openPdf(File file) {
    OpenFile.open(file.path);
  }
}
