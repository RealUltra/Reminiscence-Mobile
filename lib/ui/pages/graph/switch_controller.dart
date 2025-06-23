import 'dart:ui';

class SwitchController {
  late bool _value;
  final List<VoidCallback> _listeners = [];

  SwitchController({initialValue = false}) {
    _value = initialValue;
  }

  bool get value => _value;

  set value(bool value) {
    _value = value;
    _notifyListeners();
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

  void setValueQuietly(bool value) {
    this.value = value;
  }
}
