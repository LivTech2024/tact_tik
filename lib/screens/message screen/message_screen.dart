import 'package:flutter/material.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/message%20screen/widgets/chat_list.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';

class MobileChatScreen extends StatelessWidget {
  const MobileChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
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
          const Expanded(
            child: ChatList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    hintText: 'Type a message!',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    contentPadding: EdgeInsets.all(width / width10),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: width / width8),
                    ),
                  ),
                )),
                IconButton(
                  onPressed: () {
                    // Send message logic here
                  },
                  icon: Icon(
                    Icons.send,
                    size: width / width24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
