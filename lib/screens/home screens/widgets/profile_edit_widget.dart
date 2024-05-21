import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/main.dart';
import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class ProfileEditWidget extends StatelessWidget {
  const ProfileEditWidget({
    Key? key, // Added Key? key parameter
    required this.tittle,
    required this.content,
    required this.onTap,
  }) : super(key: key); // Added super(key: key) to the constructor

  final String tittle;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterSemibold(
            text: tittle,
            fontsize: width / width20,
            color:  isDark ? DarkColor.color1 : LightColor.color3,
          ),
          SizedBox(height: height / height10),
          InterRegular(
            text: content,
            fontsize: width / width16,
            letterSpacing: -.05,
            color:  isDark ? DarkColor.color3 : LightColor.color3,
          ),
        ],
      ),
    );
  }
}
