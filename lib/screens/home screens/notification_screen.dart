import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/enums/alert_enums.dart';
import '../../common/widgets/alert_widget.dart';
import '../../fonts/inter_medium.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    // Text(
    //   message.notification!.title.toString(),
    //   style: TextStyle(color: Colors.white),
    // ),

    List enums = [
      AlertEnum.newExchange,
      AlertEnum.newOffer,
      AlertEnum.exchange,
      AlertEnum.shiftEnded,
    ];
    return Scaffold(
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
            children: [
              SizedBox(height: 30.h),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: enums.length,
                itemBuilder: (context, index) => AlertWidget(
                  Enum: enums[index],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
