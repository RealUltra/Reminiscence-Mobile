import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _fileHistoryKey = "file_history";

Future<Map<String, int>> getFileHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final fileHistoryJson = prefs.getString(_fileHistoryKey) ?? "{}";
  final Map<String, int> fileHistory =
      jsonDecode(fileHistoryJson).cast<String, int>();
  return fileHistory;
}

Future<void> updateFileHistory(String filePath) async {
  final prefs = await SharedPreferences.getInstance();

  final fileHistory = await getFileHistory();

  final now = DateTime.now();
  fileHistory[filePath] = now.millisecondsSinceEpoch;

  prefs.setString(_fileHistoryKey, jsonEncode(fileHistory));
}
