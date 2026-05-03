import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const pinnedMessagesKey = 'pinnedMessages';

List<String> getPinnedMessagesSync(SharedPreferences prefs) {
  String pinnedMessagesJson = prefs.getString(pinnedMessagesKey) ?? "[]";
  List<String> pinnedMessages = jsonDecode(pinnedMessagesJson).cast<String>();
  return pinnedMessages;
}

Future<List<String>> getPinnedMessages() async {
  final prefs = await SharedPreferences.getInstance();
  return getPinnedMessagesSync(prefs);
}
