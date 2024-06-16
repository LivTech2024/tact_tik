import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_semibold.dart';
import 'package:bounce/bounce.dart';
import 'package:tact_tik/main.dart';
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
    this.backgroundcolor = DarkColor.WidgetColor,
    this.borderRadius = 0,
    this.useBorderRadius = false,
    this.MyBorderRadius,
    this.useWidget = false,
    this.MyWidget,
    this.useBorder = false,
  });

  final bool useBold;
  final bool useBorder;
  final bool useBorderRadius;
  final bool useWidget;
  final String text;
  final double? fontsize;
  final double borderRadius;
  final double height;
  final Color? color;
  final Color backgroundcolor;
  final VoidCallback onPressed;
  final BorderRadiusGeometry? MyBorderRadius;
  final Widget? MyWidget;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      onTap: onPressed,
      child: Container(
        decoration: useBorder
            ? BoxDecoration(
                boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    )
                  ],
                // color: backgroundcolor,
                borderRadius: useBorderRadius
                    ? MyBorderRadius
                    : BorderRadius.circular(borderRadius),
                border: Border.all(color: backgroundcolor))
            : BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  )
                ],
                color: backgroundcolor,
                borderRadius: useBorderRadius
                    ? MyBorderRadius
                    : BorderRadius.circular(borderRadius),
              ),
        height: height,
        child: Center(
          child: useWidget
              ? MyWidget
              : useBold
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
