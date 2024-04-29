import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterMedium extends StatelessWidget {
  const InterMedium({super.key, this.fontsize, required this.text, this.color, this.textAlign, this.maxLines, this.letterSpacing});

  final double? fontsize;
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: fontsize , color: color , letterSpacing: letterSpacing, ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
