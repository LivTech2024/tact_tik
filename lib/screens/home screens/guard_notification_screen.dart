import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/enums/guard_alert_enums.dart';
import '../../common/widgets/guard_alert_widget.dart';
import '../../fonts/inter_medium.dart';

class GuardNotificationScreen extends StatelessWidget {
  const GuardNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List enums = [
      GuardAlertEnum.newOffer,
      GuardAlertEnum.newExchange,
      GuardAlertEnum.ShiftStatusNotification,
      // If request is rejected then pass var (isRejected)
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Alerts',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () {},
                  child: InterMedium(
                    text: 'Clear Notification',
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontsize: 14.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: enums.length,
                  itemBuilder: (context, index) => GuardAlertWidget(
                    Enum: enums[index],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
