import 'package:flutter/material.dart';

class ThemeColors {
  static const Map<String, Color> colorMap = {
    'blue': Colors.blue,
    'red': Colors.red,
    'green': Colors.green,
    'purple': Colors.purple,
    'orange': Colors.orange,
  };

  static Color fromName(String name) {
    return colorMap[name] ?? Colors.blue;
  }
}
