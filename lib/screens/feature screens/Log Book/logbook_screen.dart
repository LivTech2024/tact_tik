import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
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

  @override
  void initState() {
    super.initState();
    fetchlog();
  }

  void fetchlog() async {
    try {
      _logBookStream = FirebaseFirestore.instance
          .collection('LogBook')
          .orderBy('LogBookDate', descending: true)
          .where('LogBookEmpId', isEqualTo: widget.EmpId)
          .snapshots();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
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
                text: 'LogBook',
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
                    child: Center(
                        child: InterMedium(
                      text: 'Loading...',
                      color: Theme.of(context).primaryColor,
                      fontsize: 18.sp,
                    )),
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

    for (int i = 0; i < documents.length; i++) {
      final document = documents[i];
      final data = document.data() as Map<String, dynamic>;
      final shiftName = data['ShiftName'] ??
          'Shift_$i'; // Use 'Shift_$i' as a unique identifier if ShiftName is absent
      final logData = data['LogBookData'] as List<dynamic>;
      final logTimestamp = data['LogBookDate'] as Timestamp;
      final clientName = data['LogBookClientName'] ?? '';
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
            'LogBookShiftName': data['LogBookShiftName'] ?? '',
            'LogPatrolName': logMapData['LogPatrolName'] ?? '',
            'LogCheckPointName': logMapData['LogCheckPointName'] ?? '',
          });
        } else {
          logsByDate[date] = [
            {
              'CLIENTNAME': clientName,
              'LOCATION': logLocation,
              'LOGTYPE': logType,
              'LOGREPORTTIME': logReportTime,
              'LogBookShiftName': data['LogBookShiftName'] ?? '',
              'LogPatrolName': logMapData['LogPatrolName'] ?? '',
              'LogCheckPointName': logMapData['LogCheckPointName'] ?? '',
            }
          ];
        }
      }

      logsByDate.forEach((date, logs) {
        logs.sort((a, b) => b['LOGREPORTTIME'].compareTo(a['LOGREPORTTIME']));
      });

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
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
                borderRadius: BorderRadius.circular(10.r),
                color: Theme.of(context).cardColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InterBold(
                    text: widget.date,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                    fontsize: 18.sp,
                  ),
                  Icon(
                    expand
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined,
                    size: 24.sp,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  )
                ],
              ),
            ),
          ),
          if (expand)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: InterBold(
                text: widget.shiftName,
                fontsize: 18.sp,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
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
                  clientname: log['CLIENTNAME'] ?? "",
                  logtype: log['LOGTYPE'],
                  location: log['LOCATION'] ?? "",
                  time: formattedDateTime,
                  shiftName: log['LogBookShiftName'] ?? "",
                  patrolName: log['LogPatrolName'] ?? "",
                  checkPointName: log['LogCheckPointName'] ?? "",
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
