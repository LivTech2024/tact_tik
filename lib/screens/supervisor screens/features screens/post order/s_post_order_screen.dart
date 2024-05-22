import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/poppins_medium.dart';
import 'package:tact_tik/fonts/poppins_regular.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/post%20order/create_post_order.dart';
// import 'package:workmanager/workmanager.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/post_order.dart/view_post_order.dart';

class SPostOrder extends StatelessWidget {
  const SPostOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateSPostOrder(
                  isDisplay: false,
                ),
              ),
            );
          },
          backgroundColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
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
                color: isDark? DarkColor.color1 : LightColor.color3,
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
                            isDisplay: false,
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
                          color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InterSemibold(
                              text: 'Supervisor Name here',
                              fontsize: width / width20,
                              color: isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.color3,
                            ),
                            SizedBox(
                              height: height / height20,
                            ),
                            InterBold(
                              text: 'Title Here',
                              color: isDark
                                  ? DarkColor.color2
                                  : LightColor.color3,
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
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
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
                                        color: isDark
                                            ? DarkColor.color15
                                            : LightColor.color1,
                                      ),
                                      PoppinsRegular(
                                        text: '329 KB',
                                        color: isDark
                                            ? DarkColor.color16
                                            : LightColor.color1,
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
