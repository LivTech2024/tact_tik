import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:http/http.dart' as http;

import '../../fonts/inter_regular.dart';

class HistoryScreen extends StatefulWidget {
  final String empID;
  const HistoryScreen({super.key, required this.empID});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String shiftName = '';
  String shiftLocation = '';
  String shiftStartTimeStr = '';
  String shiftEndTimeStr = '';
  String shiftTotalTime = '';
  late Timestamp shiftActualDate;
  late String shiftActualId;
  String shiftClientName = '';
  String shiftClientId = '';
  String logoImageUrl = '';
  String shiftDateStr = '';
  late Duration totalWorkHours;
  late Duration breakDuration;
  late Duration totalWorkHoursAfterBreak;
  int hours = 0;
  int minutes = 0;

  @override
  void initState() {
    // TODO: implement initState
    fetchShiftHistoryDetails();
    super.initState();
  }

  List<Map<String, dynamic>> shiftHistory = [];
  FireStoreService fireStoreService = FireStoreService();
  void fetchShiftHistoryDetails() async {
    print("Emp ID ${widget.empID}");
    var shifthistory = await fireStoreService.getShiftHistory(widget.empID);
    setState(() {
      shiftHistory = shifthistory;
    });
    print('Shift History :  ${shifthistory}');
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  TimeOfDay _stringToTimeOfDay(String time) {
    final format = time.split(":");
    int hour = int.parse(format[0]);
    int minute = int.parse(format[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  _getTimeDifference(TimeOfDay startTime, TimeOfDay endTime) {
    final now = DateTime.now();
    final startDateTime = DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute);
    final endDateTime =
        DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    // Calculate difference
    totalWorkHours = endDateTime.difference(startDateTime);

    // If the end time is before the start time, assume it’s the next day
    if (totalWorkHours.isNegative) {
      final nextDayEndDateTime = endDateTime.add(Duration(days: 1));
      totalWorkHours = nextDayEndDateTime.difference(startDateTime);
    }
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    print('Formatted Duration: ${hours}h ${minutes}m'); 
    return '${hours}h ${minutes}m';
  }

  void fetchBreakTimes() async {
    print('inside fetch');

    try {
      // Firestore instance
      // FirebaseFirestore firestore = FirebaseFirestore.instance;
      print('shiftID: $shiftActualId');

      print("now fetch snapshot");
      // Path to the document, change 'collectionName' and 'documentID' accordingly
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Shifts')
          .where('ShiftId',
              isEqualTo: shiftActualId) // Adjust field name if needed
          .get();

      print("fetch snapshot done");
      // Check if any documents were returned
      if (querySnapshot.docs.isNotEmpty) {
        // Loop through the results
        for (var documentSnapshot in querySnapshot.docs) {
          print('Document data: ${documentSnapshot.data()}');

          // Assuming the array is directly within the document
          List<dynamic> firstArray = documentSnapshot.get('ShiftCurrentStatus');

          // Access the map inside the array, assuming it's the first element
          Map<String, dynamic> map = firstArray[0];

          // Access the second array inside the map
          List<dynamic> secondArray = map['StatusBreak'];

          // Access the final map inside the second array, assuming it's the first element
          Map<String, dynamic> finalMap = secondArray[0];

          // Retrieve BreakEndTime and BreakStartTime
          Timestamp breakEndTimeTimestamp = finalMap['BreakEndTime'];
          Timestamp breakStartTimeTimestamp = finalMap['BreakStartTime'];

          // Convert Firebase Timestamp to DateTime
          DateTime breakEndTime = (breakEndTimeTimestamp).toDate();
          DateTime breakStartTime = (breakStartTimeTimestamp).toDate();

          print('Break End Time: $breakEndTime');
          print('Break Start Time: $breakStartTime');

          // Calculate the difference
          breakDuration = breakEndTime.difference(breakStartTime);

          print('Break Duration: $breakDuration');

          // Make sure totalWorkHours is initialized before subtraction
          if (totalWorkHours != null && breakDuration != null) {
            totalWorkHoursAfterBreak = totalWorkHours - breakDuration;
            print('Total Work Hours After Break: $totalWorkHoursAfterBreak');
          } else {
            print('Total Work Hours or Break Duration is null');
          }
        }
      } else {
        print('No documents match the query!');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> getData(var shiftData) async {
    //Basic Details:
    shiftActualDate = shiftData['ShiftDate'];
    DateTime shiftDateTime = shiftActualDate.toDate();
    shiftDateStr = DateFormat('dd/MM/yyyy').format(shiftDateTime);

    // shiftDateTime.format

    shiftStartTimeStr = shiftData['ShiftStartTime'];
    shiftEndTimeStr = shiftData['ShiftEndTime'];

    TimeOfDay shiftStartTime = _stringToTimeOfDay(shiftStartTimeStr);
    TimeOfDay shiftEndTime = _stringToTimeOfDay(shiftEndTimeStr);

    shiftActualId = shiftData['ShiftId'];
    print('shiftActualId');

    _getTimeDifference(shiftStartTime, shiftEndTime);
    fetchBreakTimes();

    //Shift Details:
    shiftName = shiftData['ShiftName'];
    shiftLocation = shiftData['ShiftLocationAddress'];

    //For Client Name:
    shiftClientId = shiftData['ShiftClientId'];
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('Clients')
        .where('ClientId', isEqualTo: shiftClientId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> clientData = querySnapshot.docs.first.data();
      setState(() {
        shiftClientName = clientData['ClientName'];
      });

      print('Client Name: $shiftClientName');
    } else {
      print('No matching client found');
    }
    print("GetData done");

    //TODO:
    //Total Work Hours:

    //Breaks Taken:
    //Patrol Status:
  }

  Future<String> generateShiftReportPdf() async {
    print('inside shiftReport');
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });

    final dateFormat = DateFormat('HH:mm'); // Define the format for time

    final totalWorkHoursString = totalWorkHoursAfterBreak != null
    ? formatDuration(totalWorkHoursAfterBreak)
    : '0h 0m';
    final breakDurationString = breakDuration != null
    ? formatDuration(breakDuration)
    : '0h 0m';

    print("now html");
    final htmlcontent = """
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

        .logo-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .logo-container img {
            max-height: 50px; /* Set the max-height for the logos */
        }

        h1 {
            margin: 0;
            font-size: 24px;
            flex-grow: 1; /* Allow the <h1> to grow and fill the space */
        }

        h3 {
          color: #7137CD
        }

        section {
            padding-top: 5px;
            padding-bottom: 5px;
            padding-left:25px;
        }
        .location {
            width: 50%;
            max-width: 50%;
            word-wrap: break-word;
        }


        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin-bottom: 10px;
            max-height: 200px; /* Define a max-height for the images */
        }

        footer {
            background-color: #333;
            color: white;
            text-align: center;
            padding: 10px 0;
            margin-top: auto; /* Push the footer to the bottom of the page */
        }
    </style>
</head>
<body>
    <header>
        <h1>Shift Report</h1>
    </header>

    <section>
    <img src="tacticalProtection.jpeg" alt="Tactical Protection">
    </section>

    <section>
        <h3>Basic Details</h3>
        <p><b>Date:</b> ${shiftDateStr}</p>
        <p><b>Time: </b>Time</p>
        <p><b>Shift Start:</b> ${shiftStartTimeStr}</p>
        <p><b>Shift End:</b> ${shiftEndTimeStr}</p>
    </section>
    <section>
        <h3>Shift Details</h3>
        <p><b>Shift Name:</b> ${shiftName}</p>
        <p><b>Client:</b> ${shiftClientName}</p>
        <p class="location"><b>Locaiton:</b> ${shiftLocation}</p>
    </section>
   <section>
    <h3>Work Details</h3>
    <p><b>Total Work Hours: </b> ${totalWorkHoursString}</p>
    <p><b>Breaks Taken: </b> ${breakDurationString}</p>
</section>
    <section>
        <h3>Status</h3>
        <p><b>Patrol Status:</b> status</p>
    </section>
</body>
</html>
  """;

    // Generate the PDF
    final pdfResponse = await http.post(
      Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'html': htmlcontent,
        'file_name': '${shiftName}-shift_report.pdf',
      }),
    );

    if (pdfResponse.statusCode == 200) {
      print('PDF generated successfully');
      final pdfBase64 = await base64Encode(pdfResponse.bodyBytes);
      savePdfLocally(pdfBase64, '${shiftName}-shift_report.pdf');
      Navigator.of(context).pop();
      print('PDF Saved');
      return pdfBase64;
    } else {
      Navigator.of(context).pop();
      print('Failed to generate PDF. Status code: ${pdfResponse.statusCode}');
      throw Exception('Failed to generate PDF');
    }
  }

  Future<File> savePdfLocally(String pdfBase64, String fileName) async {
    final pdfBytes = base64Decode(pdfBase64);
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    }

    final file = File('${directory?.path}/$fileName');

    await file.writeAsBytes(pdfBytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          // physics: const PageScrollPhysics(),
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
                text: 'My History',
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30.h,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (shiftHistory.isEmpty) {
                    return Center(
                      child: Text('No shift history available.'),
                    );
                  }
                  var shift = shiftHistory[index];
                  DateTime shiftDate =
                      (shift['ShiftDate'] as Timestamp).toDate();
                  String date =
                      '${shiftDate.day}/${shiftDate.month}/${shiftDate.year}';
                  String dayOfWeek = _getDayOfWeek(shiftDate.weekday);
                  return Padding(
                    padding:
                        EdgeInsets.only(left: 30.w, right: 30.w, bottom: 40.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: "${date}  ${dayOfWeek}",
                          fontsize: width / width18,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          constraints: BoxConstraints(
                            minHeight: 340.h,
                          ),
                          padding: EdgeInsets.only(
                            top: 20.h,
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
                            borderRadius: BorderRadius.circular(10.w),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Shift Name',
                                      fontsize: 16.w,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                    ),
                                    SizedBox(width: 40.w),
                                    Flexible(
                                      child: InterSemibold(
                                        text: shift['ShiftName'],
                                        fontsize: 16.w,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                height: 100.h,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? DarkColor.colorRed
                                    : LightColor.colorRed,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Location',
                                      fontsize: 16.w,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                    ),
                                    SizedBox(width: width / width40),
                                    Flexible(
                                      child: InterSemibold(
                                        text: shift['ShiftLocationAddress'],
                                        fontsize: 16.w,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.h),
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterSemibold(
                                          text: 'Shift Timimg',
                                          fontsize: 16.w,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        InterSemibold(
                                          text:
                                              '${shift['ShiftStartTime']} to ${shift['ShiftEndTime']}',
                                          fontsize: 16.w,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: height / height20),
                                    SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterSemibold(
                                            text: 'Total',
                                            fontsize: 16.w,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                          SizedBox(
                                            height: 20.h,
                                          ),
                                          InterSemibold(
                                            text: '',
                                            fontsize: 16.sp,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Button1(
                                text: 'text',
                                useWidget: true,
                                MyWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_for_offline,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 24.sp,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    InterSemibold(
                                      text: 'Download',
                                      color: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .color,
                                      fontsize: 16.sp,
                                    )
                                  ],
                                ),
                                onPressed: () {
                                  try {
                                    print("Done button tapped");
                                    getData(shift);

                                    // shiftTotalTime=;
                                    generateShiftReportPdf();
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                backgroundcolor:
                                    Theme.of(context).primaryColorLight,
                                useBorderRadius: true,
                                MyBorderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.w),
                                  bottomRight: Radius.circular(12.w),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: shiftHistory.isNotEmpty ? shiftHistory.length : 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
} /**/
