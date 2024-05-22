import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tact_tik/common/widgets/customErrorToast.dart';
import 'package:tact_tik/screens/home%20screens/home_screen.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';
import 'package:toastification/toastification.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/button1.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class EndCheckpointScreen extends StatefulWidget {
  final String EmpId;
  final String PatrolID;
  final String ShiftId;
  final String EmpName;
  final int CompletedCount;
  final int PatrolRequiredCount;
  final String PatrolCompanyID;
  final String PatrolClientID;
  final String LocationId;
  final String ShiftName;
  final String description;

//  widget.PatrolCompanyID,
//                               "",
//                               widget.PatrolClientID,
//                               widget.LocationId,
//                               widget.ShiftName
  //  widget.p.PatrolId,
  //                             widget.p.EmpId,
  //                             widget.p.ShiftId

  const EndCheckpointScreen({
    super.key,
    required this.EmpId,
    required this.PatrolID,
    required this.ShiftId,
    required this.EmpName,
    required this.CompletedCount,
    required this.PatrolRequiredCount,
    required this.PatrolCompanyID,
    required this.PatrolClientID,
    required this.LocationId,
    required this.ShiftName,
    required this.description,
  });

  @override
  State<EndCheckpointScreen> createState() => _ReportCheckpointScreenState();
}

FireStoreService fireStoreService = FireStoreService();

class _ReportCheckpointScreenState extends State<EndCheckpointScreen> {
  bool _expand = false;
  late Map<String, bool> _expandCategoryMap;
  TextEditingController Controller = TextEditingController();
  bool _isLoading = false;
  String selectedOption = 'Normal';
  bool buttonEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadShiftStartedState();
    // // Initialize expand state for each category
    // _expandCategoryMap = Map.fromIterable(widget.p.categories,
    //     key: (category) => category.title, value: (_) => false);
  }

  void _loadShiftStartedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _expand = prefs.getBool('expand') ?? false;
    });
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
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'End Patrol',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height / height30),
                    Text(
                      'Add Note',
                      style: TextStyle(
                        fontSize: width / width14,
                        color: Primarycolor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: height / height10),
                    Row(
                      children: [
                        Radio(
                          activeColor: Primarycolor,
                          value: 'Emergency',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                        InterRegular(
                          text: 'Emergency',
                          fontsize: width / width16,
                          color: color1,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: Primarycolor,
                          value: 'Normal',
                          groupValue: selectedOption,
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                            });
                          },
                        ),
                        InterRegular(
                          text: 'Normal',
                          fontsize: width / width16,
                          color: color1,
                        )
                      ],
                    ),
                    SizedBox(height: height / height10),
                    TextField(
                      controller: Controller,
                      decoration: InputDecoration(
                        hintText: 'Add Comment',
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: height / height100)
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Primarycolor,
                    ),
                  ),
                ),
              Align(
                // bottom: 10,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Button1(
                      text: 'Submit',
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        if (widget.CompletedCount ==
                            widget.PatrolRequiredCount - 1) {
                          String? InTime = prefs.getString("StartTime");
                          DateTime now = DateTime.now();
                          DateTime inTime =
                              DateFormat("HH:mm").parse(InTime ?? "");
                          DateTime combinedDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              inTime.hour,
                              inTime.minute,
                              inTime.second);
                          Timestamp patrolInTimestamp =
                              Timestamp.fromMillisecondsSinceEpoch(
                                  combinedDateTime.millisecondsSinceEpoch);

                          print("patrolIn time: ${patrolInTimestamp}");

                          DateFormat dateFormat =
                              DateFormat("yyyy-MM-dd HH:mm:ss");
                          String formattedEndDate =
                              dateFormat.format(DateTime.now());
                          Timestamp patrolOutTimestamp =
                              Timestamp.fromDate(DateTime.now());
                          String formattedStartDate =
                              dateFormat.format(DateTime.now());
                          String formattedEndTime =
                              dateFormat.format(DateTime.now());
                          DateFormat timeformat = DateFormat(
                              "HH:mm:ss"); // Define the format for time
                          // String formattedPatrolInTime =
                          //     timeformat.format(StartTime);
                          String formattedPatrolOutTime =
                              timeformat.format(DateTime.now());
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          await fireStoreService.fetchAndCreatePatrolLogs(
                              widget.PatrolID,
                              widget.EmpId,
                              widget.EmpName,
                              widget.CompletedCount + 1,
                              formattedStartDate,
                              patrolInTimestamp,
                              patrolOutTimestamp,
                              Controller.text,
                              widget.ShiftId);
                          print("Patrol count == Required COunt");
                          setState(() {
                            _expand = false;

                            prefs.setBool("expand", _expand);
                          });
                          //If the count is equal
                          var imageUrls =
                              await fireStoreService.getImageUrlsForPatrol(
                                  widget.PatrolID,
                                  widget.EmpId,
                                  widget.ShiftId);

                          print(imageUrls);
                          List<Map<String, dynamic>> formattedImageUrls =
                              imageUrls.map((url) {
                            return {
                              'StatusReportedTime': url['StatusReportedTime'],
                              'ImageUrls': url['ImageUrls'],
                              'StatusComment': url['StatusComment'],
                              'CheckPointName': url['CheckPointName'],
                              'CheckPointStatus': url['CheckPointStatus']
                            };
                          }).toList();
                          await fireStoreService
                              .LastEndPatrolupdatePatrolsStatus(widget.PatrolID,
                                  widget.EmpId, widget.EmpName, widget.ShiftId);
                          List<String> emails = [];
                          var ClientEmail = await fireStoreService
                              .getClientPatrolEmail(widget.PatrolClientID);
                          var AdminEmail = await fireStoreService
                              .getAdminEmail(widget.PatrolCompanyID);

                          var TestinEmail = "sutarvaibhav37@gmail.com";
                          var defaultEmail = "tacttikofficial@gmail.com";
                          var testEmail3 = "Swastikbthiramdas@gmail.com";
                          emails.add(TestinEmail);
                          // emails.add(testEmail3);
                          // emails.add(testEmail3);
                          emails.add(ClientEmail!);
                          emails.add(AdminEmail!);
                          emails.add(defaultEmail!);
                          DateFormat timeFormat = DateFormat("HH:mm");

                          //         DateTime.now());
                          num count = widget.CompletedCount + 1;
                          var clientName = await fireStoreService
                              .getClientName(widget.PatrolClientID);
                          await fireStoreService.addToLog(
                              "patrol_end",
                              "",
                              clientName ?? "",
                              widget.EmpId,
                              widget.EmpName,
                              widget.PatrolCompanyID,
                              "",
                              widget.PatrolClientID,
                              widget.LocationId,
                              widget.ShiftName);
                          sendapiEmail(
                              emails,
                              selectedOption == "Emergency"
                                  ? "Urgent Update for ${widget.description} Date:- ${formattedStartDate} "
                                  : "Patrol update for ${widget.description} Date:- ${formattedStartDate}",
                              widget.EmpName,
                              "",
                              'Shift ',
                              formattedStartDate,
                              formattedImageUrls,
                              widget.EmpName,
                              InTime,
                              formattedEndTime,
                              widget.CompletedCount + 1,
                              widget.PatrolRequiredCount.toString(),
                              widget.description,
                              "Completed",
                              InTime,
                              formattedPatrolOutTime,
                              Controller.text,
                              selectedOption);
                          // _refresh();
                          // sendFormattedEmail(emailParams);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          String? InTime = prefs.getString("StartTime");
                          DateTime now = DateTime.now();
                          DateTime inTime =
                              DateFormat("HH:mm").parse(InTime ?? "");
                          DateTime combinedDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              inTime.hour,
                              inTime.minute,
                              inTime.second);
                          Timestamp patrolInTimestamp =
                              Timestamp.fromMillisecondsSinceEpoch(
                                  combinedDateTime.millisecondsSinceEpoch);

                          print("patrolIn time: ${patrolInTimestamp}");

                          DateFormat dateFormat =
                              DateFormat("yyyy-MM-dd HH:mm:ss");
                          String formattedEndDate =
                              dateFormat.format(DateTime.now());
                          Timestamp patrolOutTimestamp =
                              Timestamp.fromDate(DateTime.now());
                          String formattedStartDate =
                              dateFormat.format(DateTime.now());
                          String formattedEndTime =
                              dateFormat.format(DateTime.now());
                          DateFormat timeformat = DateFormat(
                              "HH:mm:ss"); // Define the format for time
                          // String formattedPatrolInTime =
                          //     timeformat.format(StartTime);
                          String formattedPatrolOutTime =
                              timeformat.format(DateTime.now());
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          await fireStoreService.fetchAndCreatePatrolLogs(
                              widget.PatrolID,
                              widget.EmpId,
                              widget.EmpName,
                              widget.CompletedCount + 1,
                              formattedStartDate,
                              patrolInTimestamp,
                              patrolOutTimestamp,
                              Controller.text,
                              widget.ShiftId);
                          //if normal update
                          setState(() {
                            _expand = false;
                            buttonEnabled = false;

                            prefs.setBool("expand", _expand);
                          });
                          var imageUrls =
                              await fireStoreService.getImageUrlsForPatrol(
                                  widget.PatrolID,
                                  widget.EmpId,
                                  widget.ShiftId);
                          List<Map<String, dynamic>> formattedImageUrls =
                              imageUrls.map((url) {
                            return {
                              'StatusReportedTime': url['StatusReportedTime'],
                              'ImageUrls': url['ImageUrls'],
                              'StatusComment': url['StatusComment'],
                              'CheckPointName': url['CheckPointName'],
                              'CheckPointStatus': url['CheckPointStatus']
                            };
                          }).toList();
                          await fireStoreService.EndPatrolupdatePatrolsStatus(
                              widget.PatrolID,
                              widget.EmpId,
                              widget.EmpName,
                              widget.ShiftId);

                          List<String> emails = [];
                          var ClientEmail = await fireStoreService
                              .getClientEmail(widget.PatrolClientID);
                          var AdminEmail = await fireStoreService
                              .getAdminEmail(widget.PatrolCompanyID);

                          print(imageUrls);
                          var TestinEmail = "sutarvaibhav37@gmail.com";
                          var defaultEmail = "tacttikofficial@gmail.com";
                          // var defaultEmail = "tacttikofficial@gmail.com";
                          var testEmail3 = "Swastikbthiramdas@gmail.com";
                          emails.add(TestinEmail);
                          emails.add(testEmail3);

                          emails.add(ClientEmail!);
                          emails.add(AdminEmail!);
                          emails.add(defaultEmail!);
                          // var clientId = await fireStoreService
                          //     .getShiftClientID(
                          //         widget.p.ShiftId);
                          var clientName = await fireStoreService
                              .getClientName(widget.PatrolClientID);
                          await fireStoreService.addToLog(
                              "patrol_end",
                              "",
                              clientName ?? "",
                              widget.EmpId,
                              widget.EmpName,
                              widget.PatrolCompanyID,
                              "",
                              widget.PatrolClientID,
                              widget.LocationId,
                              widget.ShiftName);
                          num newCount = widget.CompletedCount;
                          sendapiEmail(
                              emails,
                              selectedOption == "Emergency"
                                  ? "Urgent Update for ${widget.description} Date:- ${formattedStartDate} "
                                  : "Patrol update for ${widget.description} Date:- ${formattedStartDate}",
                              widget.EmpName,
                              "",
                              'Shift ',
                              formattedStartDate,
                              formattedImageUrls,
                              widget.EmpName,
                              InTime,
                              formattedEndTime,
                              widget.CompletedCount + 1,
                              widget.PatrolRequiredCount.toString(),
                              widget.description,
                              "Completed",
                              InTime,
                              formattedPatrolOutTime,
                              Controller.text,
                              selectedOption);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()));
                        }
                      },
                      color: Colors.white,
                      borderRadius: width / width20,
                      backgroundcolor: Primarycolor,
                    ),
                    SizedBox(
                      height: height / height20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
