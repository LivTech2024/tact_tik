import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoppinsSemibold extends StatelessWidget {
  const PoppinsSemibold(
      {super.key, this.fontsize, required this.text, this.color, this.letterSpacing});

  final double? fontsize;
  final String text;
  final Color? color;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        fontSize: fontsize,
        color: color,
          letterSpacing: letterSpacing,
      ),
    );
  }
}
