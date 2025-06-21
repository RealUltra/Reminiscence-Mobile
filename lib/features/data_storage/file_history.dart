import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, int>> getFileHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final fileHistoryJson = prefs.getString("file_history") ?? "{}";
  final Map<String, int> fileHistory =
      jsonDecode(fileHistoryJson).cast<String, int>();
  return fileHistory;
}

Future<void> updateFileHistory(String filePath) async {
  final prefs = await SharedPreferences.getInstance();

  final fileHistory = await getFileHistory();

  final now = DateTime.now();
  fileHistory[filePath] = now.millisecondsSinceEpoch;

  prefs.setString("file_history", jsonEncode(fileHistory));
}
