import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/sizes.dart';
import '../../../utils/colors.dart';

class CustomeTextField extends StatelessWidget {
  const CustomeTextField({
    super.key,
    required this.hint,
    this.isExpanded = false,
    this.showIcon = true,
    this.isEnabled = true,
    this.controller,
    this.textInputType, this.maxlength,
  });

  final String hint;
  final int? maxlength;
  final bool isExpanded;
  final bool showIcon;
  final bool isEnabled;
  final TextInputType? textInputType;

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.only(
        left: width / width20,
        top: height / height5,
        bottom: height / height5,
      ),
      decoration: BoxDecoration(
        color: WidgetColor,
        borderRadius: BorderRadius.circular(width / width10),
      ),
      constraints: isExpanded
          ? BoxConstraints()
          : BoxConstraints(
              minHeight: height / height60,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              maxLength: maxlength,
              controller: controller,
              maxLines: isExpanded ? null : 1,
              // keyboardType: Key,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontSize: width / width18,
                color: Colors.white, // Change text color to white
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(
                    Radius.circular(width / width10),
                  ),
                ),
                focusedBorder: InputBorder.none,
                hintStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w300,
                  fontSize: width / width18,
                  color: color2, // Change text color to white
                ),
                hintText: hint,
                contentPadding: EdgeInsets.zero, // Remove padding
              ),
              keyboardType: textInputType,
              cursorColor: Primarycolor,
              enabled: isEnabled,
            ),
          ),
          if (showIcon)
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.mic,
                color: color33,
                size: width / width24,
              ),
            )
        ],
      ),
    );
  }
}
