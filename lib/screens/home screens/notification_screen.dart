import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:tact_tik/screens/home%20screens/notification_model.dart';
// import 'package:your_app/models/notification_model.dart'; // Import your notification model

import '../../common/enums/alert_enums.dart';
import '../../common/widgets/alert_widget.dart';
import '../../fonts/inter_medium.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Alerts2',
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 20.h),
              TextButton(
                onPressed: () => _clearNotifications(context),
                child: InterMedium(
                  text: 'Clear Notification',
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontsize: 14.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: FutureBuilder<List<NotificationModel>>(
                  future: _getNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No notifications'));
                    }

                    final notifications = snapshot.data!;
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) => AlertWidget(
                        Enum: notifications[index]
                            .title, // Use appropriate property for AlertWidget
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<NotificationModel>> _getNotifications() async {
    var box = Hive.box('notifications');
    var notificationList = box.values.toList().cast<Map<String, dynamic>>();
    return notificationList.map((data) {
      return NotificationModel(
        title: data['title'],
        body: data['body'],
        timestamp: DateTime.parse(data['timestamp']),
      );
    }).toList();
  }

  void _clearNotifications(BuildContext context) async {
    var box = Hive.box('notifications');
    await box.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notifications cleared')),
    );
    // Optionally, you might want to trigger a rebuild or refresh of the notifications
  }
}
