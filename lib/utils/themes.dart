import 'package:flutter/material.dart';
import 'package:tact_tik/utils/colors.dart';

var ligthTheme=ThemeData(
    canvasColor: LightColor.Secondarycolor,
    cardColor: LightColor.WidgetColor,
    primaryColor: LightColor.Primarycolor,
    appBarTheme: AppBarTheme(
      backgroundColor: LightColor.AppBarcolor,
      elevation: 5,
      shadowColor: LightColor.color3.withOpacity(.1),
      iconTheme: IconThemeData(
        color: LightColor.color3,
      ),
      titleTextStyle: TextStyle(
        color: LightColor.color3,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
 );
var darkTheme=ThemeData(
    canvasColor: DarkColor.Secondarycolor,
    cardColor: DarkColor.WidgetColor,
    primaryColor: DarkColor.Primarycolor,
    appBarTheme: AppBarTheme(
      backgroundColor: DarkColor.AppBarcolor,
      elevation: 0,

      iconTheme: IconThemeData(
        color: DarkColor.Primarycolor,
      ),
      titleTextStyle: TextStyle(
      color: DarkColor.Primarycolor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
      
    ),

  );