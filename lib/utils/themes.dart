import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/utils/colors.dart';

var ligthTheme = ThemeData(
  scaffoldBackgroundColor: LightColor.Secondarycolor,
  brightness: Brightness.light,
  cardColor: LightColor.WidgetColor,
  primaryColor: LightColor.Primarycolor,
  appBarTheme: AppBarTheme(
    backgroundColor: LightColor.AppBarcolor,
    elevation: 5,
    shadowColor: LightColor.color3.withOpacity(.1),
    iconTheme: IconThemeData(
      color: LightColor.color3,
      size: 24.sp,
    ),
    titleTextStyle: TextStyle(
      color: LightColor.color3,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: -.3,
    ),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: LightColor.color3,
    ),
    bodySmall: TextStyle(
      color: LightColor.color3,
    ),
  ),
);

var darkTheme = ThemeData(
  scaffoldBackgroundColor: DarkColor.Secondarycolor,
  brightness: Brightness.dark,
  cardColor: DarkColor.WidgetColor,
  primaryColor: DarkColor.Primarycolor,
  appBarTheme: AppBarTheme(
    backgroundColor: DarkColor.AppBarcolor,
    elevation: 0,
    iconTheme: IconThemeData(
      color: DarkColor.Primarycolor,
      size: 24.sp,
    ),
    titleTextStyle: TextStyle(
      color: DarkColor.Primarycolor,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: -.3,
    ),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: DarkColor.color1,
    ),
    bodySmall: TextStyle(
      color: DarkColor.Primarycolor,
    ),
  ),
);
