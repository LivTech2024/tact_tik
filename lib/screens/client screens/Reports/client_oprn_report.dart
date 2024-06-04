import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class ClientOpenReport extends StatelessWidget {
  const ClientOpenReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        appBar: AppBar(
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
            },
          ),
          title: InterBold(
            text: 'Report',
            fontsize: 18.sp,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Name:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'guy: ',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Category:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'Security safety',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Date:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: '04 Jun-24 14:10',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Follow Up Required:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'Yes',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Data:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'ftfy',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Status:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'completed',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Employee Name:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'Vaibhav Sutar',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Report Location:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'Thakur Polytechnic',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterBold(
                      text: 'Followed Up Report:',
                      fontsize: 18.sp,
                      color: color1,
                    ),
                    SizedBox(width: 20.h),
                    InterMedium(
                      text: 'Thakur Polytechnic',
                      fontsize: 14.sp,
                      color: color21,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
