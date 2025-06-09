import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData _baseTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
    );
  }

  static final light = _baseTheme(Brightness.light);
  static final dark = _baseTheme(Brightness.dark);
}
