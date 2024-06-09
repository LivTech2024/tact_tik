import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/main.dart';
import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SPanicScreen extends StatefulWidget {
  final String empId;
  const SPanicScreen({super.key, required this.empId});

  @override
  State<SPanicScreen> createState() => _SPanicScreenState();
}

class _SPanicScreenState extends State<SPanicScreen> {
  @override
  Widget build(BuildContext context) {
  

    return SafeArea(
      child: Scaffold(
       
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
                },
              ),
              title: InterMedium(
                text: 'Panic',
               
              ),
              centerTitle: true,
              floating: true,
            ),
            SliverFillRemaining(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Messages')
                    .where('MessageReceiversId', arrayContains: widget.empId)
                    .orderBy('MessageCreatedAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No panic messages found.'));
                  }

                  final messages = snapshot.data!.docs.where((doc) {
                    var messageData = doc['MessageData'] ?? '';
                    return messageData.contains('Panic Button pressed');
                  }).toList();

                  if (messages.isEmpty) {
                    return Center(child: Text('No panic messages found.'));
                  }

                  Map<String, List<DocumentSnapshot>> groupedMessages = {};
                  for (var message in messages) {
                    var messageDate = (message['MessageCreatedAt'] as Timestamp).toDate();
                    var formattedDate = "${messageDate.day}/${messageDate.month}/${messageDate.year}";

                    if (groupedMessages.containsKey(formattedDate)) {
                      groupedMessages[formattedDate]!.add(message);
                    } else {
                      groupedMessages[formattedDate] = [message];
                    }
                  }

                  return ListView.builder(
                    itemCount: groupedMessages.length,
                    itemBuilder: (context, index) {
                      String date = groupedMessages.keys.elementAt(index);
                      List<DocumentSnapshot> dailyMessages = groupedMessages[date]!;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: InterBold(
                                text: date,
                                fontsize: 18.sp,
                                color: isDark
                                    ? DarkColor.color21
                                    : LightColor.color3,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            ...dailyMessages.map((message) {
                              var messageData = message['MessageData'] ?? '';
                              var messageDate = (message['MessageCreatedAt'] as Timestamp).toDate();
                              var formattedTime = "${messageDate.hour}:${messageDate.minute.toString().padLeft(2, '0')} ${messageDate.hour >= 12 ? 'pm' : 'am'}";
                              var createdBy = message['MessageCreatedByName'] ?? 'Unknown';

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.transparent
                                            : LightColor.color3
                                                .withOpacity(.05),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: Offset(0, 3),
                                      )
                                    ],
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.all(20.w),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          // TODO pass the image value there
                                          CircleAvatar(
                                            backgroundImage: NetworkImage('url'), // Replace with actual image URL if available
                                            foregroundImage: AssetImage('assets/images/default.png'),
                                            radius: 20.r,
                                            backgroundColor: isDark
                                                ? DarkColor.Primarycolor
                                                : LightColor.Primarycolor,
                                          ),
                                          SizedBox(width: 20.w),
                                          InterBold(
                                            text: createdBy,
                                            letterSpacing: -.3,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                        ],
                                      ),
                                      InterMedium(
                                        text: formattedTime,
                                        fontsize: 16.sp,
                                        color: isDark
                                            ? DarkColor.color1
                                            : LightColor.color3,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
