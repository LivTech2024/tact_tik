import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/utils/colors.dart';

class ClientOpenDarScreen extends StatelessWidget {
  const ClientOpenDarScreen({super.key});

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
          title: InterRegular(
            text: "DAR Data- Nick Jones",
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Place Spot Name Goes Here..',
                  fontsize: 18.sp,
                ),
                SizedBox(height: 20.h),
                InterSemibold(
                  text: 'Time: 00.00 - 01.00  ',
                  fontsize: 14.sp,
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Description',
                  fontsize: 18.sp,
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  constraints: BoxConstraints(),
                  decoration: BoxDecoration(
                    color: DarkColor.WidgetColor,
                    borderRadius: BorderRadius.circular(13.85.r),
                  ),
                  child: InterRegular(
                    text:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse varius enim in eros elementum tristique. Lorem ipsum dolor sit amet\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse varius enim in eros elementum tristique.  ipsum dolor sit amet\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse varius enim in eros elementum tristique. Lorem ipsum dolor sit amet....',
                    fontsize: 14.sp,
                    maxLines: 80,
                  ),
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Patrol',
                  fontsize: 20.sp,
                ),
                InterBold(
                  text: 'Reports',
                  fontsize: 20.sp,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // print("TIle Patrol Data ${TilePatrolData}");
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30.h),
                        height: 35.h,
                        color: Theme.of(context).cardColor,
                        child: Row(
                          children: [
                            Container(
                              width: 15.w,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Column(
                                children: [
                                  InterBold(
                                    text: "#334AH6 Qr Missing",
                                    fontsize: 12.sp,
                                    color: Colors.white,
                                  ),
                                  InterBold(
                                    text: "11.36pm",
                                    fontsize: 12.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
