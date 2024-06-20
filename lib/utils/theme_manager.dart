import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  late SharedPreferences storage;

  get themeMode => _themeMode;

  void toggleTheme() async {
    storage = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.dark) {
      storage.setBool('isDark', true);
      _themeMode = ThemeMode.light;
    } else {
      storage.setBool('isDark', false);
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  init() async {
    storage = await SharedPreferences.getInstance();
    bool isDark = storage.getBool('isDark') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
