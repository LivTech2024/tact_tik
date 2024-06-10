import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_regular.dart';

class ViewCheckpointScreen extends StatefulWidget {
  final String reportedAt;
  final String comment;
  final List<dynamic> images;
  final String GuardName;
  const ViewCheckpointScreen(
      {super.key,
      required this.comment,
      required this.images,
      required this.reportedAt,
      required this.GuardName});

  @override
  State<ViewCheckpointScreen> createState() => _ViewCheckpointScreenState();
}

class _ViewCheckpointScreenState extends State<ViewCheckpointScreen> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        
        appBar: AppBar(
          
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              
              size: 24.sp,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            // text: '$widget.guardName}',
            text: "${widget.GuardName}",
          
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
                InterBold(
                  text: 'Details',
                  fontsize: 18.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                SizedBox(height: 20.h),
                InterMedium(
                  text: 'Time: ' + widget.reportedAt,
                  fontsize: 14.sp,
                  color: Theme.of(context).textTheme.displaySmall!.color,
                ),
                SizedBox(height: 50.h),
                InterBold(
                  text: 'Comments',
                  fontsize: 18.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                SizedBox(height: 10.h),
                InterMedium(
                  text: widget.comment,
                  fontsize: 14.sp,
                  color: Theme.of(context).textTheme.displaySmall!.color,
                  maxLines: 3,
                ),
                SizedBox(height: 50.h),
                InterBold(
                  text: 'Images',
                  fontsize: 18.sp,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
                GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    crossAxisCount: 3,
                  ),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = widget.images[index];
                    return Container(
                      height: 66.h,
                      width: 66.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(width / width10),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 50.h),
                // InterBold(
                //   text: 'Reports',
                //   fontsize: width / width18,
                //   color: color1,
                // ),
                // ListView.builder(
                //   shrinkWrap: true,
                //   physics: const NeverScrollableScrollPhysics(),
                //   itemCount: 10,
                //   itemBuilder: (context, index) {
                //     return Container(
                //       margin: EdgeInsets.only(top: 14.h),
                //       height: 30.h,
                //       padding: EdgeInsets.only(right: 10.w),
                //       decoration: BoxDecoration(
                //           color: WidgetColor,
                //           borderRadius: BorderRadius.circular(10.r)),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Container(
                //             width: 10.w,
                //             height: double.infinity,
                //             color: Colors.red,
                //           ),
                //           SizedBox(width: width / width2),
                //           SizedBox(
                //             width: width / width230,
                //             child: InterMedium(
                //               text: '#334AH6 Qr Missing',
                //               color: color6,
                //               fontsize: width / width16,
                //             ),
                //           ),
                //           SizedBox(width: width / width2),
                //           InterBold(
                //             text: '11.36pm',
                //             color: color6,
                //             fontsize: width / width16,
                //           )
                //         ],
                //       ),
                //     );
                //   },
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
