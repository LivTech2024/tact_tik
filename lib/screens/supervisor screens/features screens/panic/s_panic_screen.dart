import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppBarcolor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: width / width24,
                ),
                padding: EdgeInsets.only(left: width / width20),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: InterRegular(
                text: 'Panic',
                fontsize: width / width18,
                color: Colors.white,
                letterSpacing: -.3,
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
                        padding: EdgeInsets.symmetric(vertical: height / height20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: width / width20),
                              child: InterBold(
                                text: date,
                                fontsize: width / width18,
                                color: color21,
                              ),
                            ),
                            SizedBox(height: height / height10),
                            ...dailyMessages.map((message) {
                              var messageData = message['MessageData'] ?? '';
                              var messageDate = (message['MessageCreatedAt'] as Timestamp).toDate();
                              var formattedTime = "${messageDate.hour}:${messageDate.minute.toString().padLeft(2, '0')} ${messageDate.hour >= 12 ? 'pm' : 'am'}";
                              var createdBy = message['MessageCreatedByName'] ?? 'Unknown';

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: width / width20, vertical: height / height20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color19,
                                    borderRadius: BorderRadius.circular(width / width12),
                                  ),
                                  padding: EdgeInsets.all(width / width20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage('url'), // Replace with actual image URL if available
                                            radius: width / width20,
                                          ),
                                          SizedBox(width: width / width20),
                                          InterBold(
                                            text: createdBy,
                                            letterSpacing: -.3,
                                            color: color1,
                                          ),
                                        ],
                                      ),
                                      InterMedium(
                                        text: formattedTime,
                                        fontsize: width / width16,
                                        color: color1,
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
