import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:workmanager/workmanager.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';
import '../../supervisor screens/features screens/create_post_order_screen.dart';
import 'view_post_order.dart';

class PostOrder extends StatelessWidget {
  const PostOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => CreatePostOrder(
        //           isDisplay: false,
        //         ),
        //       ),
        //     );
        //   },
        //   backgroundColor: Primarycolor,
        //   shape: const CircleBorder(),
        //   child: const Icon(Icons.add),
        // ),
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
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePostOrder(
                            isDisplay: true,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: height / height250,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: width / width20,
                          vertical: height / height10,
                        ),
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: height / height10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width / width10),
                          color: WidgetColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Container(
                              width: width / width200,
                              height: height / height46,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(width / width10),
                                color: color1,
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width / width6),
                                    child: SvgPicture.asset(
                                        'assets/images/pdf.svg',
                                        width: width / width32),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      PoppinsMedium(
                                        text: 'PDFNAME.pdf',
                                        color: color15,
                                      ),
                                      PoppinsRegular(
                                        text: '329 KB',
                                        color: color16,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height / height20,
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              // Add this line
                              physics: NeverScrollableScrollPhysics(),
                              // Add this line
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                // Number of columns in the grid
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                              ),

                              // Don't Update the count there will be only 3 photos display hear or less then that.
                              itemCount: 3,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  height: height / height20,
                                  width: width / width20,
                                  child: Image.network(
                                      'https://cdn-images-1.medium.com/v2/resize:fit:1200/1*5-aoK8IBmXve5whBQM90GA.png'),
                                );
                              },
                            ),
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
