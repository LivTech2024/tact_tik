import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/screens/feature%20screens/task/task_feature_create_screen.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class TaskFeatureScreen extends StatelessWidget {
  const TaskFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFeatureCreateScreen(),
                ));
          },
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add , size: 24.sp,),
        ),
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
                  size: 24.sp,
                ),
                padding: EdgeInsets.only(left: 20.w),
                onPressed: () {
                  Navigator.pop(context);
                  print("Navigtor debug: ${Navigator.of(context).toString()}");
                },
              ),
              title: InterRegular(
                text: 'Task',
                fontsize: 18.sp,
                color: Colors.white,
                letterSpacing: -.3,
              ),
              centerTitle: true,
              floating: true, // Makes the app bar float above the content
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30.h,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 30.w,
                      right: 30.w,
                      bottom: 40.h,
                    ),
                    child: Container(
                      width: double.maxFinite,
                      constraints: BoxConstraints(
                        minHeight: 140.h,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InterSemibold(
                            text: 'Guard Name',
                            fontsize: 20.sp,
                            color: Primarycolor,
                          ),
                          SizedBox(height: 10.h),
                          InterSemibold(
                            text: 'This tittle is only for eg. to understand',
                            fontsize: 20.sp,
                            color: color1,
                            maxLines: 5,
                          ),
                          SizedBox(height: 5.h),
                          InterMedium(
                            text:
                                'Take care of all the computers Make sure they are properly turned off',
                            fontsize: 14.sp,
                            color: color3,
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
