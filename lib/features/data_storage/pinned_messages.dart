import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

List<String> getPinnedMessagesSync(SharedPreferences prefs) {
  String pinnedMessagesJson = prefs.getString('pinnedMessages') ?? "[]";
  List<String> pinnedMessages = jsonDecode(pinnedMessagesJson).cast<String>();
  return pinnedMessages;
}

Future<List<String>> getPinnedMessages() async {
  final prefs = await SharedPreferences.getInstance();
  return getPinnedMessagesSync(prefs);
}
