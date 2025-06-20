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

Future<List<String>> getPinnedMessages() async {
  final prefs = await SharedPreferences.getInstance();

  String pinnedMessagesJson = prefs.getString('pinnedMessages') ?? "[]";
  List<String> pinnedMessages = jsonDecode(pinnedMessagesJson).cast<String>();

  return pinnedMessages;
}

Future<void> pinMessage(String messageId) async {
  final prefs = await SharedPreferences.getInstance();

  final pinnedMessages = await getPinnedMessages();

  if (!pinnedMessages.contains(messageId)) {
    pinnedMessages.add(messageId);
  }

  prefs.setString("pinnedMessages", jsonEncode(pinnedMessages));
}

Future<void> unpinMessage(String messageId) async {
  final prefs = await SharedPreferences.getInstance();

  final pinnedMessages = await getPinnedMessages();

  if (pinnedMessages.contains(messageId)) {
    pinnedMessages.remove(messageId);
  }

  prefs.setString("pinnedMessages", jsonEncode(pinnedMessages));
}

Future<bool> isPinned(String messageId) async {
  final pinnedMessages = await getPinnedMessages();
  return pinnedMessages.contains(messageId);
}
