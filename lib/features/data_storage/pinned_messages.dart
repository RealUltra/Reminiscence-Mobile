import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

List<String> getPinnedMessages(SharedPreferences prefs) {
  String pinnedMessagesJson = prefs.getString('pinnedMessages') ?? "[]";
  List<String> pinnedMessages = jsonDecode(pinnedMessagesJson).cast<String>();
  return pinnedMessages;
}

Future<void> pinMessage(String messageId) async {
  final prefs = await SharedPreferences.getInstance();

  final pinnedMessages = getPinnedMessages(prefs);

  if (!pinnedMessages.contains(messageId)) {
    pinnedMessages.add(messageId);
  }

  await setPinnedMessages(pinnedMessages, prefs: prefs);
}

Future<void> unpinMessage(String messageId) async {
  final prefs = await SharedPreferences.getInstance();

  final pinnedMessages = getPinnedMessages(prefs);

  if (pinnedMessages.contains(messageId)) {
    pinnedMessages.remove(messageId);
  }

  await setPinnedMessages(pinnedMessages, prefs: prefs);
}

Future<bool> isPinned(String messageId) async {
  final prefs = await SharedPreferences.getInstance();
  final pinnedMessages = getPinnedMessages(prefs);
  return pinnedMessages.contains(messageId);
}

Future<void> setPinnedMessages(
  List<String> pinnedMessages, {
  SharedPreferences? prefs,
}) async {
  prefs ??= await SharedPreferences.getInstance();
  await prefs.setString("pinnedMessages", jsonEncode(pinnedMessages));
}
