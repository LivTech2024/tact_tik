import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  late SharedPreferences storage;

  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    _loadThemeMode();
  }

  void toggleTheme() async {
    storage = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      storage.setBool('isDark', false);
    } else {
      _themeMode = ThemeMode.dark;
      storage.setBool('isDark', true);
    }
    notifyListeners();
  }

  void _loadThemeMode() async {
    storage = await SharedPreferences.getInstance();
    bool isDark = storage.getBool('isDark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
