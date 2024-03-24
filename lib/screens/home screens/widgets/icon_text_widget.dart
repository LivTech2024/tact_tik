import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/utils/colors.dart';

class IconTextWidget extends StatelessWidget {
  const IconTextWidget({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: Primarycolor,),
        SizedBox(width: 20),
        Flexible(child: InterBold(text: text , fontsize: 14,color: color6,))
      ],
    );
  }
}
