import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return Container(
      height: 74.h,
      width: 74.w,
      decoration: BoxDecoration(
        color: WidgetColor,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          useSVG
              ? SvgPicture.asset(
                  SVG!,
                  color: color,
                  height: 24.h,
                  width: 24.w,
                )
              : Icon(
                  icon,
                  size: 24.sp,
                  color: color,
                ),
          SizedBox(height: 10.h),
          InterMedium(
            text: text,
            fontsize: 12.sp,
            color: textcolor,
          )
        ],
      ),
    );
  }
}
