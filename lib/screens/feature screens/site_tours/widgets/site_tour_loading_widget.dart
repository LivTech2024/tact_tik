import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SiteTourLoadingWidget extends StatelessWidget {
  const SiteTourLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(height: 70, 'assets/images/location_loader.json'),
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
    );
  }
}
