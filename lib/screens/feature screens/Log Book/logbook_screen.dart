import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/widget/log_type_widget.dart';

import '../../../common/enums/log_type_enums.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class LogBookScreen extends StatefulWidget {
  const LogBookScreen({super.key});

  @override
  State<LogBookScreen> createState() => _LogBookScreenState();
}

class _LogBookScreenState extends State<LogBookScreen> {
  DateTime _selectedDate = DateTime.now();
  DatePickerController datePickerController = DatePickerController();

  List convertDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return [date.day, date.month, date.year];
  }

  Map<String, dynamic>? fetchLogsByDateAndId(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> logs) {
    for (var log in logs) {
      List date = convertDate(log['LogBookDate'] as Timestamp);
      if (date[0] == _selectedDate.day &&
          date[1] == _selectedDate.month &&
          date[2] == _selectedDate.year &&
          log['LogBookEmpId'] == FirebaseAuth.instance.currentUser!.uid) {
        return log.data();
      }
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      datePickerController.jumpToSelection();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? DarkColor.color1 : LightColor.color3,
                size: width / width24,
              ),
              padding: EdgeInsets.only(left: width / width20),
              onPressed: () {
                Navigator.pop(context);
                print("Navigtor debug: ${Navigator.of(context).toString()}");
              },
            ),
            title: InterRegular(
              text: 'LogBook',
              fontsize: width / width18,
              color: isDark ? DarkColor.color1 : LightColor.color3,
              letterSpacing: -.3,
            ),
            centerTitle: true,
            floating: true, // Makes the app bar float above the content
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: height / height30,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              width: double.infinity,
              child: DatePicker(
                DateTime(2024),
                controller: datePickerController,
                initialSelectedDate: DateTime.now(),
                selectionColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
                selectedTextColor: Colors.white,
                onDateChange: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ),
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('LogBook').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              Map<String, dynamic>? logBookDoc =
                  fetchLogsByDateAndId(snapshot.data!.docs);

              // print(logBookDocs);
              if (logBookDoc == null) {
                print('No data found');
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'No data found!',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else {
                List<dynamic> logs = logBookDoc['LogBookData'];
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    //
                    (context, index) {
                      Map<String, dynamic> logBookId = logs[index];
                      // final logData =
                      //     logBookDocs[index].data() as Map<String, dynamic>;
                      // return LogBookWidget(
                      //   logBookId: logBookId,
                      //   // log: Logs.fromDocument(logData),
                      // );
                      // Logs log = Logs.fromDocument(logBookId);
                      return LogTypeWidget(
                        clientName: logBookDoc['LogBookCleintName'] ?? "",
                        location: logBookDoc['LogBookLocationName'] ?? "",
                        logtype: logBookId['LogType'],
                        logEnum: LogBookEnum.CheckPoint,
                        time: logBookId['LogReportedAt'],
                      );
                    },
                    childCount: logs.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// class LogBookWidget extends StatefulWidget {
//   // final String logBookId;
//   final Logs log;

//   const LogBookWidget({
//     super.key,
//     // required this.logBookId,
//     required this.log,
//   });

//   @override
//   State<LogBookWidget> createState() => _LogBookWidgetState();
// }

// class _LogBookWidgetState extends State<LogBookWidget> {
//   bool expand = false;

//   @override
//   Widget build(BuildContext context) {
//     final double height = MediaQuery.of(context).size.height;
//     final double width = MediaQuery.of(context).size.width;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: width / width30),
//       child:  Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     print('on ckick');
//                     setState(() {
//                       expand = !expand;
//                     });
//                   },
//                   child: Container(
//                     margin: EdgeInsets.only(top: height / height10),
//                     padding: EdgeInsets.symmetric(horizontal: width / width20),
//                     height: height / height70,
//                     width: double.maxFinite,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(width / width10),
//                       color: WidgetColor,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         InterBold(
//                           text: widget.logBookId,
//                           color: Primarycolor,
//                           fontsize: width / width18,
//                         ),
//                         Icon(
//                           expand
//                               ? Icons.arrow_circle_up_outlined
//                               : Icons.arrow_circle_down_outlined,
//                           size: width / width24,
//                           color: Primarycolor,
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Visibility(
//                 //   visible: expand,
//                 //   child: Column(
//                 //     children: List.generate(
//                 //       logs.length,
//                 //       (index) => FirebaseAuth.instance.currentUser!.uid ==
//                 //               logs[index]['LogBookEmployeeId']
//                 //           ? LogTypeWidget(
//                 //               clientName: logs[index]['LogbookEmployeeName'],
//                 //               location: logs[index]['LogBookLocation'],
//                 //               logtype: logs[index]['LogBookType'],
//                 //               time: LogBookEnum.CheckPoint,
//                 //             )
//                 //           : const SizedBox(),
//                 //     ),
//                 //   ),
//                 // ),
//               ],
//             )
//     );
//   }
// }

class Logs {
  final String time;
  final String location;
  final String clientName;
  final String timeStamp;
  final String logtype;

  Logs({
    required this.time,
    required this.clientName,
    required this.location,
    required this.timeStamp,
    required this.logtype,
  });

  factory Logs.fromDocument(Map<String, dynamic>? data) {
    if (data == null) {
      throw Exception('Data is null');
    }

    final String? logBookLocation = data['LogBookLocation'];
    final String? logbookEmployeeName = data['LogbookEmployeeName'];
    final String? logBookType = data['LogBookType'];

    if (logBookLocation == null ||
        logbookEmployeeName == null ||
        logBookType == null) {
      throw Exception('Required data is missing');
    }

    Timestamp timestamp = Timestamp.now();
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    return Logs(
      time: formattedDate,
      location: logBookLocation,
      clientName: logbookEmployeeName,
      timeStamp: formattedDate,
      logtype: logBookType,
    );
  }
}
