import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../../common/sizes.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({super.key, this.icon, this.useSVG = false, this.svg});

  final IconData? icon;
  final String? svg;
  final bool useSVG;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      height: height / height48,
      width: width / width48,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color21),
      child: Center(
        child: useSVG
            ? SvgPicture.asset(svg!)
            : Icon(
                icon,
                size: width / width24,
                color: color20,
              ),
      ),
    );
  }
}
