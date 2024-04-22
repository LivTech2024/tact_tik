import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/visitors/create_visitors.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class VisiTorsScreen extends StatelessWidget {
  const VisiTorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateVisitors(),
                ));
          },
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: CustomScrollView(
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
                text: 'Visitors',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height / height30,
                    ),
                    InterBold(
                      text: 'Today',
                      fontsize: width / width20,
                      color: Primarycolor,
                    ),
                    SizedBox(
                      height: height / height30,
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Patrol p = patrolsData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: Container(
                      height: width / width120,
                      width: double.maxFinite,
                      margin: EdgeInsets.only(bottom: height / height10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width / width10),
                        color: WidgetColor,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width / width10,
                                vertical: height / height10,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: width / width40,
                                    height: height / height40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          width / width10),
                                      color: Primarycolorlight,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/man.svg',
                                        height: height / height20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width / width120,
                                    child: InterMedium(
                                      text: 'Guy Hawkins',
                                      color: color1,
                                      fontsize: width / width16,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          InterBold(
                                            text: 'in time',
                                            fontsize: width / width12,
                                            color: color4,
                                          ),
                                          SizedBox(width: width / width6),
                                          InterMedium(
                                            text: '11 : 36 pm',
                                            fontsize: width / width14,
                                            color: color3,
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          InterBold(
                                            text: 'out time',
                                            fontsize: width / width12,
                                            color: color4,
                                          ),
                                          SizedBox(width: width / width6),
                                          InterMedium(
                                            text: '11 : 36 pm',
                                            fontsize: width / width14,
                                            color: color3,
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: width / width10),
                              decoration: BoxDecoration(
                                color: colorRed,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(width / width10),
                                  bottomRight: Radius.circular(width / width10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InterSemibold(
                                    text: 'Location',
                                    color: color1,
                                    fontsize: width / width14,
                                  ),
                                  SizedBox(
                                    width: width / width200,
                                    child: InterRegular(
                                      text:
                                          '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                                      fontsize: width / width12,
                                      color: color2,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
