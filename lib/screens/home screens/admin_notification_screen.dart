import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/common/widgets/admin_alert_widget.dart';
import 'package:tact_tik/screens/home%20screens/guard_notification_screen.dart';
import 'package:tact_tik/services/Userservice.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../common/enums/guard_alert_enums.dart';
import '../../common/widgets/guard_alert_widget.dart';
import '../../fonts/inter_medium.dart';

class AdminNotificationScreen extends StatefulWidget {
  final String employeeId;
  final String companyId;
  const AdminNotificationScreen(
      {super.key, required this.employeeId, required this.companyId});

  @override
  _GuardNotificationScreenState createState() =>
      _GuardNotificationScreenState();
}

class _GuardNotificationScreenState extends State<AdminNotificationScreen> {
  List<NotificationModel> notifications = [];
  final _userService = UserService(firestoreService: FireStoreService());
  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      print("EmployeeiD ${_userService.employeeID}");
      print("CompanyId ${_userService.shiftCompanyId}");
      print("CompanyId Emp ${widget.companyId}");

      // Fetch notifications for SHIFTOFFER with status "started"
      QuerySnapshot shiftOfferSnapshot = await FirebaseFirestore.instance
          .collection('Notification')
          .where('NotificationCompanyId', isEqualTo: widget.companyId)
          .where('NotificationType', isEqualTo: 'SHIFTOFFER')
          .where('NotificationStatus', isEqualTo: 'pending')
          .orderBy('NotificationCreatedAt', descending: true)
          .get();

      // Fetch notifications for SHIFTEXCHANGE with status "started"
      QuerySnapshot shiftExchangeSnapshot = await FirebaseFirestore.instance
          .collection('Notification')
          .where('NotificationCompanyId', isEqualTo: widget.companyId)
          .where('NotificationType', isEqualTo: 'SHIFTEXCHANGE')
          .where('NotificationStatus', isEqualTo: 'pending')
          .orderBy('NotificationCreatedAt', descending: true)
          .get();

      // Fetch notifications for Message with only companyId condition
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('Notification')
          .where('NotificationCompanyId', isEqualTo: widget.companyId)
          .where('NotificationType', isEqualTo: 'Message')
          .orderBy('NotificationCreatedAt', descending: true)
          .get();

      // Combine all results: SHIFTOFFER, SHIFTEXCHANGE, and Message
      List<QueryDocumentSnapshot> allDocs = [
        ...shiftOfferSnapshot.docs,
        ...shiftExchangeSnapshot.docs,
        ...messageSnapshot.docs,
      ];

      // Sort combined notifications by creation time (in descending order)
      allDocs.sort((a, b) {
        Timestamp timeA = a['NotificationCreatedAt'] ?? Timestamp.now();
        Timestamp timeB = b['NotificationCreatedAt'] ?? Timestamp.now();
        return timeB.compareTo(timeA); // Descending order
      });

      setState(() {
        notifications =
            allDocs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
      });

      print("Notifications:");
      for (var notification in notifications) {
        print(
            "Message: ${notification.message}, Type: ${notification.type}, CreatedAt: ${notification.createdAt.toDate()}");
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
            text: ' Supervisor Alerts',
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
                SizedBox(height: 20.h),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => SupervisorAlertWidget(
                    message: notifications[index].message,
                    type: notifications[index].type,
                    createdAt: notifications[index].createdAt.toDate(),
                    shiftExchangeData: notifications[index].shiftExchangeData,
                    shiftOfferData: notifications[index].shiftOfferData,
                    notiId: notifications[index].notificationId,
                    status: notifications[index].notificationStatus,
                    refresh: () {
                      fetchNotifications();
                    },
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

// class NotificationModel {
//   final String message;
//   final String type;
//   final Timestamp createdAt;
//   final String notificationStatus;
//   final ShiftExchangeData? shiftExchangeData;
//   final ShiftOfferData? shiftOfferData;
//   final String notificationId;
// // NotificationId
//   NotificationModel({
//     required this.message,
//     required this.type,
//     required this.createdAt,
//     required this.notificationStatus,
//     required this.notificationId,
//     this.shiftExchangeData,
//     this.shiftOfferData,
//   });

//   factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     // Parsing data and handling optional fields
//     return NotificationModel(
//       message: data['NotificationMessage'] ?? '',
//       type: data['NotificationType'] ?? '',
//       createdAt: data['NotificationCreatedAt'] ?? Timestamp.now(),
//       notificationStatus: data['NotificationStatus'] ?? '',
//       notificationId: data['NotificationId'],
//       shiftExchangeData: data['ShiftExchangeData'] != null
//           ? ShiftExchangeData.fromMap(data['ShiftExchangeData'])
//           : null,
//       shiftOfferData: data['ShiftOfferData'] != null
//           ? ShiftOfferData.fromMap(data['ShiftOfferData'])
//           : null,
//     );
//   }
// }

// class ShiftExchangeData {
//   final String exchangeShiftId;
//   final String exchangeShiftTime;
//   final Timestamp exchangeShiftDate;
//   final String exchangeShiftLocation;
//   final String exchangeShiftRequestedId;
//   final String exchangeShiftRequestedName;
//   final String exchangeShiftName;
//   ShiftExchangeData({
//     required this.exchangeShiftId,
//     required this.exchangeShiftTime,
//     required this.exchangeShiftDate,
//     required this.exchangeShiftLocation,
//     required this.exchangeShiftRequestedId,
//     required this.exchangeShiftRequestedName,
//     required this.exchangeShiftName,
//   });

//   factory ShiftExchangeData.fromMap(Map<String, dynamic> map) {
//     return ShiftExchangeData(
//       exchangeShiftId: map['ExchangeShiftId'] ?? '',
//       exchangeShiftTime: map['ExchangeShiftTime'] ?? '',
//       exchangeShiftDate: map['ExchangeShiftDate'] ?? Timestamp.now(),
//       exchangeShiftLocation: map['ExchangeShiftLocation'] ?? '',
//       exchangeShiftRequestedId: map['ExchangeShiftRequestedId'] ?? '',
//       exchangeShiftRequestedName: map['ExchangeShiftRequestedName'] ?? '',
//       exchangeShiftName: map['ExchangeShiftName'] ?? '',
//     );
//   }
// }

// class ShiftOfferData {
//   final String offerShiftId;
//   final String offerShiftTime;
//   final Timestamp offerShiftDate;
//   final String offerShiftLocation;
//   final String offerShiftRequestedId;
//   final String offerShiftRequestedName;
//   final String offerShiftName;
//   final String offerShiftID;

//   ShiftOfferData({
//     required this.offerShiftId,
//     required this.offerShiftID,
//     required this.offerShiftTime,
//     required this.offerShiftDate,
//     required this.offerShiftLocation,
//     required this.offerShiftRequestedId,
//     required this.offerShiftRequestedName,
//     required this.offerShiftName,
//   });

//   factory ShiftOfferData.fromMap(Map<String, dynamic> map) {
//     return ShiftOfferData(
//       offerShiftId: map['OfferShiftId'] ?? '',
//       offerShiftTime: map['OfferShiftTime'] ?? '',
//       offerShiftDate: map['OfferShiftDate'] ?? Timestamp.now(),
//       offerShiftLocation: map['OfferShiftLocation'] ?? '',
//       offerShiftRequestedId: map['OfferShiftRequestedId'] ?? '',
//       offerShiftRequestedName: map['OfferShiftRequestedName'] ?? '',
//       offerShiftName: map['OfferShiftName'] ?? '',
//       offerShiftID: '',
//     );
//   }
// }
