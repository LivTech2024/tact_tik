import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../fonts/inter_regular.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          // physics: const PageScrollPhysics(),
          slivers: [
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
                text: 'My History',
                fontsize: width / width18,
                color: Colors.white,
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(left: width / width30 , right: width / width30 , bottom: height / height40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Yesterday',
                          fontsize: width / width18,
                          color: color1,
                        ),
                        SizedBox(height: height / height20),
                        Container(
                          height: height / height340,
                          padding: EdgeInsets.only(
                              top: height / height20,),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(width / width10),
                            color: WidgetColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Shift Name',
                                      fontsize: width / width16,
                                      color: color1,
                                    ),
                                    SizedBox(width: width / width40),
                                    Flexible(
                                      child: InterSemibold(
                                        text: 'Holi Shift',
                                        fontsize: width / width16,
                                        color: color1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height / height10,),
                              Container(
                                height: height / height100,
                                color: colorRed,
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InterSemibold(
                                      text: 'Location',
                                      fontsize: width / width16,
                                      color: color1,
                                    ),
                                    SizedBox(width: width / width40),
                                    Flexible(
                                      child: InterSemibold(
                                        text:
                                            '521 Despard Street Atlanta, GA 30329',
                                        fontsize: width / width16,
                                        color: color1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height / height30),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width / width20),
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterSemibold(
                                          text: 'Shift Timimg',
                                          fontsize: width / width16,
                                          color: color1,
                                        ),
                                        SizedBox(
                                          height: height / height20,
                                        ),
                                        InterSemibold(
                                          text: '12:00pm to 4:30pm',
                                          fontsize: width / width16,
                                          color: color1,
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: height / height20),
                                    SizedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterSemibold(
                                            text: 'Total',
                                            fontsize: width / width16,
                                            color: color1,
                                          ),
                                          SizedBox(
                                            height: height / height20,
                                          ),
                                          InterSemibold(
                                            text: '02hr 36min',
                                            fontsize: width / width16,
                                            color: color1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: height / height20,),
                              Button1(
                                text: 'text',
                                useWidget: true,
                                MyWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_for_offline,
                                      color: color1,
                                      size: width / width24,
                                    ),
                                    SizedBox(
                                      width: width / width10,
                                    ),
                                    InterSemibold(
                                      text: 'Download',
                                      color: color1,
                                      fontsize: width / width16,
                                    )
                                  ],
                                ),
                                onPressed: () {},
                                backgroundcolor: Primarycolorlight,
                                useBorderRadius: true,
                                MyBorderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(width / width12),
                                  bottomRight: Radius.circular(width / width12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} /**/
