import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_storage/pinned_messages.dart'
    as data_storage;
import 'package:shared_preferences/shared_preferences.dart';

class PinnedMessagesProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  PinnedMessagesProvider({required this.prefs});

  List<String> get pinnedMessages {
    String pinnedMessagesJson = prefs.getString('pinnedMessages') ?? "[]";
    List<String> pinnedMessages = jsonDecode(pinnedMessagesJson).cast<String>();
    return pinnedMessages;
  }

  set pinnedMessages(List<String> pinnedMessages) {
    prefs
        .setString("pinnedMessages", jsonEncode(pinnedMessages))
        .then((_) => notifyListeners());
  }

  Future<void> pinMessage(String messageId) async {
    await data_storage.pinMessage(messageId);
    notifyListeners();
  }

  Future<void> unpinMessage(String messageId) async {
    await data_storage.unpinMessage(messageId);
    notifyListeners();
  }
}
