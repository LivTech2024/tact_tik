import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/client%20screens/patrol/view_checkpoint_screen.dart';
import 'package:tact_tik/screens/home%20screens/widgets/icon_text_widget.dart';
import 'package:tact_tik/services/EmailService/EmailJs_fucntion.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../../fonts/inter_semibold.dart';
import '../../../utils/colors.dart';
import '../select_client_guards_screen.dart';

class ClientOpenPatrolScreen extends StatefulWidget {
  final String guardName;
  final String startDate;
  final String startTime;
  final String endTime;
  final int patrolLogCount;
  final String status;
  final String feedback;
  final List<dynamic> checkpoints;
  final Map<String, dynamic> data;
  ClientOpenPatrolScreen({
    super.key,
    required this.guardName,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.patrolLogCount,
    required this.status,
    required this.feedback,
    required this.checkpoints,
    required this.data,
  });

  @override
  State<ClientOpenPatrolScreen> createState() => _ClientOpenPatrolScreenState();
}

class _ClientOpenPatrolScreenState extends State<ClientOpenPatrolScreen> {
  DateTime? selectedDate;

  final List<String> members = [
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
    'https://pikwizard.com/pw/small/39573f81d4d58261e5e1ed8f1ff890f6.jpg',
  ];

  void NavigateScreen(Widget screen, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        selectedDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;
    // final String guardName = Data['PatrolLogGuardName'] ?? '';
    // final String startDate = Data['PatrolDate'] ?? '';
    // final String startTime = Data['PatrolLogStartedAt'] != null
    //     ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
    //         Data['PatrolLogStartedAt'].millisecondsSinceEpoch))
    //     : "";
    // final String endTime = Data['PatrolLogEndedAt'] != null
    //     ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(
    //         Data['PatrolLogEndedAt'].millisecondsSinceEpoch))
    //     : "";
    // final int patrolLogCount = Data['PatrolLogPatrolCount'] ?? 0;
    // final String status = Data['PatrolLogStatus'] ?? 'N/A';
    // final String feedback =
    //     Data['PatrolLogFeedbackComment'] ?? 'No feedback provided';
    // final List<Map<String, dynamic>> checkpoints =
    //     Data['PatrolLogCheckPoints'] ?? [];

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
            text: "${widget.guardName}",
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 140.w,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SelectClientGuardsScreen(companyId: '',)));
                        },
                        child: IconTextWidget(
                          space: 6.w,
                          icon: Icons.add,
                          iconSize: 20.sp,
                          text: 'Select Guard',
                          useBold: true,
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color
                              as Color,
                          Iconcolor: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color as Color,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: SizedBox(
                        width: 190.w,
                        child: IconTextWidget(
                          icon: Icons.calendar_today,
                          text: selectedDate != null
                              ? "${selectedDate!.toLocal()}".split(' ')[0]
                              : 'Display shift Date',
                          fontsize: 14.sp,
                          color: Theme.of(context).textTheme.bodySmall!.color
                              as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),*/
                Container(
                  height: 200.h,
                  margin: EdgeInsets.only(top: 10.h),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      )
                    ],
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.only(top: 20.h),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 5.h),
                              Container(
                                height: 30.h,
                                width: 4.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10.r),
                                    bottomRight: Radius.circular(10.r),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 14.w),
                          SizedBox(
                            width: 190.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InterSemibold(
                                  text: widget.guardName,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                  fontsize: 18.sp,
                                ),
                                // SizedBox(height: height / height5),
                              ],
                            ),
                          )
                        ],
                      ),
                      // SizedBox(height: height / height10),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 18.w,
                          right: 24.w,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 70.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InterRegular(
                                    text: 'Started at',
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color!,
                                  ),
                                  SizedBox(height: 12.h),
                                  InterMedium(
                                    text: widget.startTime,
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 70.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InterRegular(
                                    text: 'Ended at',
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color!,
                                  ),
                                  SizedBox(height: 12.h),
                                  InterMedium(
                                    text: widget.endTime,
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InterRegular(
                                    text: 'Count',
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color!,
                                  ),
                                  SizedBox(height: 12.sp),
                                  InterMedium(
                                    text: '${widget.patrolLogCount}',
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InterRegular(
                                    text: 'Status',
                                    fontsize: 14.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color!,
                                  ),
                                  SizedBox(height: 12.h),
                                  InterBold(
                                    text: widget.status,
                                    fontsize: 14.sp,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InterRegular(
                                  text: 'Feedback :',
                                  color: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .color!,
                                  fontsize: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                    child: InterRegular(
                                  text: widget.feedback,
                                  color: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .color,
                                  fontsize: 14.sp,
                                  maxLines: 3,
                                )),
                              ],
                            ),
                            SizedBox(
                              width: 100.w,
                              child: TextButton(
                                clipBehavior: Clip.none,
                                onPressed: () async {
                                  await generateShiftReportPdf(
                                    "Vaibhav",
                                    widget.data,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.download_for_offline_sharp,
                                      size: 24.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    InterMedium(
                                      text: 'PDF',
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
                                      fontsize: 14.sp,
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                InterBold(
                  text: 'Checkpoints',
                  fontsize: 18.sp,
                  color:
                      Theme.of(context).textTheme.displaySmall!.color as Color,
                ),
                SizedBox(height: 20.h),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.checkpoints.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final checkpointData = widget.checkpoints[index];
                    final checkpointName =
                        checkpointData['CheckPointName'] ?? '';
                    final checkpointStatus =
                        checkpointData['CheckPointStatus'] ?? '';
                    final checkpointReportedAt =
                        checkpointData['CheckPointReportedAt'];
                    final checkpointComment =
                        checkpointData['CheckPointComment'] ?? '';
                    final checkpointImages =
                        checkpointData['CheckPointImage'] ?? [];

                    final reportedAtTime = checkpointReportedAt != null
                        ? DateFormat('hh:mm a').format(
                            (checkpointReportedAt as Timestamp).toDate())
                        : '';

                    return GestureDetector(
                      onTap: () {
                        NavigateScreen(
                          ViewCheckpointScreen(
                            reportedAt: reportedAtTime,
                            comment: checkpointComment,
                            images: checkpointImages,
                            GuardName: widget.guardName,
                          ),
                          context,
                        );
                      },
                      child: Container(
                        height: 50.h,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(bottom: 10.h),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor,
                              blurRadius: 5,
                              spreadRadius: 2,
                              offset: Offset(0, 3),
                            )
                          ],
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 12.h,
                                  width: 12.w,
                                  decoration: BoxDecoration(
                                    color: checkpointStatus == 'checked'
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                SizedBox(
                                  width: 120.w,
                                  child: InterMedium(
                                    // text: 'Checkpoint name Checkpoint name..',
                                    color: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .color,
                                    text: checkpointName,
                                    // color: color21,
                                    fontsize: 16.sp,
                                  ),
                                )
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 24.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .color as Color,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
