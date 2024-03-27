import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterLight extends StatelessWidget {
  const InterLight({super.key, this.fontsize, required this.text, this.color, this.textAlign});

  final double? fontsize;
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.inter(fontWeight: FontWeight.w300, fontSize: fontsize , color: color , ),
      textAlign: textAlign,
    );
  }
}
