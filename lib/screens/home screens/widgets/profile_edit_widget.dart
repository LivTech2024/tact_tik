import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:tact_tik/fonts/roboto_bold.dart';
import 'package:tact_tik/fonts/roboto_medium.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class ProfileEditWidget extends StatelessWidget {
  const ProfileEditWidget(
      {super.key,
      required this.tittle,
      required this.content,
      required Null Function() onTap});
  final String tittle;
  final String content;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterSemibold(
          text: tittle,
          fontsize: width / width20,
          color: color1,
        ),
        SizedBox(height: height / height10),
        InterRegular(
          text: content,
          fontsize: width / width16,
          letterSpacing: -.05,
          color: color3,
        ),
      ],
    );
  }
}
