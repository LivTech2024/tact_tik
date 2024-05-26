import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterBold extends StatelessWidget {
  const InterBold({super.key, this.fontsize, required this.text, this.color, this.letterSpacing, this.maxLine, this.textAlign});

  final double? fontsize;
  final double? letterSpacing;
  final int? maxLine;
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: fontsize , color: color , letterSpacing: letterSpacing, ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }
}
