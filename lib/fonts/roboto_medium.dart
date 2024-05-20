import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RobotoMedium extends StatelessWidget {
  const RobotoMedium({super.key, this.fontsize, required this.text, this.color, this.maxLines});

  final double? fontsize;
  final String text;
  final Color? color;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
      GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: fontsize , color: color),
      overflow: TextOverflow.clip,
      maxLines: maxLines,
    );
  }
}
