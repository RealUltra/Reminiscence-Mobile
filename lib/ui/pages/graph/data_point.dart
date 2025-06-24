import 'dart:math';

import 'package:flutter/material.dart';

class DataPoint {
  static final colors = <Color>[
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.deepOrange,
    Colors.deepPurpleAccent,
    Colors.pink,
  ];

  final String x;
  final int y;

  const DataPoint(this.x, this.y);

  static void shuffleColors() {
    colors.shuffle();
  }

  static Color getColor(int index) {
    if (index >= colors.length) {
      final newColor = Color(
        (Random().nextDouble() * 0xFFFFFF).toInt(),
      ).withAlpha(255);
      colors.add(newColor);
    }

    return colors[index];
  }
}
