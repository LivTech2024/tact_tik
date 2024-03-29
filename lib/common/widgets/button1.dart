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
    this.backgroundcolor = WidgetColor, this.borderRadius = 0,
  });

  final bool useBold;
  final String text;
  final double? fontsize;
  final double borderRadius;
  final double height;
  final Color? color;
  final Color backgroundcolor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundcolor,
          borderRadius: BorderRadius.circular(borderRadius)
        ),
        height: height,
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
