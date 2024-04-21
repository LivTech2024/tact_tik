import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/sizes.dart';
import '../../../../utils/colors.dart';

class SetTextfieldWidget extends StatelessWidget {
  const SetTextfieldWidget({super.key, required this.hintText, this.controller, this.keyboardType});
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;


    return Container(
      height: height / height60,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: width / width20),
      decoration: BoxDecoration(
        // color: Colors.redAccent,
        borderRadius: BorderRadius.circular(width / width10),
        color: WidgetColor,
      ),
      margin: EdgeInsets.only(top: height / height10),
      child:  Expanded(
        child: Center(
          child: TextField(
            keyboardType: keyboardType,
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
              hintText: hintText,
              contentPadding: EdgeInsets.zero, // Remove padding
            ),
            cursorColor: Primarycolor,
          ),
        ),
      ),
    );
  }
}
