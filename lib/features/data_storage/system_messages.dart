import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const systemMessagesKey = 'systemMessages';

List<String> getSystemMessagesSync(SharedPreferences prefs) {
  String systemMessagesJson = prefs.getString(systemMessagesKey) ?? "[]";
  List<String> systemMessages = jsonDecode(systemMessagesJson).cast<String>();
  return systemMessages;
}

Future<List<String>> getSystemMessages() async {
  final prefs = await SharedPreferences.getInstance();
  return getSystemMessagesSync(prefs);
}
