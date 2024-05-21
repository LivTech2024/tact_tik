import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';

class ClientOpenPatrolScreen extends StatelessWidget {
  ClientOpenPatrolScreen({super.key});

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
  Widget build(BuildContext context) {
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;

    return SafeArea(
      child: Scaffold(
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
                        color: DarkColor. Primarycolor,
                      ),
                    ),
                    SizedBox(
                      width: width / width140,
                      child: IconTextWidget(
                        icon: Icons.add,
                        text: 'Select Guard',
                        useBold: true,
                        fontsize: width / width14,
                        color: DarkColor. Primarycolor,
                        Iconcolor: DarkColor. color1,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / height20,
                ),
                Container(
                  height: 1800,
                  margin: EdgeInsets.only(top: height / height10),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: DarkColor. color30,
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
                                    topRight: Radius.circular(width / width10),
                                    bottomRight:
                                    Radius.circular(width / width10),
                                  ),
                                  color: DarkColor.color22,
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
                                  color: DarkColor.color22,
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
                                    color: DarkColor. color22,
                                  ),
                                  SizedBox(height: height / height12),
                                  InterMedium(
                                    text: '11:36',
                                    fontsize: width / width14,
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
                                    color: DarkColor.color22,
                                  ),
                                  SizedBox(height: height / height12),
                                  InterMedium(
                                    text: '16:56',
                                    fontsize: width / width14,
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
                                    color: DarkColor.color22,
                                  ),
                                  SizedBox(height: height / height12),
                                  InterMedium(
                                    text: '100',
                                    fontsize: width / width14,
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
                                    color: DarkColor. color22,
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
                      )
                    ],
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
