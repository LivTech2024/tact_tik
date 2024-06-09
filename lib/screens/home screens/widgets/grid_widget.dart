import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../utils/colors.dart';

class gridWidget extends StatelessWidget {
  const gridWidget({super.key, required this.img, required this.tittle});
  final String img;
  final String tittle;

  @override
  Widget build(BuildContext context) {
    // final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment:
          MainAxisAlignment.start,
      children: [
        Container(
          height: 100.h,
          width: 100.w,
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Center(
            child: SizedBox(
              height: 50.h,
              width: 60.h,
              child: Image.asset(img),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        InterBold(
          text: tittle,
          color: isDark? DarkColor.color25:LightColor.color3,
          fontsize: 16.sp,
          letterSpacing: -0.3,
        ),
      ],
    );
  }
}
