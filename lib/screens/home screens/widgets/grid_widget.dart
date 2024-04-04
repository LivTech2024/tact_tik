import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../common/sizes.dart';
import '../../../fonts/inter_bold.dart';
import '../../../utils/colors.dart';

class gridWidget extends StatelessWidget {
  const gridWidget({super.key, required this.img, required this.tittle});
  final String img;
  final String tittle;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment:
      //     MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: height / height80,
          width: width / width80,
          decoration: BoxDecoration(
            color: WidgetColor,
            borderRadius: BorderRadius.circular(width / width18),
          ),
          child: Center(
            child: SizedBox(
              height: height/ height40,
              width: width / width40,
              child: Image.asset(img),
            ),
          ),
        ),
        SizedBox(height: height / height10),
        InterBold(
          text: tittle,
          color: color25,
          fontsize: width / width16,
          letterSpacing: -0.3,
        ),
      ],
    );
  }
}
