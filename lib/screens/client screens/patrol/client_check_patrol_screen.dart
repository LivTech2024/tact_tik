import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/feature%20screens/petroling/patrolling.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import 'client_open_patrol_screen.dart';

class ClientCheckPatrolScreen extends StatefulWidget {
  final String PatrolIdl;
  ClientCheckPatrolScreen({super.key, required this.PatrolIdl});

  @override
  State<ClientCheckPatrolScreen> createState() =>
      _ClientCheckPatrolScreenState();
}

class _ClientCheckPatrolScreenState extends State<ClientCheckPatrolScreen> {
  void NavigateScreen(Widget screen, BuildContext context) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  List<Map<String, dynamic>> patrolsList = [];
  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];
  @override
  void initState() {
    FireStoreService fireStoreService = FireStoreService();
    // TODO: implement initState
    super.initState();
    get_PatrolInfo();
  }

  void get_PatrolInfo() async {
    var PatrologsData = await fireStoreService.getPatrolsLogs(widget.PatrolIdl);
    if (PatrologsData != null || PatrologsData.isNotEmpty) {
      setState(() {
        patrolsList = PatrologsData;
      });
    }
    print(PatrologsData);
    try {} catch (error) {
      print("Error ${error}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkColor. Secondarycolor,
        appBar: AppBar(
          backgroundColor: DarkColor. AppBarcolor,
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
            text: 'Guards',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: height / height30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: width / width190,
                      child: IconTextWidget(
                        icon: Icons.calendar_today,
                        text: '23 / 04 / 2024',
                        fontsize: width / width14,
                        color: DarkColor.Primarycolor,
                      ),
                    ),
                    SizedBox(
                      width: width / width140,
                      child: IconTextWidget(
                        space: width / width6,
                        icon: Icons.add,
                        iconSize: width / width20,
                        text: 'Select Guard',
                        useBold: true,
                        fontsize: width / width14,
                        color: DarkColor.Primarycolor,
                        Iconcolor: DarkColor. color1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / height20,
                ),
                for (var patrol in patrolsList)
                  GestureDetector(
                    onTap: () {
                      NavigateScreen(
                          ClientOpenPatrolScreen(
                            guardName: patrol[''],
                            startDate: '',
                            startTime: '',
                            endTime: '',
                            patrolLogCount: 0,
                            status: '',
                            feedback: '',
                            checkpoints: [],
                          ),
                          context);
                    },
                    child: Container(
                      height: height / height140,
                      margin: EdgeInsets.only(top: height / height10),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: DarkColor.WidgetColor,
                        borderRadius: BorderRadius.circular(width / width14),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: height / height20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  SizedBox(height: height / height5),
                                  Container(
                                    height: height / height30,
                                    width: width / width4,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight:
                                            Radius.circular(width / width10),
                                        bottomRight:
                                            Radius.circular(width / width10),
                                      ),
                                      color: DarkColor. Primarycolor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: width / width14),
                              SizedBox(
                                width: width / width190,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: patrol['PatrolLogGuardName'] ?? "",
                                      color: DarkColor. color21,
                                      fontsize: width / width18,
                                    ),
                                    // SizedBox(height: height / height5),
                                  ],
                                ),
                              )
                            ],
                          ),
                          // SizedBox(height: height / height10),
                          Padding(
                            padding: EdgeInsets.only(
                              left: width / width18,
                              right: width / width24,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: width / width80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Started at',
                                        fontsize: width / width12,
                                        color: DarkColor. color21,
                                      ),
                                      SizedBox(height: height / height12),
                                      InterMedium(
                                        text: patrol['PatrolLogStartedAt'] !=
                                                null
                                            ? DateFormat('hh:mm a').format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    patrol['PatrolLogStartedAt']
                                                        .millisecondsSinceEpoch))
                                            : "",
                                        fontsize: width / width12,
                                        color: DarkColor. color1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: width / width80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Ended at',
                                        fontsize: width / width12,
                                        color: DarkColor.color21,
                                      ),
                                      SizedBox(height: height / height12),
                                      InterMedium(
                                        text: patrol['PatrolLogEndedAt'] != null
                                            ? DateFormat('hh:mm a').format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    patrol['PatrolLogEndedAt']
                                                        .millisecondsSinceEpoch))
                                            : "",
                                        fontsize: width / width12,
                                        color: DarkColor.color1,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: width / width60,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Count',
                                        fontsize: width / width12,
                                        color: DarkColor.color21,
                                      ),
                                      SizedBox(height: height / height12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: DarkColor. Primarycolor,
                                            size: width / width16,
                                          ),
                                          SizedBox(
                                            width: width / width2,
                                          ),
                                          InterMedium(
                                            text: patrol['PatrolLogPatrolCount']
                                                    .toString() ??
                                                "",
                                            fontsize: width / width12,
                                            color: DarkColor.color1,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: width / width80,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterRegular(
                                        text: 'Status',
                                        fontsize: width / width12,
                                        color: DarkColor.color21,
                                      ),
                                      SizedBox(height: height / height12),
                                      InterBold(
                                        text: 'Completed',
                                        fontsize: width / width12,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
