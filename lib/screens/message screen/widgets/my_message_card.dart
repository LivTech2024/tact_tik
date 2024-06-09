import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/sizes.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;

  const MyMessageCard({Key? key, required this.message, required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;


    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width / width8),),
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.symmetric(horizontal: width / width15, vertical: height / height5),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: width / width10,
                  right: width / width30,
                  top: height / height5,
                  bottom: height / height30,
                ),
                child: InterMedium(
                  text: message,
                  fontsize: width / width16,
                  color: isDark ? DarkColor.color1 : LightColor.color3,
                ),
              ),
              Positioned(
                bottom: height / height4,
                right: width / width10,
                child: Row(
                  children: [
                    InterMedium(
                      text: date,
                      fontsize: width / width13,
                      color:  isDark ? DarkColor.color2 : LightColor.color3,
                    ),
                    SizedBox(
                      width: width / width4
                    ),
                    Icon(
                      Icons.done_all,
                      size: width / width20,
                      color:  isDark ? DarkColor.color2 : LightColor.color3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
