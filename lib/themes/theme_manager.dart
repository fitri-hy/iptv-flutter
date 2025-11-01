import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_colors.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final colorName = prefs.getString('accentColor') ?? 'blue';
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _accentColor = ThemeColors.fromName(colorName);
    notifyListeners();
  }

  Future<void> updateTheme(bool isDark, String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    await prefs.setString('accentColor', colorName);

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _accentColor = ThemeColors.fromName(colorName);
    notifyListeners();
  }
}
