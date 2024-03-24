import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoppinsLight extends StatelessWidget {
  const PoppinsLight({super.key, this.fontsize, required this.text, this.color, this.textAlign});

  final double? fontsize;
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.poppins(fontWeight: FontWeight.w300, fontSize: fontsize , color: color , ),
      textAlign: textAlign,
    );
  }
}
