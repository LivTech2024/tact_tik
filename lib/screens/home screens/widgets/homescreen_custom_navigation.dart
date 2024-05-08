import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class HomeScreenCustomNavigation extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      height: height / height74,
      width: width / width74,
      decoration: BoxDecoration(
        color: WidgetColor,
        borderRadius: BorderRadius.circular(width / width13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          useSVG
              ? SvgPicture.asset(
                  SVG!,
                  color: color,
                )
              : Icon(
                  icon,
                  size: width / width24,
                  color: color,
                ),
          SizedBox(height: height / height8),
          InterMedium(
            text: text,
            fontsize: width / width12,
            color: textcolor,
          )
        ],
      ),
    );
  }
}
