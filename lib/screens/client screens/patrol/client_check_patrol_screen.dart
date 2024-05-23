import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import 'client_open_patrol_screen.dart';

class ClientCheckPatrolScreen extends StatelessWidget {
  ClientCheckPatrolScreen({super.key});

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
    // Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
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
                        color: Primarycolor,
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
                        color: Primarycolor,
                        Iconcolor: color1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / height20,
                ),
                GestureDetector(
                  onTap: () {
                    NavigateScreen(ClientOpenPatrolScreen() , context);

                  },
                  child: Container(
                    height: height / height140,
                    margin: EdgeInsets.only(top: height / height10),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: WidgetColor,
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
                                    color: Primarycolor,
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
                                    color: color21,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Started at',
                                      fontsize: width / width12,
                                      color: color21,
                                    ),
                                    SizedBox(height: height / height12),
                                    InterMedium(
                                      text: '11:36',
                                      fontsize: width / width12,
                                      color: color1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width / width80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Ended at',
                                      fontsize: width / width12,
                                      color: color21,
                                    ),
                                    SizedBox(height: height / height12),
                                    InterMedium(
                                      text: '16:56',
                                      fontsize: width / width12,
                                      color: color1,
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
                                      fontsize: width / width12,
                                      color: color21,
                                    ),
                                    SizedBox(height: height / height12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Primarycolor,
                                          size: width / width16,
                                        ),
                                        SizedBox(
                                          width: width / width2,
                                        ),
                                        InterMedium(
                                          text: '100',
                                          fontsize: width / width12,
                                          color: color1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: width / width80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InterRegular(
                                      text: 'Status',
                                      fontsize: width / width12,
                                      color: color21,
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
