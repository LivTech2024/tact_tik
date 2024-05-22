import 'package:flutter/material.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SKeyManagementViewScreen extends StatelessWidget {
  const SKeyManagementViewScreen({super.key});

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
        backgroundColor: DarkColor.Secondarycolor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => (),
            //     ));
          },
          backgroundColor: DarkColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add , size: width / width24,),
        ),
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
                  print("Navigator debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Assets',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              centerTitle: true,
              floating: true,
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
                      color: DarkColor. Primarycolor,
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
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: GestureDetector(
                      onTap: (){
                        /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewAssetsScreen()));*/
                      },
                      child: Container(
                        height: width / width60,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: height / height10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width / width10),
                          color: DarkColor. WidgetColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: height / height44,
                                  width: width / width44,
                                  padding: EdgeInsets.symmetric(horizontal: width / width10),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(width / width10),
                                    color: DarkColor. Primarycolorlight,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.home_repair_service,
                                      color: DarkColor. Primarycolor,
                                      size: width / width24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: width / width20),
                                InterMedium(
                                  text: 'Equipment Title',
                                  fontsize: width / width16,
                                  color: DarkColor.color1,
                                ),
                              ],
                            ),
                            InterMedium(
                              text: '11 : 36 pm',
                              color: DarkColor. color17,
                              fontsize: width / width16,
                            ),
                            SizedBox(width: width / width20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
