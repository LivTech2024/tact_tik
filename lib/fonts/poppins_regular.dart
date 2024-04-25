import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoppinsRegular extends StatelessWidget {
  const PoppinsRegular({super.key, this.fontsize, required this.text, this.color, this.textAlign, this.letterSpacing});

  final double? fontsize;
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: fontsize , color: color ,letterSpacing: letterSpacing,),
      textAlign: textAlign,
    );
  }
}
