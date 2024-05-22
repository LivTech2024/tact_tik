import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/widget/log_type_widget.dart';

import '../../../../common/enums/log_type_enums.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../services/EmailService/EmailJs_fucntion.dart';
import '../../../../utils/colors.dart';

class SLogBookScreen extends StatefulWidget {
  final String empId;
  final String empName;

  const SLogBookScreen({super.key, required this.empId, required this.empName});

  @override
  State<SLogBookScreen> createState() => _LogBookScreenState();
}

class _LogBookScreenState extends State<SLogBookScreen> {
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
        .where('LogBookEmpId', isEqualTo: widget.empId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: height / height30,
            ),
          ),
          SliverAppBar(
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
                print("Navigtor debug: ${Navigator.of(context).toString()}");
              },
            ),
            title: InterRegular(
              text: 'LogBook -  ${widget.empName}',
              fontsize: width / width18,
              color: Colors.white,
              letterSpacing: -.3,
            ),
            centerTitle: true,
            floating: true, // Makes the app bar float above the content
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
                  child: CircularProgressIndicator(),
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
      final shiftName = data['ShiftName'] ??
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

        if (logsByDate.containsKey(date)) {
          logsByDate[date]!.add({
            'CLIENTNAME': clientName,
            'LOCATION': logLocation,
            'LOGTYPE': logType,
            'LOGTIMESTAMP': logTimestamp,
          });
        } else {
          logsByDate[date] = [
            {
              'CLIENTNAME': clientName,
              'LOCATION': logLocation,
              'LOGTYPE': logType,
              'LOGTIMESTAMP': logTimestamp,
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / width30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expand = !expand;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: height / height10),
              padding: EdgeInsets.symmetric(horizontal: width / width20),
              height: height / height70,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width / width10),
                color: WidgetColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InterBold(
                    text: widget.date,
                    color: Primarycolor,
                    fontsize: width / width18,
                  ),
                  Icon(
                    expand
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined,
                    size: width / width24,
                    color: Primarycolor,
                  )
                ],
              ),
            ),
          ),
          if (expand)
            Padding(
              padding: EdgeInsets.symmetric(vertical: height / height10),
              child: Flexible(
                child: InterBold(
                  text: widget.shiftName,
                  fontsize: width / width18,
                  color: Primarycolor,
                ),
              ),
            ),
          Visibility(
            visible: expand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.logs.map((log) {
                final logTimestamp = log['LOGTIMESTAMP'] as Timestamp;
                final dateTime = logTimestamp.toDate();
                final formattedDateTime =
                    DateFormat('hh:mm:ss a').format(dateTime);
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
