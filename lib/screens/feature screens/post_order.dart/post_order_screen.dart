import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class PostOrder extends StatelessWidget {
  const PostOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
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
                text: 'Post Order',
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
                  // Patrol p = patrolsData[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / width30,
                        vertical: height / height30),
                    child: Container(
                      height: width / width120,
                      width: double.maxFinite,
                      margin: EdgeInsets.only(bottom: height / height10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width / width10),
                        color: WidgetColor,
                      ),
                      child: Container(
                        height: height / height270,
                        width: double.maxFinite,
                        child: Column(
                          children: [
                            InterSemibold(
                              text: 'Supervisor Name here',
                              fontsize: width / width20,
                              color: Primarycolor,
                            ),
                            SizedBox(
                              height: height / height20,
                            ),
                            InterBold(
                              text: 'Title Here',
                              color: color2,
                              fontsize: width / width14,
                            ),
                            SizedBox(
                              height: height / height16,
                            ),
                            InterRegular(
                              text:
                                  'Post Orders Here\nPost Orders Here\nPost Orders Here\nPost Orders Here..',
                              color: color2,
                              fontsize: width / width14,
                            ),
                            SizedBox(
                              height: height / height20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: height / height80,
                                      width: width / width80,
                                      child: Image.network('https://cdn-images-1.medium.com/v2/resize:fit:1200/1*5-aoK8IBmXve5whBQM90GA.png'),
                                    ),
                                    SizedBox(
                                      height: height / height80,
                                      width: width / width80,
                                      child: Image.network('https://cdn-images-1.medium.com/v2/resize:fit:1200/1*5-aoK8IBmXve5whBQM90GA.png'),
                                    ),
                                  ],
                                ),
                                InterRegular(
                                  text: '12.36pm',
                                  color: color2,
                                  fontsize: width / width14,
                                ),
                              ],
                            )
                          ],
                        ),
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
