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
              Theme.of(context).canvasColor,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              
            },
            backgroundColor:
                Theme.of(context).primaryColor,
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              size: 24.sp,
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                 
                  ),
                  padding: EdgeInsets.only(left: 20.w),
                  onPressed: () {
                    Navigator.pop(context);
                    print(
                        "Navigator debug: ${Navigator.of(context).toString()}");
                  },
                ),
                title: InterMedium(
                  text: 'Pay Discrepancy',
                  
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
                            color:  Theme.of(context).textTheme.bodyMedium!.color,
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
                                color: Theme.of(context).cardColor,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InterMedium(
                                        text: 'Discrepancy Title',
                                        fontsize: 16.sp,
                                        color:  Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                      ),
                                  InterMedium(
                                    text: '11:36 pm',
                                    color:  Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .color,
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
