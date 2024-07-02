import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ContactWidget extends StatelessWidget {
  const ContactWidget({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color:Theme.of(context).shadowColor,
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(0, 3),
          )
        ],
        borderRadius: BorderRadius.circular(10.r),
        color: Theme.of(context).cardColor,
      ),
      margin: EdgeInsets.only(top: 10.h),
      child: Center(
        child: InternationalPhoneNumberInput(

          textAlignVertical: TextAlignVertical.top,
          cursorColor:
          Theme.of(context).primaryColor,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w300,
            fontSize: 18.sp,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
          scrollPadding: EdgeInsets.zero,
          textAlign: TextAlign.start,
          onInputChanged: (PhoneNumber number) {
            print(number.phoneNumber);
          },
          onInputValidated: (bool value) {
            print(value);
          },
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            useBottomSheetSafeArea: true,
          ),
          // ignoreBlank: false,
          autoValidateMode: AutovalidateMode.disabled,
          selectorTextStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w300,
            fontSize: 18.sp,
            color:
            Theme.of(context).textTheme.bodyMedium!.color,
          ),
          inputDecoration: InputDecoration(
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
                  .color,
            ),
            hintText: 'Contact Number',
            contentPadding: EdgeInsets.zero,
            // counterText: "",
          ),
          initialValue: PhoneNumber(isoCode: 'CA'),
          textFieldController: controller,
          formatInput: true,
          keyboardType: TextInputType.numberWithOptions(
              signed: true, decimal: false),
          inputBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(
              Radius.circular(10.r),
            ),
          ),
          onSaved: (PhoneNumber number) {
            print('On Saved: $number');
          },
        ),
      ),
    );
  }
}
