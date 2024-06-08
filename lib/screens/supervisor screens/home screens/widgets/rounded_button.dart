import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/sizes.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({super.key, this.icon, this.useSVG = false, this.svg});

  final IconData? icon;
  final String? svg;
  final bool useSVG;

  @override
  Widget build(BuildContext context) {


    return Container(
      height: 48.h,
      width: 48.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: DarkColor.color21),
      child: Center(
        child: useSVG
            ? SvgPicture.asset(svg!)
            : Icon(
                icon,
                size: 24.w,
                color: DarkColor.  color20,
              ),
      ),
    );
  }
}
