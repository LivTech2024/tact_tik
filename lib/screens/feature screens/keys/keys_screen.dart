import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/assets/view_assets_screen.dart';
import 'package:tact_tik/screens/feature%20screens/keys/view_keys_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class KeysScreen extends StatelessWidget {
  const KeysScreen({super.key});

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
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 5,
              shadowColor: isDark ? DarkColor.color1 : LightColor.color3.withOpacity(.1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigator debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Keys',
                fontsize: width / width18,
                color: isDark ? DarkColor.color1 : LightColor.color3,
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
                      color: isDark
                          ? DarkColor.Primarycolor
                          : LightColor.color3,
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
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewKeysScreen()));
                      },
                      child: Container(
                        height: width / width60,
                        padding:
                        EdgeInsets.symmetric(horizontal: width / width10),
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: height / height10),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.transparent
                                  : LightColor.color3.withOpacity(.05),
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: Offset(0, 3),
                            )
                          ],
                          borderRadius: BorderRadius.circular(width / width10),
                          color: isDark
                              ? DarkColor.WidgetColor
                              : LightColor.WidgetColor,
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
                                  decoration: BoxDecoration(

                                    borderRadius:
                                    BorderRadius.circular(width / width10),
                                    color: isDark
                                        ? DarkColor.Primarycolorlight
                                        : LightColor.Primarycolorlight,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.home_repair_service,
                                      color: isDark
                                          ? DarkColor.Primarycolor
                                          : LightColor.Primarycolor,
                                      size: width / width24,
                                    ),
                                  ),
                                ),
                                SizedBox(width: width / width20),
                                InterMedium(
                                  text: 'Equipment Title',
                                  fontsize: width / width16,
                                  color: isDark
                                      ? DarkColor. color1
                                      : LightColor.color3,
                                ),
                              ],
                            ),
                            InterMedium(
                              text: '11 : 36 pm',
                              color: isDark
                                  ? DarkColor.color17
                                  : LightColor.color2,
                              fontsize: width / width16,
                            ),
                            // SizedBox(width: width / width10),
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
