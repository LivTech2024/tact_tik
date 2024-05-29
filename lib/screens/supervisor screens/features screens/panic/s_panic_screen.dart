import 'package:flutter/material.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SPanicScreen extends StatelessWidget {
  const SPanicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkColor.Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
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
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Panic',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: height / height30, bottom: height / height26),
                        child: InterBold(
                          text: '23/05/2024',
                          fontsize: width / width18,
                          color: DarkColor. color21,
                        ),
                      ),
                      Column(
                        children: List.generate(10, (index) {
                          return Container(
                            height: height / height60,
                            decoration: BoxDecoration(
                              color: DarkColor. color19,
                              borderRadius:
                                  BorderRadius.circular(width / width12),
                            ),
                            margin: EdgeInsets.only(bottom: height / height10),
                            width: double.maxFinite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: height / height48,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / width20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: height / height50,
                                            width: width / width50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage('url'),
                                                filterQuality:
                                                    FilterQuality.high,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: width / width20),
                                          InterBold(
                                            text: 'Bessie Cooper',
                                            letterSpacing: -.3,
                                            color: DarkColor. color1,
                                          ),
                                        ],
                                      ),
                                      InterMedium(
                                        text: '5:84 pm',
                                        fontsize: width / width16,
                                        color: DarkColor.color1,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  );
                },
                childCount: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
