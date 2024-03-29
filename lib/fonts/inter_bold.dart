import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterBold extends StatelessWidget {
  const InterBold({super.key, this.fontsize, required this.text, this.color, this.letterSpacing});

  final double? fontsize;
  final double? letterSpacing;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: fontsize , color: color , letterSpacing: letterSpacing, ),
    );
  }
}
