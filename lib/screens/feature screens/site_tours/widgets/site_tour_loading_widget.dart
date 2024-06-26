import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:tact_tik/main.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';

class SiteTourLoadingWidget extends StatelessWidget {
  const SiteTourLoadingWidget(
      {super.key,});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            height: 470.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.r),
              color: Theme.of(context).canvasColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                      height: 70.h, 'assets/images/location_loader.json'),
                  Text(
                    'Getting your location...',
                    style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          )
        ]));
  }
}
