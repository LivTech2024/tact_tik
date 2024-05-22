import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/feature%20screens/task/task_feature_create_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class TaskFeatureScreen extends StatelessWidget {
  const TaskFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFeatureCreateScreen(),
                ));
          },
          backgroundColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: CustomScrollView(
          // physics: const PageScrollPhysics(),
          slivers: [
            SliverAppBar(
              shadowColor: isDark ? DarkColor.color1 : LightColor.color3.withOpacity(.1),
              backgroundColor: isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
              elevation: 10,
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
                text: 'Task',
                fontsize: width / width18,
                color: isDark ? DarkColor.color1 : LightColor.color3,
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
                    padding: EdgeInsets.only(
                        left: width / width30,
                        right: width / width30,
                        bottom: height / height40),
                    child: Container(
                      width: double.maxFinite,
                      constraints: BoxConstraints(
                        minHeight: height / height140,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: width / width14,
                          vertical: height / height10),
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
                        color: isDark
                            ? DarkColor.WidgetColor
                            : LightColor.WidgetColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InterSemibold(
                            text: 'Guard Name',
                            fontsize: width / width20,
                            color: isDark
                                ? DarkColor.Primarycolor
                                : LightColor.color3,
                          ),
                          SizedBox(height: height / height10),
                          InterSemibold(
                            text: 'This tittle is only for eg. to understand',
                            fontsize: width / width20,
                            color: isDark
                                ? DarkColor.color1
                                : LightColor.color3,
                            maxLines: 5,
                          ),
                          SizedBox(height: height / height5),
                          InterMedium(
                            text:
                                'Take care of all the computers Make sure they are properly turned off',
                            fontsize: width / width14,
                            color: isDark
                                ? DarkColor.color3
                                : LightColor.color3,
                            maxLines: 4,
                          ),
                        ],
                      ),
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
}
