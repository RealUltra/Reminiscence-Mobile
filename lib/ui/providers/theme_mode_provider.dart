import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  ThemeModeProvider({required this.prefs});

  ThemeMode get themeMode {
    return _stringToThemeMode(themeModeValue);
  }

  String? get themeModeValue {
    return prefs.getString("theme");
  }

  Future<void> setThemeMode(String? themeModeValue) async {
    if (themeModeValue == null) {
      await prefs.remove("theme");
    } else {
      await prefs.setString("theme", themeModeValue);
    }

    notifyListeners();
  }

  ThemeMode _stringToThemeMode(String? value) {
    if (value == "dark") {
      return ThemeMode.dark;
    } else if (value == "light") {
      return ThemeMode.light;
    } else {
      return ThemeMode.system;
    }
  }
}
