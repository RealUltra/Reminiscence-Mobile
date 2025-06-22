import 'dart:ui';

import 'package:flutter/material.dart';

class DropdownController {
  late int _selected;
  final List<VoidCallback> _listeners = [];

  DropdownController({int initialValue = 0}) {
    _selected = initialValue;
  }

  int get selected => _selected;

  set selected(value) {
    _selected = value;
    _notifyListeners();
  }

  void setSelectedQuietly(int value) {
    _selected = value;
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
