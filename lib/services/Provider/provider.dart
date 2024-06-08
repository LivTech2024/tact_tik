import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UIProvider extends GetxController {
  var isDark = false;

  void changeTheme(stete) {
    if (stete == 'true') {
      isDark = true;
      Get.changeTheme(ThemeData.dark());
    } else {
      isDark = false;
    }
    update();
  }
}
