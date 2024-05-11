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
    bool isLight = Theme.of(context).brightness == Brightness.light;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment:
      //     MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: height / height100,
          width: width / width100,
          decoration: BoxDecoration(
            color: isLight ? color1 : WidgetColor,
            borderRadius: BorderRadius.circular(width / width18),
          ),
          child: Center(
            child: SizedBox(
              height: height/ height60,
              width: width / width60,
              child: Image.asset(img),
            ),
          ),
        ),
        SizedBox(height: height / height10),
        InterBold(
          text: tittle,
          color: isLight ? WidgetColor : color25,
          fontsize: width / width16,
          letterSpacing: -0.3,
        ),
      ],
    );
  }
}
