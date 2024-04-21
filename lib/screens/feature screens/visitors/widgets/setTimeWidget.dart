import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class SetTimeWidget extends StatelessWidget {
  SetTimeWidget({
    super.key,
    required this.hintText,
    this.controller,
    required this.onTap,
    this.flex = 1,
  });

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback onTap;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width / width20),
        height: height / height60,
        width: double.maxFinite,
        decoration: BoxDecoration(
          // color: Colors.redAccent,
          borderRadius: BorderRadius.circular(width / width10),
          color: WidgetColor,
        ),
        // margin: EdgeInsets.only(top: height / height10 ,),
        child: Center(
          child: GestureDetector(
            onTap: onTap,
            child: InterMedium(
              text: hintText,
              fontsize: width / width18,
              color: color25,
            ),
          ),
        ),
      ),
    );
  }
}
