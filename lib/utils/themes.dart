import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tact_tik/utils/colors.dart';

var ligthTheme = ThemeData(
    scaffoldBackgroundColor: LightColor.Secondarycolor,
    brightness: Brightness.light,
    canvasColor: LightColor.Secondarycolor,
    cardColor: LightColor.WidgetColor,
    primaryColor: LightColor.Primarycolor,
    primaryColorLight: LightColor.Primarycolorlight,
    hintColor: LightColor.color1,
    highlightColor: LightColor.color2,
    hoverColor: LightColor.color1,
    progressIndicatorTheme:
    ProgressIndicatorThemeData(color: LightColor.Primarycolor),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      iconSize: 24.sp,
      backgroundColor: LightColor.Primarycolor,
      shape: CircleBorder(),
    ),
    iconTheme: IconThemeData(color: LightColor.Secondarycolor),
    appBarTheme: AppBarTheme(
      backgroundColor: LightColor.AppBarcolor,
      elevation: 5,
      shadowColor: LightColor.color3.withOpacity(.5),
      iconTheme: IconThemeData(
        color: LightColor.color3,
        size: 24.sp,
      ),
      titleTextStyle: TextStyle(
        color: LightColor.color3,
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: -.3,
      ),
    ),
    focusColor: LightColor.color3,
    shadowColor: LightColor.color3.withOpacity(.1),

    textTheme: const TextTheme(
      titleMedium: TextStyle(
        color: DarkColor.color15,
      ),
      headlineSmall: TextStyle(
        color: LightColor.color3,
      ),
      labelMedium: TextStyle(
        color: LightColor.color3,
      ),
      labelSmall: TextStyle(
        color: LightColor.color3,
      ),
      displayLarge: TextStyle(
        color: LightColor.color3,
      ),
      displayMedium: TextStyle(
        color: LightColor.color3,
      ),
      displaySmall: TextStyle(
        color: LightColor.color3,
      ),
      bodyLarge: TextStyle(
        color: LightColor.color3,
      ),
      bodyMedium: TextStyle(
        color: LightColor.color3,
      ),
      bodySmall: TextStyle(
        color: LightColor.color3,
      ),
      titleSmall: TextStyle(
        color: LightColor.color3,
      ),
      headlineLarge: TextStyle(
        color: LightColor.color3,
      ),
      headlineMedium: TextStyle(
        color: LightColor.color3,
      ),
      titleLarge: TextStyle(
        color: LightColor.color3,
      ),
    ));

var darkTheme = ThemeData(
  scaffoldBackgroundColor: DarkColor.Secondarycolor,
  brightness: Brightness.dark,
  cardColor: DarkColor.WidgetColor,
  canvasColor: DarkColor.Secondarycolor,
  primaryColor: DarkColor.Primarycolor,
  primaryColorLight: DarkColor.Primarycolorlight,
  hintColor: DarkColor.color24,
  highlightColor: DarkColor.color25,
  hoverColor: DarkColor.color22,
  progressIndicatorTheme:
  ProgressIndicatorThemeData(color: DarkColor.Primarycolor),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    iconSize: 24.sp,
    backgroundColor: DarkColor.Primarycolor,
    shape: CircleBorder(),
  ),
  iconTheme: IconThemeData(color: DarkColor.color11),
  appBarTheme: AppBarTheme(
    backgroundColor: DarkColor.AppBarcolor,
    elevation: 0,
    iconTheme: IconThemeData(
      color: DarkColor.color5,
      size: 24.sp,
    ),
    titleTextStyle: TextStyle(
      color: DarkColor.color5,
      fontSize: 18.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: -.3,
    ),
  ),
  shadowColor: Colors.transparent,
  focusColor: DarkColor.color4,
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: DarkColor.color16,
    ),
    titleMedium: TextStyle(
      color: DarkColor.color15,
    ),
    titleSmall: TextStyle(
      color: DarkColor.color5,
    ),
    headlineLarge: TextStyle(
      color: DarkColor.color14,
    ),
    headlineMedium: TextStyle(
      color: DarkColor.color5,
    ),
    headlineSmall: TextStyle(
      color: DarkColor.color3,
    ),
    labelMedium: TextStyle(
      color: DarkColor.color10,
    ),
    labelSmall: TextStyle(
      color: DarkColor.color8,
    ),
    displayLarge: TextStyle(
      color: DarkColor.color12,
    ),
    displayMedium: TextStyle(
      color: DarkColor.color17,
    ),
    displaySmall: TextStyle(
      color: DarkColor.color21,
    ),
    bodyLarge: TextStyle(
      color: DarkColor.color2,
    ),
    bodyMedium: TextStyle(
      color: DarkColor.color1,
    ),
    bodySmall: TextStyle(
      color: DarkColor.color5,
    ),
  ),
);
