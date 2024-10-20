import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../common/enums/guard_alert_enums.dart';
import '../../common/widgets/guard_alert_widget.dart';
import '../../fonts/inter_medium.dart';

class GuardNotificationScreen extends StatefulWidget {
  final String employeeId;
  final String companyId;
  const GuardNotificationScreen(
      {super.key, required this.employeeId, required this.companyId});

  @override
  _GuardNotificationScreenState createState() =>
      _GuardNotificationScreenState();
}

class _GuardNotificationScreenState extends State<GuardNotificationScreen> {
  List<NotificationModel> notifications = [];
  final _userService = UserService(firestoreService: FireStoreService());
  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      print("OfferCompanyiD ${widget.companyId}");
      // Fetch Shift Offer notifications for the specific company
      QuerySnapshot shiftOfferSnapshot = await FirebaseFirestore.instance
          .collection('Notification')
          .where('NotificationType', isEqualTo: 'SHIFTOFFER')
          .where('NotificationCompanyId', isEqualTo: widget.companyId)
          .orderBy('NotificationCreatedAt', descending: true)
          .get();

      // Fetch other notifications related to the employee
      QuerySnapshot otherNotificationsSnapshot =
          await FirebaseFirestore.instance
              .collection('Notification')
              .where('NotificationIds', arrayContains: widget.employeeId)
              // .where('NotificationType', isNotEqualTo: 'SHIFTOFFER')
              .orderBy('NotificationCreatedAt', descending: true)
              .get();

      print("Shift Offer Notifications Snapshot:");
      for (var doc in shiftOfferSnapshot.docs) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
      }

      print("Other Notifications Snapshot:");
      for (var doc in otherNotificationsSnapshot.docs) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
      }

      List<NotificationModel> fetchedNotifications = [];
      List<NotificationModel> shiftOfferNotifications = [];

      // Process Shift Offer notifications
      for (var doc in shiftOfferSnapshot.docs) {
        var notification = NotificationModel.fromFirestore(doc);
        shiftOfferNotifications.add(notification);
      }

      // Process other notifications
      for (var doc in otherNotificationsSnapshot.docs) {
        var notification = NotificationModel.fromFirestore(doc);

        if (notification.notificationStatus != 'completed') {
          fetchedNotifications.add(notification);
        }
      }

      print(
          "Shift Offer Notifications Count: ${shiftOfferNotifications.length}");
      print("Other Notifications Count: ${fetchedNotifications.length}");

      // Combine and update state
      setState(() {
        notifications = fetchedNotifications + shiftOfferNotifications;
      });

      print("Combined Notifications:");
      for (var notification in notifications) {
        print(
            "Message: ${notification.message}, Type: ${notification.type}, CreatedAt: ${notification.createdAt.toDate()}");
        print("Notification Display ${notification}");
      }
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // TextButton(
                //   onPressed: () {
                //     // Implement Clear Notification functionality here
                //     print("Notification length ${notifications.length}");
                //   },
                //   child: InterMedium(
                //     text: 'Clear Notification',
                //     color: Theme.of(context).textTheme.bodyLarge?.color,
                //     fontsize: 14.sp,
                //   ),
                // ),
                // SizedBox(height: 20.h),

                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => GuardAlertWidget(
                    message: notifications[index].message,
                    type: notifications[index].type,
                    createdAt: notifications[index].createdAt.toDate(),
                    shiftExchangeData: notifications[index].shiftExchangeData,
                    shiftOfferData: notifications[index].shiftOfferData,
                    notiId: notifications[index].notificationId,
                    status: notifications[index].notificationStatus,
                    onRefresh: () {
                      fetchNotifications();
                    },
                    currentEmpid: widget.employeeId,
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

class NotificationModel {
  final String message;
  final String type;
  final Timestamp createdAt;
  final String notificationStatus;
  final ShiftExchangeData? shiftExchangeData;
  final ShiftOfferData? shiftOfferData;
  final String notificationId;

  NotificationModel({
    required this.message,
    required this.type,
    required this.createdAt,
    required this.notificationStatus,
    required this.notificationId,
    this.shiftExchangeData,
    this.shiftOfferData,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      message: data['NotificationMessage'] ?? '',
      type: data['NotificationType'] ?? '',
      createdAt: data['NotificationCreatedAt'] ?? Timestamp.now(),
      notificationStatus: data['NotificationStatus'] ?? '',
      notificationId: data['NotificationId'] ?? '',
      shiftExchangeData: data['ShiftExchangeData'] != null
          ? ShiftExchangeData.fromMap(data['ShiftExchangeData'])
          : null,
      shiftOfferData: data['ShiftOfferData'] != null
          ? ShiftOfferData.fromMap(data['ShiftOfferData'])
          : null,
    );
  }
}

class ShiftExchangeData {
  final String exchangeShiftId;
  final String exchangeShiftTime;
  final Timestamp exchangeShiftDate;
  final String exchangeShiftLocation;
  final String exchangeShiftRequestedId;
  final String exchangeShiftRequestedName;
  final String exchangeShiftName;

  ShiftExchangeData({
    required this.exchangeShiftId,
    required this.exchangeShiftTime,
    required this.exchangeShiftDate,
    required this.exchangeShiftLocation,
    required this.exchangeShiftRequestedId,
    required this.exchangeShiftRequestedName,
    required this.exchangeShiftName,
  });

  factory ShiftExchangeData.fromMap(Map<String, dynamic> map) {
    return ShiftExchangeData(
      exchangeShiftId: map['ExchangeShiftId'] ?? '',
      exchangeShiftTime: map['ExchangeShiftTime'] ?? '',
      exchangeShiftDate: map['ExchangeShiftDate'] ?? Timestamp.now(),
      exchangeShiftLocation: map['ExchangeShiftLocation'] ?? '',
      exchangeShiftRequestedId: map['ExchangeShiftRequestedId'] ?? '',
      exchangeShiftRequestedName: map['ExchangeShiftRequestedName'] ?? '',
      exchangeShiftName: map['ExchangeShiftName'] ?? '',
    );
  }
}

class ShiftOfferData {
  final String offerShiftId;
  final String offerShiftTime;
  final Timestamp offerShiftDate;
  final String offerShiftLocation;
  final String offerShiftRequestedId;
  final String offerShiftRequestedName;
  final String offerShiftName;
  // final String offerShiftID;
  final String offerAcceptedId;

  ShiftOfferData({
    required this.offerShiftId,
    // required this.offerShiftID,
    required this.offerShiftTime,
    required this.offerShiftDate,
    required this.offerShiftLocation,
    required this.offerShiftRequestedId,
    required this.offerShiftRequestedName,
    required this.offerShiftName,
    required this.offerAcceptedId,
  });

  factory ShiftOfferData.fromMap(Map<String, dynamic> map) {
    return ShiftOfferData(
      offerShiftId: map['ShiftOfferId'] ?? '',
      offerShiftTime: map['ShiftOfferTime'] ?? '',
      offerShiftDate: map['ShiftOfferDate'] ?? Timestamp.now(),
      offerShiftLocation: map['ShiftOfferLocation'] ?? '',
      offerShiftRequestedId: map['ShiftOfferShiftId'] ?? '',
      offerShiftRequestedName: map['ShiftOfferShiftName'] ?? '',
      offerShiftName: map['ShiftOfferShiftName'] ?? '',
      // offerShiftID: '',
      offerAcceptedId: map["ShiftOfferAcceptedId"] ?? "",
    );
  }
}
