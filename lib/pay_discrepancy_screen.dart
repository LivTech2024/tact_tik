import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

import '../../../fonts/inter_bold.dart';
import '../../../fonts/inter_regular.dart';
import '../../../utils/colors.dart';

class PayDiscrepancyScreen extends StatefulWidget {
  const PayDiscrepancyScreen({
    super.key,
  });

  @override
  State<PayDiscrepancyScreen> createState() => _PayDiscrepancyScreenState();
}

class _PayDiscrepancyScreenState extends State<PayDiscrepancyScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor:
              isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              
            },
            backgroundColor:
                isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              size: 24.sp,
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor:
                    isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? DarkColor.color1 : LightColor.color3,
                    size: 24.sp,
                  ),
                  padding: EdgeInsets.only(left: 20.w),
                  onPressed: () {
                    Navigator.pop(context);
                    print(
                        "Navigator debug: ${Navigator.of(context).toString()}");
                  },
                ),
                title: InterRegular(
                  text: 'Pay Discrepancy',
                  fontsize: 18.sp,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
                  letterSpacing: -0.3,
                ),
                centerTitle: true,
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30.h,
                      ),
                      
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                          ),
                          child: InterBold(
                            text: '11/02/2024',
                            fontsize: 20.sp,
                            color: isDark
                                ? DarkColor.Primarycolor
                                : LightColor.color3,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 60.h,
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              margin: EdgeInsets.only(bottom: 10.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: isDark
                                    ? DarkColor.WidgetColor
                                    : LightColor.WidgetColor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InterMedium(
                                        text: 'Discrepancy Title',
                                        fontsize: 16.sp,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                  InterMedium(
                                    text: '11:36 pm',
                                    color: isDark
                                        ? DarkColor.color17
                                        : LightColor.color2,
                                    fontsize: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  childCount: 1,
                ),
              ),
            ],
          )),
    );
  }
}
