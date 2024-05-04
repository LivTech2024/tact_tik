import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  }) : super(key: key);

  final String hintText;
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    final bool shouldDisable = widget.isEditMode
        ? !widget.enabled // Disable based on 'enabled' in edit mode
        : widget.hintText.toLowerCase().contains(
            'asset return'); // Disable if "Asset Return" when creating a new visitor

    return Container(
      height: height / height60,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: width / width20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width / width10),
        color: WidgetColor,
      ),
      margin: EdgeInsets.only(top: height / height10),
      child: Center(
        child: TextField(
          keyboardType: widget.keyboardType,
          enabled:
              !shouldDisable, // Enable or disable TextField based on shouldDisable
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w300,
            fontSize: width / width18,
            color: Colors.white,
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
                Radius.circular(width / width10),
              ),
            ),
            focusedBorder: InputBorder.none,
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
              fontSize: width / width18,
              color: color2,
            ),
            hintText: widget.hintText,
            contentPadding: EdgeInsets.zero,
          ),
          cursorColor: Primarycolor,
          controller: widget.controller,
          inputFormatters: widget.inputFormatters,
        ),
      ),
    );
  }
}
