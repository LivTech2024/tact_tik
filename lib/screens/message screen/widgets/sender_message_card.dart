import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/sizes.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
  }) : super(key: key);
  final String message;
  final String date;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(width / width8),),
          color: isDark ? DarkColor.Primarycolorlight : LightColor.Primarycolorlight,
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
                  color: DarkColor.  color1,
                ),
              ),
              Positioned(
                bottom: height / height2,
                right: height / height10,
                child: InterMedium(
                  text: date,
                    fontsize: width / width13,
                    color: DarkColor.color2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
