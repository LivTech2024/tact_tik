import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class HomeScreenCustomNavigation extends StatefulWidget {
  const HomeScreenCustomNavigation(
      {super.key,
      required this.icon,
      required this.color,
      this.useSVG = false,
      required this.text,
      required this.textcolor,
      this.SVG});
  final IconData icon;
  final Color color;
  final Color textcolor;
  final bool useSVG;
  final String? SVG;
  final String text;

  @override
  State<HomeScreenCustomNavigation> createState() => _HomeScreenCustomNavigationState();
}

class _HomeScreenCustomNavigationState extends State<HomeScreenCustomNavigation> {
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      height: (width / width70),
      width: (width / width70),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : LightColor.color3.withOpacity(.05),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
        color: isDark? DarkColor. WidgetColor:LightColor.WidgetColor,
        borderRadius: BorderRadius.circular((width / width13)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.useSVG
              ? SvgPicture.asset(
                  widget.SVG!,
                  color: widget.color,
                )
              : Icon(
                  widget.icon,
                  size: (width / width24),
                  color: widget.color,
                ),
          SizedBox(height: height / height8),
          InterMedium(
            text: widget.text,
            fontsize: (width / width12),
            color: widget.textcolor,
          )
        ],
      ),
    );
  }
}
