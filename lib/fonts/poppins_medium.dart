import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoppinsMedium extends StatelessWidget {
  const PoppinsMedium({super.key, this.fontsize, required this.text, this.color});

  final double? fontsize;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: fontsize , color: color),
    );
  }
}
