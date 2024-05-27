import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';

class SiteTourLoadingWidget extends StatelessWidget {
  final double height;
  final double width;
  const SiteTourLoadingWidget(
      {super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: width / width30),
        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            height: height / height470,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width / width40),
              color: Secondarycolor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                      height: 70, 'assets/images/location_loader.json'),
                  Text(
                    'Getting your location...',
                    style: GoogleFonts.inter(
                        color: const Color(0xffD0D0D0),
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
          )
        ]));
  }
}
