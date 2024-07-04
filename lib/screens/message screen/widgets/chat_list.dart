import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart'; // Add this import
import 'package:tact_tik/screens/message%20screen/widgets/sender_message_card.dart';
import 'info.dart';
import 'my_message_card.dart';

class ChatList extends StatefulWidget {
  final String? guardId;
  const ChatList({Key? key, this.guardId}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<QuerySnapshot>>(
      stream: CombineLatestStream.list([
        FirebaseFirestore.instance
            .collection('Messages')
            .where('MessageType', isEqualTo: 'message')
            .where('MessageCreatedById', isEqualTo: currentUser?.uid)
            .where('MessageReceiversId', arrayContains: widget.guardId)
            .snapshots(),
        FirebaseFirestore.instance
            .collection('Messages')
            .where('MessageType', isEqualTo: 'message')
            .where('MessageCreatedById', isEqualTo: widget.guardId)
            .where('MessageReceiversId', arrayContains: currentUser?.uid)
            .snapshots(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = [
          ...snapshot.data![0].docs,
          ...snapshot.data![1].docs,
        ];

        if (docs.isEmpty) {
          return const Center(child: Text("No Conversations to Display"));
        }

        var messages = docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String messageData = data['MessageData'] ?? "";
          Timestamp timestamp = data['MessageCreatedAt'];
          DateTime dateTime = timestamp.toDate();
          String time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

          bool isMe = data['MessageCreatedById'] == currentUser?.uid;

          return {
            'text': messageData,
            'time': time,
            'isMe': isMe,
            'timestamp': timestamp,
          };
        }).toList();

        messages.sort((b, a) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            if (messages[index]['isMe'] == true) {
              return MyMessageCard(
                message: messages[index]['text'].toString(),
                date: messages[index]['time'].toString(),
              );
            }
            return SenderMessageCard(
              message: messages[index]['text'].toString(),
              date: messages[index]['time'].toString(),
            );
          },
        );
      },
    );
  }
}