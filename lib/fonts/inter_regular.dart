import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InterRegular extends StatelessWidget {
  const InterRegular(
      {super.key,
      this.fontsize,
      required this.text,
      this.color,
      this.letterSpacing, this.maxLines});

  final double? fontsize;
  final double? letterSpacing;
  final int? maxLines;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: fontsize,
        color: color,
        letterSpacing: letterSpacing,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
