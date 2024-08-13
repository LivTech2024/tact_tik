import 'package:bounce/bounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/message%20screen/widgets/chat_list.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';

class MobileChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String companyId;
  final String userName;

  const MobileChatScreen(
      {Key? key,
      required this.receiverId,
      required this.receiverName,
      required this.companyId,
      required this.userName})
      : super(key: key);

  @override
  State<MobileChatScreen> createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends State<MobileChatScreen> {
  final TextEditingController _messageController = TextEditingController();

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
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterMedium(
            text: 'Message',
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                guardId: widget.receiverId,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.sp),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        hintText: 'Type a message!',
                        hintStyle: GoogleFonts.inter(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(10.sp),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 8.w),
                        ),
                      ),
                      cursorColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Bounce(
                    onTap: () async {
                      String message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        User? currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser != null) {
                          DocumentReference docRef = await FirebaseFirestore
                              .instance
                              .collection('Messages')
                              .add({
                            'MessageCompanyId': widget.companyId,
                            'MessageCreatedAt': Timestamp.now(),
                            'MessageCreatedById': currentUser.uid,
                            'MessageCreatedByName': widget.userName,
                            'MessageData': message,
                            'MessageReceiversId': [widget.receiverId],
                            'MessageType': "message"
                            //To-do MessageCreatorType
                          });
                          await docRef.update({
                            'MessageId': docRef.id,
                          });
                          _messageController.clear();
                        }
                      }
                    },
                    child: Container(
                      height: 45.h,
                      width: 45.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
