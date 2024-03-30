import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/utils/colors.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({super.key, this.icon, this.useSVG = false, this.svg});

  final IconData? icon;
  final String? svg;
  final bool useSVG;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color21),
      child: Center(
        child: useSVG
            ? SvgPicture.asset(svg!)
            : Icon(
                icon,
                size: 24,
                color: color20,
              ),
      ),
    );
  }
}
