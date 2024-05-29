import 'package:flutter/material.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/task/task_feature_create_screen.dart';
import 'package:tact_tik/utils/colors.dart';

class TaskFeatureScreen extends StatelessWidget {
  const TaskFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkColor.Secondarycolor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFeatureCreateScreen(),
                ));
          },
          backgroundColor: DarkColor.Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
        body: CustomScrollView(
          // physics: const PageScrollPhysics(),
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
                text: 'Task',
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
                        color: DarkColor.WidgetColor,
                        borderRadius: BorderRadius.circular(width / width10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InterSemibold(
                            text: 'Guard Name',
                            fontsize: width / width20,
                            color: DarkColor. Primarycolor,
                          ),
                          SizedBox(height: height / height10),
                          InterSemibold(
                            text: 'This tittle is only for eg. to understand',
                            fontsize: width / width20,
                            color: DarkColor.color1,
                            maxLines: 5,
                          ),
                          SizedBox(height: height / height5),
                          InterMedium(
                            text:
                                'Take care of all the computers Make sure they are properly turned off',
                            fontsize: width / width14,
                            color: DarkColor. color3,
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
