import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../utils/colors.dart';

class SetTimeWidget extends StatelessWidget {
  SetTimeWidget({
    Key? key,
    required this.hintText,
    this.controller,
    required this.onTap,
    this.flex = 1,
    this.isEnabled = false,
    required this.enabled,
    required this.isEditMode, // Add 'isEditMode' parameter
  }) : super(key: key);

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback onTap;
  final int flex;
  final bool isEnabled;
  final bool enabled;
  final bool isEditMode;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    final bool shouldIgnore =
        isEditMode ? !enabled : hintText.toLowerCase().contains('out');

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
            ignoring: shouldIgnore,
            child: GestureDetector(
              onTap: !shouldIgnore ? onTap : null,
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
