import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import 'create_discrepancy.dart';

class PayDiscrepancyDisplay extends StatelessWidget {
  const PayDiscrepancyDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Paystub',
          ),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CreateDiscrepancy()));
          },
          // backgroundColor: Theme.of(context).primaryColor,
          shape: CircleBorder(),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Today',
                          fontsize: 18.sp,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        SizedBox(height: 30.h),
                        Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 160.w,
                                child: InterMedium(
                                  text: 'Discrepancy Title',
                                  fontsize: 16.sp,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                              ),
                              InterMedium(
                                text: '11 : 36 pm',
                                fontsize: 16.sp,
                                color: Theme.of(context).textTheme.headlineSmall!.color,
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
