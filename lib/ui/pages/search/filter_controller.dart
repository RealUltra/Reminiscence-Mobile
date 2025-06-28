import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/search/filter.dart';

class FilterController {
  late Map<String, Filter> _filters;
  final List<VoidCallback> _listeners = [];

  FilterController(this._filters);

  Map<String, Filter> get filters => _filters;

  set filters(Map<String, Filter> filters) {
    _filters = filters;
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
