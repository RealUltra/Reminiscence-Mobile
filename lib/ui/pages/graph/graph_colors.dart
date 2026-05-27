import 'package:flutter/material.dart';

class GraphColors {
  static const light = <Color>[
    Color(0xFF0057D9),
    Color(0xFFD11F3F),
    Color(0xFF00875A),
    Color(0xFF8E44AD),
    Color(0xFFB35C00),
    Color(0xFF007A8A),
    Color(0xFF6F5E00),
    Color(0xFFC21875),
    Color(0xFF4E6E00),
    Color(0xFF5D5FEF),
    Color(0xFF8B2F00),
    Color(0xFF2F6F4E),
    Color(0xFFB0008E),
    Color(0xFF5A4FB3),
    Color(0xFF9A6A00),
    Color(0xFF0B6B84),
    Color(0xFFB33800),
    Color(0xFF1D7A2E),
    Color(0xFF9D2F5F),
    Color(0xFF3F6CC8),
  ];

  static const dark = <Color>[
    Color(0xFF7CB7FF),
    Color(0xFFFF7A8A),
    Color(0xFF5FE0A3),
    Color(0xFFD6A3FF),
    Color(0xFFFFB45C),
    Color(0xFF65DDE6),
    Color(0xFFE7D85B),
    Color(0xFFFF8FD2),
    Color(0xFFA8E063),
    Color(0xFF9EA7FF),
    Color(0xFFFF9F7A),
    Color(0xFF8EE6BF),
    Color(0xFFFF7BE5),
    Color(0xFFC3B8FF),
    Color(0xFFFFD36D),
    Color(0xFF75D2FF),
    Color(0xFFFF8C5F),
    Color(0xFF7FEA77),
    Color(0xFFFF8EBA),
    Color(0xFF89AFFF),
  ];

  static List<Color> forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }

  static Color getColor(Brightness brightness, int index) {
    final colors = forBrightness(brightness);
    return colors[index % colors.length];
  }
}
