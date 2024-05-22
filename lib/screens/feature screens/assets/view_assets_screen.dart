import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/main.dart';

import '../../../common/sizes.dart';
import '../../../common/widgets/setTextfieldWidget.dart';
import '../../../utils/colors.dart';
import '../visitors/widgets/setTimeWidget.dart';

class ViewAssetsScreen extends StatelessWidget {
  ViewAssetsScreen({super.key});

  Future<TimeOfDay?> showCustomTimePicker(BuildContext context) async {
    TimeOfDay? selectedTime;

    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: DarkColor. Primarycolor, // Change primary color to red
              secondary: DarkColor. Primarycolor,
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime;
  }

/*
  void _selectTime(BuildContext context, bool isStartTime) async {
    final selectedTime = await showCustomTimePicker(context);
    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          InTime = selectedTime;
        } else {
          OutTime = selectedTime;
        }
      });
      print('InTime: $InTime');
      print('OutTime: $OutTime');
    }
  }
*/
/*
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ));
  }
*/

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height / height30),
            InterBold(
              text: 'Allocation Date',
              color: isDark ? DarkColor.Primarycolor : LightColor.color3,
              fontsize: width / width20,
            ),
            SizedBox(height: height / height30),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: height / height60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width10),
                      color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InterMedium(text: '21 / 04 / 2024',
                          fontsize: width / width16,
                          color: isDark
                              ? DarkColor.color2
                              : LightColor.color3,),
                        SvgPicture.asset('assets/images/calendar_clock.svg',
                          width: width / width20,)
                      ],
                    ),
                  ),
                ),
                SizedBox(width: width / width6),
                Expanded(
                  child: Container(
                    height: height / height60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / width10),
                      color: isDark
                          ? DarkColor.WidgetColor
                          : LightColor.WidgetColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InterMedium(text: '22 / 04 / 2024',
                          fontsize: width / width16,
                          color: isDark
                              ? DarkColor.color2
                              : LightColor.color3,),
                        SvgPicture.asset('assets/images/calendar_clock.svg',
                          width: width / width20,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height / height30),
            InterBold(text: 'Equipment' , color: isDark ? DarkColor.color1 : LightColor.color3,fontsize: width / width16,),
            SizedBox(height: height / height20),
            Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / width10),
                  color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: width / width10),
                  InterMedium(text: 'Suit' , color: isDark
                        ? DarkColor.color2
                        : LightColor.color3,fontsize: width / width16,),
                ],
              ),
            ),
            SizedBox(height: height / height12),
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width / width10),
                color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: width / width10),
                  InterMedium(text: 'Suit' , color: isDark
                        ? DarkColor.color2
                        : LightColor.color3,fontsize: width / width16,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
