import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class SupervisorCustomNavigation extends StatefulWidget {
  const SupervisorCustomNavigation(
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
  State<SupervisorCustomNavigation> createState() =>
      _HomeScreenCustomNavigationState();
}

class _HomeScreenCustomNavigationState
    extends State<SupervisorCustomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68.h,
      width: 68.w,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 1,
            offset: Offset(0, 3),
          )
        ],
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.useSVG
              ? SvgPicture.asset(
                  widget.SVG!,
                  color: widget.color,
                  height: 22.h,
                  width: 22.w,
                )
              : Icon(
                  widget.icon,
                  size: 22.sp,
                  color: widget.color,
                ),
          SizedBox(height: 10.h),
          InterMedium(
            text: widget.text,
            fontsize: 12.sp,
            color: widget.textcolor,
          )
        ],
      ),
    );
  }
}
