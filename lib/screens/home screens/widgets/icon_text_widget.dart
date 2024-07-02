import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../common/sizes.dart';

class IconTextWidget extends StatelessWidget {
  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.useBold = true,
    this.color = DarkColor.color6,
    this.fontsize = 14,
    this.iconSize,
    this.Iconcolor = DarkColor.Primarycolor,
    this.space,
  });

  final IconData icon;
  final String text;
  final bool useBold;
  final Color color;
  final Color Iconcolor;
  final double fontsize;
  final double? iconSize;
  final double? space;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Iconcolor,
          size: iconSize,
        ),
        SizedBox(width: space ?? (width / width20)),
        Flexible(
          child: useBold
              ? InterBold(
                  text: text,
                  fontsize: fontsize,
                  color: color,
                  maxLine: 2,
                )
              : InterMedium(
                  text: text,
                  fontsize: fontsize,
                  color: color,
                ),
        )
      ],
    );
  }
}
