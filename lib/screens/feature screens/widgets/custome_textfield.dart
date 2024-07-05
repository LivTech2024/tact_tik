import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/main.dart';

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
    this.textInputType,
    this.maxlength,
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

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        top: 5.h,
        bottom: 5.h,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      constraints: isExpanded
          ? BoxConstraints()
          : BoxConstraints(
              minHeight: 60.h,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              onTapOutside: (event) {
                print('onTapOutside');
                FocusManager.instance.primaryFocus?.unfocus();
              },
              maxLength: maxlength,
              controller: controller,
              maxLines: isExpanded ? null : 1,
              // keyboardType: Key,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w300,
                fontSize: 18.sp,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .color, // Change text color to white
              ),
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
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color, // Change text color to white
                ),
                hintText: hint,
                contentPadding: EdgeInsets.zero,
                // Remove padding
                counterText: '',
              ),
              keyboardType: textInputType,
              cursorColor: DarkColor.Primarycolor,
              enabled: isEnabled,
            ),
          ),
          if (showIcon)
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.mic,
                color: DarkColor.color33,
                size: 24.sp,
              ),
            )
        ],
      ),
    );
  }
}
