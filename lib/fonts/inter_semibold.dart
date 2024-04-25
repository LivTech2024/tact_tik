import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterSemibold extends StatelessWidget {
  const InterSemibold(
      {super.key, this.fontsize, required this.text, this.color, this.letterSpacing, this.maxLines, this.textAlign});

  final double? fontsize;
  final String text;
  final Color? color;
  final double? letterSpacing;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: fontsize,
        color: color,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
