import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
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
              text: 'LogBook',
              fontsize: width / width18,
              color: Colors.white,
              letterSpacing: -.3,
            ),
            centerTitle: true,
            floating: true, // Makes the app bar float above the content
          ),
          StreamBuilder<QuerySnapshot>(
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
                return SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final logBookDocs = snapshot.data!.docs;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final logBookId = logBookDocs[index].id;
                    final logData =
                        logBookDocs[index].data() as Map<String, dynamic>;
                    return LogBookWidget(
                      logBookId: logBookId,
                      log: Logs.fromDocument(logData),
                    );
                  },
                  childCount: logBookDocs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LogBookWidget extends StatefulWidget {
  final String logBookId;
  final Logs log;

  const LogBookWidget({
    super.key,
    required this.logBookId,
    required this.log,
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
                    text: widget.log.time,
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
          Visibility(
            visible: expand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LogTypeWidget(
                    time: LogBookEnum.CheckPoint,
                    clientName: widget.log.clientName,
                    location: widget.log.location,
                    logtype: widget.log.logtype),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Logs {
  final String time;
  final String location;
  final String clientName;
  final String timeStamp;
  final String logtype;

  Logs(
      {required this.time,
      required this.clientName,
      required this.location,
      required this.timeStamp,
      required this.logtype});
  factory Logs.fromDocument(Map<String, dynamic> data) {
    Timestamp timestamp = data['LogBookTimeStamp'];

    DateTime dateTime = timestamp.toDate();

    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);

    return Logs(
        time: formattedDate,
        location: data['LogBookLocation'] ?? '',
        clientName: data['LogbookEmployeeName'] ?? '',
        timeStamp: formattedDate,
        logtype: data['LogBookType']);
  }
}
