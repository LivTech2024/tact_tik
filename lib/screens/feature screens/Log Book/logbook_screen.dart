import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/widget/log_type_widget.dart';
import '../../../common/enums/log_type_enums.dart';
import '../../../fonts/inter_regular.dart';
import '../../../services/EmailService/EmailJs_fucntion.dart';
import '../../../utils/colors.dart';

class LogBookScreen extends StatefulWidget {
  final String EmpId;

  const LogBookScreen({super.key, required this.EmpId});

  @override
  State<LogBookScreen> createState() => _LogBookScreenState();
}

class _LogBookScreenState extends State<LogBookScreen> {
  late Stream<QuerySnapshot> _logBookStream;

  // Future<String> getempID() async {
  //   var userInfo = await fireStoreService.getUserInfoByCurrentUserEmail();
  //   if (userInfo != null) {
  //     String employeeId = userInfo['EmployeeId'];
  //     return employeeId;
  //   } else {
  //     print('User info not found');
  //     return "";
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _logBookStream = FirebaseFirestore.instance
        .collection('LogBook')
        .where('LogBookEmpId', isEqualTo: widget.EmpId)
        // .where('LogBookEmpId', isEqualTo: widget.EmpId)
        .snapshots();

    _logBookStream.listen((QuerySnapshot snapshot) {
      print(
          'Snapshot data: ${snapshot.docs.map((doc) => doc.data()).toList()}');
    });
    // getempID().then((empID) {
    //   _logBookStream = FirebaseFirestore.instance
    //       .collection('LogBook')
    //       .where('LogBookEmpId', isEqualTo: empID)
    //       .snapshots();
    // });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppBarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 24.sp,
                ),
                padding: EdgeInsets.only(left: 20.w),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'LogBook',
                fontsize: 18.sp,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30.h,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _logBookStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(child: InterMedium(text: 'Loading...' , color: Primarycolor,fontsize: 18.sp,)),
                  );
                }

                final documents = snapshot.data!.docs;
                final groups = _groupLogsByDate(documents);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = groups.entries.toList()[index];
                      final shiftName = entry.key;
                      final logsByDate = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: logsByDate.entries.map((dateEntry) {
                          final date = dateEntry.key;
                          final logs = dateEntry.value;

                          return LogBookWidget(
                            date: date,
                            shiftName: shiftName,
                            logs: logs,
                          );
                        }).toList(),
                      );
                    },
                    childCount: groups.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, List<Map<String, dynamic>>>> _groupLogsByDate(
      List<QueryDocumentSnapshot> documents) {
    final groups = <String, Map<String, List<Map<String, dynamic>>>>{};

    documents.sort((a, b) {
      final timestampA = a['LogBookDate'] as Timestamp;
      final timestampB = b['LogBookDate'] as Timestamp;
      return timestampB.compareTo(timestampA);
    });

    for (int i = 0; i < documents.length; i++) {
      final document = documents[i];
      final data = document.data() as Map<String, dynamic>;
      final shiftName = data['LogBookShiftName'] ??
          'Shift_$i'; // Use 'Shift_$i' as a unique identifier if ShiftName is absent
      final logData = data['LogBookData'] as List<dynamic>;
      final logTimestamp = data['LogBookDate'] as Timestamp;
      final clientName = data['LogCleintName'] ?? '';
      final logLocation = data['LogBookLocationName'] ?? '';
      final logsByDate = <String, List<Map<String, dynamic>>>{};

      for (final logMap in logData) {
        final logMapData = logMap as Map<String, dynamic>;
        final date = DateFormat('MMM d, yyyy').format(logTimestamp.toDate());

        final logType = logMapData['LogType'];
        final logReportTime = logMapData['LogReportedAt'];

        if (logsByDate.containsKey(date)) {
          logsByDate[date]!.add({
            'CLIENTNAME': clientName,
            'LOCATION': logLocation,
            'LOGTYPE': logType,
            'LOGREPORTTIME': logReportTime,
          });
        } else {
          logsByDate[date] = [
            {
              'CLIENTNAME': clientName,
              'LOCATION': logLocation,
              'LOGTYPE': logType,
              'LOGREPORTTIME': logReportTime,
            }
          ];
        }
      }

      groups[shiftName] = logsByDate;
    }

    return groups;
  }
}

class LogBookWidget extends StatefulWidget {
  final String date;
  final String shiftName;
  final List<Map<String, dynamic>> logs;

  const LogBookWidget({
    super.key,
    required this.date,
    required this.shiftName,
    required this.logs,
  });

  @override
  State<LogBookWidget> createState() => _LogBookWidgetState();
}

class _LogBookWidgetState extends State<LogBookWidget> {
  bool expand = false;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expand = !expand;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              height: 70.h,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: WidgetColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InterBold(
                    text: widget.date,
                    color: Primarycolor,
                    fontsize: 18.sp,
                  ),
                  Icon(
                    expand
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined,
                    size: 24.sp,
                    color: Primarycolor,
                  )
                ],
              ),
            ),
          ),
          if (expand)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              // child: Flexible(
              child: InterBold(
                text: widget.shiftName,
                fontsize: 18.sp,
                color: Primarycolor,
              ),
            ),
          // ),
          Visibility(
            visible: expand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.logs.map((log) {
                final logReportTime = log['LOGREPORTTIME'] as Timestamp;
                final dateTime = logReportTime.toDate();
                final formattedDateTime =
                    DateFormat('hh:mm a').format(dateTime);
                return LogTypeWidget(
                  type: LogBookEnum.values.byName(log['LOGTYPE']),
                  clientname: log['CLIENTNAME'],
                  logtype: log['LOGTYPE'],
                  location: log['LOCATION'],
                  time: formattedDateTime,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Logs {
  final String type;
  final String location;
  final String clintName;

  Logs({
    required this.type,
    required this.clintName,
    required this.location,
  });
}
