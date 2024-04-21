import 'dart:async';
import 'dart:isolate';

import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/riverpod/task_screen_provider.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/eg_patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/shift_return_task_screen.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/backgroundService/countDownTimer.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:tact_tik/utils/colors.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_semibold.dart';

class StartTaskScreen extends StatefulWidget {
  final String ShiftDate;
  final String ShiftEndTime;
  final String ShiftStartTime;
  final String EmployeId;
  final String ShiftId;
  final String ShiftClientID;
  final String ShiftAddressName;
  final String ShiftCompanyId;
  final String ShiftBranchId;
  final String EmployeeName;
  final String ShiftLocationId;
  final bool ShiftIN;
  final VoidCallback resetShiftStarted;
  final VoidCallback onRefresh;

  // final String ShiftLocation;
  // final String ShiftName;

  StartTaskScreen({
    required this.ShiftDate,
    required this.ShiftClientID,
    required this.ShiftEndTime,
    required this.ShiftStartTime,
    required this.EmployeId,
    required this.ShiftId,
    required this.ShiftAddressName,
    required this.ShiftCompanyId,
    required this.ShiftBranchId,
    required this.EmployeeName,
    required this.ShiftLocationId,
    required this.resetShiftStarted,
    required this.ShiftIN,
    required this.onRefresh,

    // required this.ShiftLocation,
    // required this.ShiftName,
  });

  @override
  State<StartTaskScreen> createState() => _StartTaskScreenState();
}

// final taskScreenProvider = StateNotifierProvider((ref) => TaskScreenState());
FireStoreService fireStoreService = FireStoreService();

class _StartTaskScreenState extends State<StartTaskScreen> {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  bool clickedIn = false;
  bool issShift = true;
  late Timer _stopwatchTimer;
  int _stopwatchSeconds = 0;
  String stopwatchtime = "";
  bool isPaused = false;
  bool onBreak = false;
  DateTime inTime = DateTime.now();
  int _elapsedTime = 0;

  // late SharedPreferences prefs;
  void send_mail_onOut() async {
    //fetch all the patrol ids assigned to him using
    List<String> emails = [];
    var ClientEmail =
        await fireStoreService.getClientEmail(widget.ShiftClientID);
    var AdminEmail =
        await fireStoreService.getAdminEmail(widget.ShiftCompanyId);
    var TestinEmail = "sutarvaibhav37@gmail.com";
    var defaultEmail = "tacttikofficial@gmail.com";
    var ClientName = await fireStoreService.getClientName(widget.ShiftClientID);
    // emails.add(ClientEmail!);
    emails.add("sutarvaibhav37@student.sfit.ac.in");
    emails.add("sutarvaibhav37@gmail.com");
    // var TestinEmail = "sutarvaibhav37@gmail.com";
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String formattedStartDate = dateFormat.format(DateTime.now());
    String formattedEndDate = dateFormat.format(DateTime.now());
    String formattedEndTime = dateFormat.format(DateTime.now());
    await fireStoreService.fetchPatrolData(widget.ShiftId, widget.EmployeId);

    if (ClientEmail != null && AdminEmail != null) {
      // emails.add(AdminEmail);
      // sendShiftEmail(
      // emails.add(TestinEmail);
      Map<String, dynamic> emailParams = {
        'to_email': '$ClientEmail, $AdminEmail ,$defaultEmail',
        // 'to_email': '$TestinEmail',
        "startDate": '${widget.ShiftId}',
        "endDate": '${widget.ShiftDate}',
        'from_name': '${widget.EmployeeName}',
        'reply_to': '$defaultEmail',
        'type': 'Shift ',
        'Location': '${widget.ShiftAddressName}',
        'Status': 'Completed',
        'GuardName': '${widget.EmployeeName}',
        'StartTime': '${widget.ShiftStartTime}',
        'EndTime': '${stopwatchtime}',
        'CompanyName': 'Tacttik',
      };
      //     emails,
      //     "Update on Shift",
      //     widget.EmployeeName,
      //     "",
      //     "Shift",
      //     widget.ShiftDate,
      //     imageData,
      //     widget.EmployeeName,
      //     widget.ShiftStartTime,
      //     widget.ShiftEndTime,
      //     widget.ShiftAddressName,
      //     "Completed",
      //     "ShiftInTime",
      //     "ShiftOutTime");
      // sendFormattedEmail(emailParams);
    }
  }

  @override
  void initState() {
    super.initState();
    inTime = DateTime.now();

    initPrefs();
    initStopwatch();
    startStopwatch();
  }

  void reload() {
    initPrefs();
    initState();
  }

  void _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedClickedIn = prefs.getBool('clickedIn');
    setState(() {
      clickedIn = savedClickedIn!;
    });
  }

  void initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedClickedIn = prefs.getBool('clickedIn');
    print("saved Clicked in values: ${savedClickedIn}");
    bool? pauseState = prefs.getBool('paused');
    bool? breakState = prefs.getBool('onBreak');
    setState(() {
      clickedIn = savedClickedIn!;
    });
    if (pauseState != null) {
      setState(() {
        isPaused = pauseState;
      });
    }
    if (breakState != null) {
      // Add this block
      setState(() {
        onBreak = breakState;
      });
      if (!onBreak) {
        startStopwatch();
      }
    }
    int? savedSeconds = prefs.getInt('stopwatchSeconds');
    int? savedInTimeMillis = prefs.getInt('savedInTime');

    if (savedSeconds != null) {
      setState(() {
        _stopwatchSeconds = savedSeconds;
      });
    }
    if (savedInTimeMillis != null) {
      // Change this line
      setState(() {
        inTime = DateTime.fromMillisecondsSinceEpoch(savedInTimeMillis);
      });
    }
  }

  void initStopwatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _elapsedTime = prefs.getInt('elapsedTime') ?? 0;
    });
    print("ELapsedTime: ${_elapsedTime}");
  }

  void startStopwatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (clickedIn && !isPaused) {
      _stopwatchTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {
          _stopwatchSeconds++;
          prefs.setInt('stopwatchSeconds', _stopwatchSeconds);
          prefs.setBool("stopwatchKey", true);
        });
      });
    }
  }

  void resetStopwatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _stopwatchSeconds = 0;
      prefs.setInt('stopwatchSeconds', _stopwatchSeconds);
    });
  }

  void resetClickedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      clickedIn = false;
      prefs.setBool('clickedIn', clickedIn);
      isPaused = false;
      prefs.setBool('pauseState', isPaused);
      _stopwatchSeconds = 0;
      prefs.setInt('savedInTime', _stopwatchSeconds);

      // Reset clickedIn state
      resetStopwatch(); // Reset the stopwatch
    });
  }

  void stopStopwatch() {
    _stopwatchTimer.cancel(); // Stop the stopwatch timer
  }

  @override
  void dispose() {
    _stopwatchTimer.cancel();
    // resetClickedState();
    super.dispose();
  }

  final LocalStorage storage = LocalStorage('ShiftDetails');

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    // Get the current time
    DateTime currentTime = DateTime.now();
    DateFormat format = DateFormat('HH:mm');
// Parse the shift start time from the widget
    DateTime shiftStartTime = format.parse(widget.ShiftStartTime);

// Convert shift start time to current date for comparison
    String lateTime = "";
    if (inTime != null) {
      DateTime currentTime = DateTime.now();
      DateTime shiftStartTime = format.parse(widget.ShiftStartTime);
      shiftStartTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        shiftStartTime.hour,
        shiftStartTime.minute,
      );
      Duration difference = shiftStartTime.difference(inTime!);
      int differenceInMinutes = difference.inMinutes.abs();

      if (differenceInMinutes > 5) {
        int hours = differenceInMinutes ~/ 60;
        int minutes = differenceInMinutes % 60;
        lateTime = '${hours}Hr ${minutes}m Late';
      }
    }
    print("IN Time : ${inTime}");
    print("Elapsed  : ${_elapsedTime}");

    print(lateTime);
    // DateTime dateTime = format.parse(widget.ShiftStartTime);
    String formattedStopwatchTime =
        '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}';
    setState(() {
      stopwatchtime = formattedStopwatchTime;
    });
    String employeeCurrentStatus = "";
    return Column(
      children: [
        Container(
          height: height / height200,
          decoration: const BoxDecoration(
            color: WidgetColor,
          ),
          padding: EdgeInsets.only(
              left: width / width26,
              top: height / height10,
              right: width / width12),
          child: Column(
            children: [
              Row(
                children: [
                  InterBold(
                    text: widget.ShiftDate,
                    color: color1,
                    fontsize: width / width18,
                  ),
                  SizedBox(
                    width: width / width12,
                  ),
                  Bounce(
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.contact_support_outlined,
                        size: width / width20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  )
                ],
              ),
              // SizedBox(height: height / height10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width / width100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'In time',
                          fontsize: width / width14,
                          color: color1,
                        ),
                        SizedBox(height: height / height10),
                        InterRegular(
                          text: widget.ShiftStartTime,
                          fontsize: width / width16,
                          color: color7,
                        ),
                        SizedBox(height: height / height20),
                        clickedIn
                            ? InterSemibold(
                                text: lateTime,
                                color: Colors.redAccent,
                                fontsize: width / width12,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width / width100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterMedium(
                          text: 'Out time',
                          fontsize: width / width14,
                          color: color1,
                        ),
                        SizedBox(height: height / height10),
                        InterRegular(
                          text: widget.ShiftEndTime,
                          fontsize: width / width16,
                          color: color7,
                        ),
                        SizedBox(height: height / height20),
                        clickedIn
                            ? InterSemibold(
                                text:
                                    '${(_stopwatchSeconds ~/ 3600).toString().padLeft(2, '0')} : ${((_stopwatchSeconds ~/ 60) % 60).toString().padLeft(2, '0')} : ${(_stopwatchSeconds % 60).toString().padLeft(2, '0')}',
                                color: color8,
                                fontsize: width / width12,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: width / width12),
                    height: height / height74,
                    width: width / width70,
                    decoration: BoxDecoration(
                      // color: Colors.redAccent,
                      image: DecorationImage(
                        image: AssetImage('assets/images/log_book.png'),
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: height / height10),
        Container(
          height: height / height65,
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: height / height5),
          decoration: BoxDecoration(
            color: WidgetColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: clickedIn,
                  child: Bounce(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool? status =
                          await fireStoreService.checkShiftReturnTaskStatus(
                              widget.EmployeId, widget.ShiftId);
                      await fireStoreService.addToLog(
                          'ShiftStarted',
                          widget.ShiftAddressName,
                          "",
                          Timestamp.now(),
                          Timestamp.now(),
                          widget.EmployeId,
                          widget.EmployeeName,
                          widget.ShiftCompanyId,
                          widget.ShiftBranchId,
                          widget.ShiftClientID);
                      setState(() {
                        if (!clickedIn) {
                          clickedIn = true;
                          prefs.setBool('clickedIn', clickedIn);
                          DateTime currentTime = DateTime.now();
                          inTime = currentTime;
                          prefs.setInt('savedInTime',
                              currentTime.millisecondsSinceEpoch);
                          Timestamp.now();
                          if (status == false) {
                            print("Staus is false");
                          } else {
                            print("Staus is true");
                          }
                          fireStoreService
                              .fetchreturnShiftTasks(widget.ShiftId);
                          startStopwatch();
                        } else {
                          print('already clicked');
                        }
                      });
                    },
                    child: Container(
                      color: WidgetColor,
                      child: Center(
                        child: InterBold(
                          text: 'Start Shift',
                          fontsize: width / width18,
                          color: clickedIn ? Primarycolorlight : Primarycolor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                color: Colors.white,
              ),
              Expanded(
                child: IgnorePointer(
                  ignoring: !clickedIn,
                  child: Bounce(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      bool? status =
                          await fireStoreService.checkShiftReturnTaskStatus(
                              widget.EmployeId, widget.ShiftId);
                      if (status == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShiftReturnTaskScreen(
                                    shiftId: widget.ShiftId,
                                    Empid: widget.EmployeId,
                                    ShiftName: widget.ShiftAddressName,
                                    EmpName: widget.EmployeeName,
                                  )),
                        );
                      } else {
                        setState(() {
                          // isPaused = !isPaused;
                          // prefs.setBool("pauseState", isPaused);
                          clickedIn = false;
                          resetStopwatch();
                          resetClickedState();
                          widget.resetShiftStarted();
                          prefs.setBool('ShiftStarted', false);
                        });
                        await fireStoreService.addToLog(
                            'ShiftEnd',
                            widget.ShiftAddressName,
                            "",
                            Timestamp.now(),
                            Timestamp.now(),
                            widget.EmployeId,
                            widget.EmployeeName,
                            widget.ShiftCompanyId,
                            widget.ShiftBranchId,
                            widget.ShiftClientID);
                        await fireStoreService.EndShiftLog(
                            widget.EmployeId,
                            formattedStopwatchTime,
                            widget.ShiftId,
                            widget.ShiftAddressName,
                            widget.ShiftBranchId,
                            widget.ShiftCompanyId,
                            widget.EmployeeName);

                        var ClientName = fireStoreService
                            .getClientName(widget.ShiftClientID);
                        var ClientEmail = fireStoreService
                            .getClientEmail(widget.ShiftClientID);
                        var AdminEmal = fireStoreService
                            .getAdminEmail(widget.ShiftCompanyId);
                        //fetch the data from Patrol Logs and generate email from it
                        var data = await fireStoreService.fetchDataForPdf(
                            widget.EmployeId, widget.ShiftId);

                        // generateAndOpenPDF(
                        //     'Vaibhav',
                        //     "sutarvaibhav37@gmail.com",
                        //     "sutarvaibhav37@gmail.com",
                        //     data);
                        //for now send email same as patrol
                        //generate the pdf
                        //add to firebase storage and then mail too
                        // String? pdfLink = fireStoreService.uploadPdfToStorage(
                        //     file, widget.ShiftId);
                        // send_mail_onOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      }
                    },
                    child: Container(
                      color: WidgetColor,
                      child: Center(
                        child: InterBold(
                          text: 'End Shift',
                          fontsize: width / width18,
                          color: clickedIn ? Primarycolor : Primarycolorlight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height / height10),
        clickedIn
            ? IgnorePointer(
                ignoring: !clickedIn,
                child: Button1(
                  height: height / height65,
                  text: isPaused ? 'Resume' : (onBreak ? 'Resume' : 'Break'),
                  fontsize: width / width18,
                  color: color5,
                  backgroundcolor: WidgetColor,
                  onPressed: () async {
                    var data = await fireStoreService.fetchDataForPdf(
                        widget.EmployeId, widget.ShiftId);
                    print(data);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    setState(() {
                      isPaused = !isPaused;
                      onBreak = false;
                      prefs.setBool('pauseState', isPaused);
                    });
                    // isPaused ? stopStopwatch() : startStopwatch();
                    if (isPaused) {
                      await fireStoreService.addToLog(
                          'ShiftBreak',
                          widget.ShiftAddressName,
                          "",
                          Timestamp.now(),
                          Timestamp.now(),
                          widget.EmployeId,
                          widget.EmployeeName,
                          widget.ShiftCompanyId,
                          widget.ShiftBranchId,
                          widget.ShiftClientID);
                      stopStopwatch();
                      setState(() {
                        onBreak = true;
                        prefs.setBool('onBreak', onBreak);
                      });
                      fireStoreService.BreakShiftLog(widget.EmployeId);
                    } else {
                      onBreak = false;
                      await fireStoreService.addToLog(
                          'ShiftResume',
                          widget.ShiftAddressName,
                          "",
                          Timestamp.now(),
                          Timestamp.now(),
                          widget.EmployeId,
                          widget.EmployeeName,
                          widget.ShiftCompanyId,
                          widget.ShiftBranchId,
                          widget.ShiftClientID);
                      prefs.setBool('onBreak', onBreak);
                      startStopwatch();
                      fireStoreService.ResumeShiftLog(widget.EmployeId);
                    }
                  },
                ),
              )
            : const SizedBox(),
        IgnorePointer(
          ignoring: !clickedIn,
          child: Button1(
            text: 'Check Patrolling',
            fontsize: width / width18,
            color: color5,
            backgroundcolor: WidgetColor,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyPatrolsList(
                            ShiftLocationId: widget.ShiftLocationId,
                            EmployeeID: widget.EmployeId,
                            EmployeeName: widget.EmployeeName,
                            ShiftId: widget.ShiftId,
                            ShiftDate: widget.ShiftDate,
                          )));
            },
          ),
        ),
      ],
    );
  }

  Future<void> generateAndOpenPDF(ClientName, ClientEmail, AdminEmal,
      List<Map<String, dynamic>> data) async {
    try {
      final pdf = pw.Document();

      final ByteData logoImageData1 =
          await rootBundle.load('assets/TPS RGB.png');
      final ByteData logoImageData2 =
          await rootBundle.load('assets/Tactik.jpeg');
      final Uint8List logoImageBytes1 = logoImageData1.buffer.asUint8List();
      final Uint8List logoImageBytes2 = logoImageData2.buffer.asUint8List();
      final logo1 = pw.MemoryImage(logoImageBytes1);
      final logo2 = pw.MemoryImage(logoImageBytes2);

      String patrolDate = data[0]['PatrolDate'];
      String patrolId = data[0]['PatrolId'];
      List<dynamic> patrolLogCheckPoints = data[0]['PatrolLogCheckPoints'];

      String patrolLogPatrolCount = data[0]['PatrolLogPatrolCount'];
      String patrolLogStartedAt = data[0]['PatrolLogStartedAt'];
      String patrolLogEndedAt = data[0]['PatrolLogEndedAt'];

      final List<Map<String, dynamic>> patrolEntries = [
        {
          'timeIn': patrolLogStartedAt,
          'timeOut': patrolLogEndedAt,
          'comment': 'Hello',
        },
      ];

      List<Map<String, dynamic>> detailedPatrolReport = [];
      for (int i = 0; i < patrolLogCheckPoints.length; i++) {
        Map<String, dynamic> checkPoint = patrolLogCheckPoints[i];
        String checkPointName = checkPoint['CheckPointName'];
        String checkPointComment = checkPoint['CheckPointComment'];
        String checkPointImage = checkPoint['CheckPointImage'][0];

        detailedPatrolReport.add({
          'patrol': patrolLogPatrolCount,
          'checkpointName': checkPointName,
          'comment': checkPointComment,
          'image': checkPointImage,
        });
      }

      final List<pw.MemoryImage> images = [];
      for (var entry in detailedPatrolReport) {
        final response = await http.get(Uri.parse(entry['image']));
        if (response.statusCode == 200) {
          final Uint8List imageBytes = response.bodyBytes;
          images.add(pw.MemoryImage(imageBytes));
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    left: 0,
                    top: 0,
                    child: pw.Image(logo1, width: 150, height: 150),
                  ),
                  pw.Positioned(
                    right: 10,
                    top: 15,
                    child: pw.Image(logo2, width: 100, height: 90),
                  ),
                ],
              ),
            ),
          ),
          build: (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'SHIFT/PATROL REPORT',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 50),
                pw.Text(
                  'Dear $ClientName,\n\nI hope this email finds you well. I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during their shift. Below is a detailed breakdown of the patrols conducted:',
                  style: pw.TextStyle(
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '** Shift Information:**',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Guard Name',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Shift Time In',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Shift Time Out',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Date',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('$ClientName'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('20:00'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('06:00'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('April 17, 2024 - April 18, 2024'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '** Patrol Information:**',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol Count',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol Time In ',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol Time Out',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Comments',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var i = 0; i < patrolEntries.length; i++)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text((i + 1).toString()),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:
                                  pw.Text(patrolEntries[i]['timeIn'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  patrolEntries[i]['timeOut'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  patrolEntries[i]['comment'] as String),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '** Detailed Patrol Report:**',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Checkpoint Name',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Time',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Comment',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Image',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var i = 0; i < detailedPatrolReport.length; i++)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  detailedPatrolReport[i]['patrol'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(detailedPatrolReport[i]
                                  ['checkpointName'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  detailedPatrolReport[i]['time'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  detailedPatrolReport[i]['comment'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:
                                  pw.Image(images[i], width: 100, height: 100),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      final output = await getExternalStorageDirectory();
      if (output != null) {
        final downloadsDirectory = Directory('${output.path}/Download');
        await downloadsDirectory.create(recursive: true);
        final file = File('${downloadsDirectory.path}/shift_patrol_report.pdf');
        final Uint8List pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
        print('PDF Generated');
        print('PDF Generated at: ${file.path}');
        // Open the PDF file
        OpenFile.open(file.path);
      } else {
        print('Error: Unable to get external storage directory.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

/*Container(
                  height: height / height65,
                  color: WidgetColor,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPaused = !isPaused;
                      });
                      if (isPaused) {
                        fireStoreService.BreakShiftLog(widget.EmployeIad);
                      } else {
                        fireStoreService.ResumeShiftLog(widget.EmployeId);
                      }
                    },
                    child: InterBold(
                      text: isPaused ? 'Resume' : 'Break',
                      fontsize: width / width18,
                      color: Primarycolor,
                    ),
                  ),
                )*/

/*() {
                      setState(() {
                        isPaused = !isPaused;
                      });
                      if (isPaused) {
                        fireStoreService.BreakShiftLog(widget.EmployeId);
                      } else {
                        fireStoreService.ResumeShiftLog(widget.EmployeId);
                      }
                    }*/
}
