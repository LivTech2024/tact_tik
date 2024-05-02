import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class SetTimeWidget extends StatelessWidget {
  SetTimeWidget({
    Key? key, // Add 'key' parameter here
    required this.hintText,
    this.controller,
    required this.onTap,
    this.flex = 1,
    this.isEnabled = true,
  }) : super(key: key); // Call super constructor with key parameter

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback onTap;
  final int flex;
  final bool isEnabled;

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
          borderRadius: BorderRadius.circular(width / width10),
          color: WidgetColor,
        ),
        child: Center(
          child: IgnorePointer(
            ignoring: !isEnabled,
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
      ),
    );
  }
}
