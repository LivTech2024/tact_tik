import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/client%20screens/patrol/view_checkpoint_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';

class ClientOpenPatrolScreen extends StatelessWidget {
  final String guardName;
  final String startDate;
  final String startTime;
  final String endTime;
  final int patrolLogCount;
  final String status;
  final String feedback;
  final List<Map<String, dynamic>> checkpoints;
  ClientOpenPatrolScreen(
      {super.key,
      required this.guardName,
      required this.startDate,
      required this.startTime,
      required this.endTime,
      required this.patrolLogCount,
      required this.status,
      required this.feedback,
      required this.checkpoints});

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

  void NavigateScreen(Widget screen, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    // final String guardName = Data['PatrolLogGuardName'] ?? '';
    // final String startDate = Data['PatrolDate'] ?? '';
    // final String startTime = Data['PatrolLogStartedAt'] != null
    //     ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
    //         Data['PatrolLogStartedAt'].millisecondsSinceEpoch))
    //     : "";
    // final String endTime = Data['PatrolLogEndedAt'] != null
    //     ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
    //         Data['PatrolLogEndedAt'].millisecondsSinceEpoch))
    //     : "";
    // final int patrolLogCount = Data['PatrolLogPatrolCount'] ?? 0;
    // final String status = Data['PatrolLogStatus'] ?? 'N/A';
    // final String feedback =
    //     Data['PatrolLogFeedbackComment'] ?? 'No feedback provided';
    // final List<Map<String, dynamic>> checkpoints =
    //     Data['PatrolLogCheckPoints'] ?? [];

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          shadowColor: isDark ? Colors.transparent : LightColor.color3.withOpacity(.1),
          backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
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
            text: guardName,
            fontsize: width / width18,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / width30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: isDark ? DarkColor.Primarycolor : LightColor.color3,
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
                        color: isDark ? DarkColor.Primarycolor : LightColor.color3,
                        Iconcolor: isDark ? DarkColor.color1 : LightColor.color3,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / height20,
                ),
                GestureDetector(
                  onTap: () {
                    // NavigateScreen();
                  },
                  child: Container(
                    height: height / height200,
                    margin: EdgeInsets.only(top: height / height10),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                      borderRadius: BorderRadius.circular(width / width14),
                    ),
                    padding: EdgeInsets.symmetric(vertical: height / height20),
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
                                    color: isDark
                                        ? DarkColor.Primarycolor
                                        : LightColor.Primarycolor,
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
                                    text: 'Guard Name',
                                    color: isDark
                                        ? DarkColor.color1
                                        : LightColor.color3,
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
                                width: width / width100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Started at',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color21
                                          : LightColor.color2,
                                    ),
                                    SizedBox(height: height / height12),
                                    InterMedium(
                                      text: '11:36',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width / width100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Ended at',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color21
                                          : LightColor.color2,
                                    ),
                                    SizedBox(height: height / height12),
                                    InterMedium(
                                      text: '16:56',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width / width60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Count',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color21
                                          : LightColor.color2,
                                    ),
                                    SizedBox(height: height / height12),
                                    InterMedium(
                                      text: '100',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width / width60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Status',
                                      fontsize: width / width14,
                                      color: isDark
                                          ? DarkColor.color21
                                          : LightColor.color2,
                                    ),
                                    SizedBox(height: height / height12),
                                    InterBold(
                                      text: '1/3',
                                      fontsize: width / width14,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height / height14),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: width / width18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterRegular(
                                text: 'Feedback :',
                                color: isDark
                                    ? DarkColor.color21
                                    : LightColor.color2,
                                fontsize: width / width14,
                              ),
                              SizedBox(width: width / width4),
                              Flexible(
                                  child: InterRegular(
                                text:
                                    ' If you have already purchased the premium, please wait a few minutes for the system to update your status and dont forget to run /premium to activate your premium status!',
                                color: isDark
                                    ? DarkColor.color10
                                    : LightColor.color3,
                                fontsize: width / width14,
                                maxLines: 3,
                              )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height / height30),
                InterBold(
                  text: 'Checkpoints',
                  fontsize: width / width18,
                  color: isDark ? DarkColor.color21 : LightColor.color3,
                ),
                SizedBox(height: height / height20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        NavigateScreen(ViewCheckpointScreen(), context);
                      },
                      child: Container(
                        height: height / height50,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: height / height10),
                        decoration: BoxDecoration(
                          color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                          borderRadius: BorderRadius.circular(width / width10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: width / width20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: height / height12,
                                  width: width / width12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: width / width10),
                                SizedBox(
                                  width: width / width120,
                                  child: InterMedium(
                                    text: 'Checkpoint name Checkpoint name..',
                                    color: isDark
                                        ? DarkColor.color21
                                        : LightColor.color2,
                                    fontsize: width / width16,
                                  ),
                                )
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: width / width24,
                              color:  DarkColor.color17 ,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
