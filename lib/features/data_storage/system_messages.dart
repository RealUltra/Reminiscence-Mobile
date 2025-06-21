import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> getSystemMessages({SharedPreferences? prefs}) async {
  prefs ??= await SharedPreferences.getInstance();

  String systemMessagesJson = prefs.getString('systemMessages') ?? "[]";
  List<String> systemMessages = jsonDecode(systemMessagesJson).cast<String>();

  return systemMessages;
}

Future<void> markAsSystemMessage(String content) async {
  /* Content must have no emojis and be completely lowercase */

  final prefs = await SharedPreferences.getInstance();

  final systemMessages = await getSystemMessages(prefs: prefs);

  if (!systemMessages.contains(content)) {
    systemMessages.add(content);
  }

  await setSystemMessages(systemMessages, prefs: prefs);
}

Future<void> unmarkAsSystemMessage(String content) async {
  final prefs = await SharedPreferences.getInstance();

  final systemMessages = await getSystemMessages(prefs: prefs);

  if (systemMessages.contains(content)) {
    systemMessages.remove(content);
  }

  await setSystemMessages(systemMessages, prefs: prefs);
}

Future<bool> isSystemMessage(String content) async {
  final systemMessages = await getSystemMessages();
  return systemMessages.contains(content);
}

Future<void> setSystemMessages(
  List<String> systemMessages, {
  SharedPreferences? prefs,
}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.setString("systemMessages", jsonEncode(systemMessages));
}
