// utils/color_utils.dart
import 'package:flutter/material.dart';

class ColorUtils {
  // Define available colors with their names
  static final Map<String, Color> colors = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.yellow,
    'Purple': Colors.purple,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
    'Teal': Colors.teal,
    'Brown': Colors.brown,
    'Cyan': Colors.cyan,
  };
  
  // Get a list of color names based on count
  static List<String> getColorNames(int count) {
    final names = colors.keys.toList();
    if (names.length > count) {
      return names.sublist(0, count);
    }
    return names;
  }
  
  // Get a list of color values based on count
  static List<Color> getColorValues(int count) {
    final values = colors.values.toList();
    if (values.length > count) {
      return values.sublist(0, count);
    }
    return values;
  }
  
  // Get a color by name
  static Color getColorByName(String name) {
    return colors[name] ?? Colors.grey;
  }
}