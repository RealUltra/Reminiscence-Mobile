import 'package:shared_preferences/shared_preferences.dart';

String getKey(String filename) {
  return "file_opened_$filename";
}

Future<bool> hasBeenOpened(String filename) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final key = getKey(filename);
  return prefs.getBool(key) ?? false;
}

Future<void> markAsOpened(String filename) async {
  final prefs = await SharedPreferences.getInstance();
  final key = getKey(filename);
  await prefs.setBool(key, true);
}

Future<void> markAsNotOpened(String filename) async {
  final prefs = await SharedPreferences.getInstance();
  final key = getKey(filename);
  await prefs.setBool(key, false);
}