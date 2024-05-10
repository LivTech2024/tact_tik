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
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/riverpod/task_screen_provider.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/eg_patrolling.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/screens/home%20screens/shift_return_task_screen.dart';
import 'package:tact_tik/screens/home%20screens/wellness_check_screen.dart';
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
    required this.onRefresh, //refresh the homescreen

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
  void send_mail_onOut(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //fetch all the patrol ids assigned to him using
    List<String> emails = [];
    var ClientEmail =
        await fireStoreService.getClientEmail(widget.ShiftClientID);
    var AdminEmail =
        await fireStoreService.getAdminEmail(widget.ShiftCompanyId);
    var TestinEmail = "pankaj.kumar1312@yahoo.com";
    var defaultEmail = "tacttikofficial@gmail.com";
    var ClientName = await fireStoreService.getClientName(widget.ShiftClientID);
    // emails.add(ClientEmail!);
    // emails.add("sutarvaibhav37@student.sfit.ac.in");
    emails.add("sutarvaibhav37@gmail.com");
    var testEmail3 = "sales@tpssolution.com";
    // var testEmail5 = "pankaj.kumar1312@yahoo.com";
    int? savedInTimeMillis = prefs.getInt('InTime');
    DateTime.fromMillisecondsSinceEpoch(savedInTimeMillis!);
    DateTime savedDateTime =
        DateTime.fromMillisecondsSinceEpoch(savedInTimeMillis);
    String formattedDateTime = DateFormat('HH:mm:ss').format(savedDateTime);
    // var testEmail4 = "ys146228@gmail.com";
    // var TestinEmail = "sutarvaibhav37@gmail.com";
    DateFormat dateFormat = DateFormat("HH:mm:ss");
    String formattedStartDate = dateFormat.format(DateTime.now());
    String formattedEndDate = dateFormat.format(DateTime.now());
    String formattedEndTime = dateFormat.format(DateTime.now());
    await fireStoreService.fetchPatrolData(widget.ShiftId, widget.EmployeId);

    if (ClientEmail != null && AdminEmail != null) {
      // emails.add(AdminEmail);
      // emails.add(TestinEmail);
      // emails.add(testEmail3);
      // emails.add(testEmail5);

      await sendShiftEmail(
        ClientName,
        emails,
        'Tacttik Shift Report',
        "Tacttik Shift Report",
        data,
        "Shift",
        widget.ShiftDate,
        widget.EmployeeName,
        widget.ShiftStartTime,
        widget.ShiftEndTime,
        widget.ShiftAddressName,
        "completed",
        formattedDateTime,
        formattedEndTime,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    inTime = DateTime.now();

    initPrefs();
    // initStopwatch();
    // startStopwatch();

    checkWellnessReport(); // Call the wellness check function
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

  Future<void> checkWellnessReport() async {
    print("Company Id ${widget.ShiftCompanyId}");

    final interval =
        await fireStoreService.wellnessFetch(widget.ShiftCompanyId);
    if (interval > 0) {
      Timer.periodic(Duration(minutes: interval), (timer) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Wellness Report',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Please upload your wellness report.',
                style: TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                // TextButton(
                //   child: Text('Close'),
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //   },
                // ),
                TextButton(
                  child: Text('Open'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WellnessCheckScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      });
    }
  }

  // final LocalStorage storage = LocalStorage('ShiftDetails');

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
    String lateTime = ""; // Example start time// Get current time
// Format the current time and start time as strings
    String currentFormattedTime = DateFormat('hh:mm a').format(currentTime);
    String startFormattedTime = DateFormat('hh:mm a')
        .format(DateFormat('HH:mm').parse(widget.ShiftStartTime));
    print("IN Time : ${inTime}");
    print("Elapsed  : ${_elapsedTime}");

    print("Late Time: ${lateTime}");
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
                                text: "",
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
                      // String time =
                      //     isShiftStartTimeWithinRange(widget.ShiftStartTime) ??
                      //         'On time';
                      // setState(() {
                      //   lateTime = time ?? "";
                      // });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await fireStoreService.changePatrolStatus(
                          widget.ShiftId, widget.EmployeId);
                      bool? status =
                          await fireStoreService.checkShiftReturnTaskStatus(
                              widget.EmployeId, widget.ShiftId);
                      var clientName = await fireStoreService
                          .getClientName(widget.ShiftClientID);
                      await fireStoreService.addToLog(
                          'shift_start',
                          widget.ShiftAddressName,
                          clientName ?? "",
                          widget.EmployeId,
                          widget.EmployeeName,
                          widget.ShiftCompanyId,
                          widget.ShiftBranchId,
                          widget.ShiftClientID,
                          widget.ShiftLocationId);
                      setState(() {
                        if (!clickedIn) {
                          clickedIn = true;
                          prefs.setBool('clickedIn', clickedIn);
                          DateTime currentTime = DateTime.now();
                          inTime = currentTime;
                          prefs.setInt(
                              'InTime', currentTime.millisecondsSinceEpoch);
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
                        widget.onRefresh();
                        setState(() {
                          // isPaused = !isPaused;
                          // prefs.setBool("pauseState", isPaused);
                          clickedIn = false;
                          resetStopwatch();
                          resetClickedState();
                          widget.resetShiftStarted();
                          prefs.setBool('ShiftStarted', false);
                        });
                        var data = await fireStoreService.fetchDataForPdf(
                            widget.EmployeId, widget.ShiftId);

                        send_mail_onOut(data);

                        // showErrorToast(context, "try again");
                        // widget.onRefresh();

                        // Handle the case when data is null

                        var clientName = await fireStoreService
                            .getClientName(widget.ShiftClientID);
                        await fireStoreService.addToLog(
                            'shift_end',
                            widget.ShiftAddressName,
                            clientName ?? "",
                            widget.EmployeId,
                            widget.EmployeeName,
                            widget.ShiftCompanyId,
                            widget.ShiftBranchId,
                            widget.ShiftClientID,
                            widget.ShiftLocationId);
                        await fireStoreService.EndShiftLog(
                            widget.EmployeId,
                            formattedStopwatchTime,
                            widget.ShiftId,
                            widget.ShiftAddressName,
                            widget.ShiftBranchId,
                            widget.ShiftCompanyId,
                            widget.EmployeeName,
                            widget.ShiftClientID);

                        String? ClientName = await fireStoreService
                            .getClientName(widget.ShiftClientID);
                        print("Client Name ${ClientName}");
                        var ClientEmail = fireStoreService
                            .getClientEmail(widget.ShiftClientID);
                        print("Client Name ${ClientEmail}");

                        var AdminEmal = fireStoreService
                            .getAdminEmail(widget.ShiftCompanyId);
                        print("Client Name ${AdminEmal}");
                        widget.onRefresh();
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        }
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
                    print("Fetched Data for generating pdf: ${data}");
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    setState(() {
                      isPaused = !isPaused;
                      onBreak = false;
                      prefs.setBool('pauseState', isPaused);
                    });
                    // isPaused ? stopStopwatch() : startStopwatch();
                    if (isPaused) {
                      var data = await fireStoreService.fetchDataForPdf(
                          widget.EmployeId, widget.ShiftId);
                      var clientName = await fireStoreService
                          .getClientName(widget.ShiftClientID);
                      print("Fetched Data for generating pdf: ${data}");
                      await fireStoreService.addToLog(
                          'shift_break',
                          widget.ShiftAddressName,
                          clientName ?? "",
                          widget.EmployeId,
                          widget.EmployeeName,
                          widget.ShiftCompanyId,
                          widget.ShiftBranchId,
                          widget.ShiftClientID,
                          widget.ShiftLocationId);
                      stopStopwatch();
                      setState(() {
                        onBreak = true;
                        prefs.setBool('onBreak', onBreak);
                      });
                      fireStoreService.BreakShiftLog(widget.EmployeId);
                    } else {
                      onBreak = false;
                      var clientName = await fireStoreService
                          .getClientName(widget.ShiftClientID);
                      await fireStoreService.addToLog(
                          'shift_resume',
                          widget.ShiftAddressName,
                          clientName ?? "",
                          widget.EmployeId,
                          widget.EmployeeName,
                          widget.ShiftCompanyId,
                          widget.ShiftBranchId,
                          widget.ShiftClientID,
                          widget.ShiftLocationId);
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

  Future<void> generateAndOpenPDF(String? clientName, String adminEmail,
      List<Map<String, dynamic>> patrolData) async {
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
                  'Dear $clientName,\n\nI hope this email finds you well. I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during their shift. Below is a detailed breakdown of the patrols conducted:',
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
                      for (var patrol in patrolData)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text("Vaibhav"),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  patrol['PatrolId'] as String? ?? 'N/A'),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  patrol['PatrolLogPatrolCount'] as String? ??
                                      'N/A'),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(patrol['PatrolLogFeedbackComment']
                                      as String? ??
                                  'N/A'),
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
