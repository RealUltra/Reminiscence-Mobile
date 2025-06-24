import 'dart:ui';

import 'package:flutter/material.dart';

class SelectionController<T> {
  late T _selected;
  final List<VoidCallback> _listeners = [];

  SelectionController(T initialValue) {
    _selected = initialValue;
  }

  T get selected => _selected;

  set selected(T value) {
    _selected = value;
    notifyListeners();
  }

  void setSelectedQuietly(T value) {
    _selected = value;
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
