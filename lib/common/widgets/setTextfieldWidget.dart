import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/main.dart';
import '../sizes.dart';
import '../../utils/colors.dart';

class SetTextfieldWidget extends StatefulWidget {
  const SetTextfieldWidget({
    Key? key,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.isEnabled = true,
    required this.enabled, // Add 'enabled' parameter
    required this.isEditMode, // Add 'isEditMode' parameter
    this.inputFormatters,
    this.maxlength,
  }) : super(key: key);

  final String hintText;
  final int? maxlength;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isEnabled;
  final bool enabled;
  final bool isEditMode;

  final List<TextInputFormatter>? inputFormatters;

  @override
  State<SetTextfieldWidget> createState() => _SetTextfieldWidgetState();
}

class _SetTextfieldWidgetState extends State<SetTextfieldWidget> {
  @override
  Widget build(BuildContext context) {
    final bool shouldDisable = widget.isEditMode
        ? !widget.enabled // Disable based on 'enabled' in edit mode
        : widget.hintText.toLowerCase().contains(
            'asset return'); // Disable if "Asset Return" when creating a new visitor

    return Container(
      height: 60.h,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : LightColor.color3.withOpacity(.05),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
       borderRadius: BorderRadius.circular(10.r),
        color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
      ),
      margin: EdgeInsets.only(top: 10.h),
      child: Center(
        child: TextField(
          maxLength: widget.maxlength,
          keyboardType: widget.keyboardType,
          enabled: !shouldDisable,
          // Enable or disable TextField based on shouldDisable
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w300,
             fontSize: 18.sp,
            color: isDark ? DarkColor.color1 : LightColor.color3,
          ),
          onSubmitted: (value) {
            setState(() {
              widget.controller!.text = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(
                Radius.circular(10.r),
              ),
            ),
            focusedBorder: InputBorder.none,
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
       fontSize: 18.sp,
              color: isDark ? DarkColor.color2 : LightColor.color3,
            ),
            hintText: widget.hintText,
            contentPadding: EdgeInsets.zero,
          ),
          cursorColor: isDark ? DarkColor.Primarycolor : LightColor.Primarycolor,
          controller: widget.controller,
          inputFormatters: widget.inputFormatters,
        ),
      ),
    );
  }
}
