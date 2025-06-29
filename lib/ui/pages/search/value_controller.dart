import 'dart:ui';

import 'package:flutter/material.dart';

class ValueController<T> {
  late T _value;
  final List<VoidCallback> _listeners = [];

  ValueController(T initialValue) {
    _value = initialValue;
  }

  T get value => _value;

  set value(T value) {
    _value = value;
    notifyListeners();
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
