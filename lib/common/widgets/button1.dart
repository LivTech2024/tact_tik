import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';

import '../../fonts/inter_bold.dart';
import '../../utils/colors.dart';

class Button1 extends StatelessWidget {
  const Button1({
    super.key,
    this.useBold = true,
    required this.text,
    this.fontsize,
    this.color,
    required this.onPressed,
    this.height = 65,
    this.backgroundcolor = WidgetColor,
  });

  final bool useBold;
  final String text;
  final double? fontsize;
  final double height;
  final Color? color;
  final Color backgroundcolor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        color: backgroundcolor,
        child: Center(
          child: useBold
              ? InterBold(
                  text: text,
                  fontsize: fontsize,
                  color: color,
                )
              : InterSemibold(
                  text: text,
                  fontsize: fontsize,
                  color: color,
                ),
        ),
      ),
    );
  }
}
