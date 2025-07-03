import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_storage/pinned_messages.dart'
    as data_storage;
import 'package:shared_preferences/shared_preferences.dart';

class PinnedMessagesProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  PinnedMessagesProvider({required this.prefs});

  List<String> get pinnedMessages {
    return data_storage.getPinnedMessagesSync(prefs);
  }

  Future<void> setPinnedMessages(List<String> pinnedMessages) async {
    await prefs.setString("pinnedMessages", jsonEncode(pinnedMessages));
    notifyListeners();
  }

  Future<void> pinMessage(String messageId) async {
    final pinnedMessages = this.pinnedMessages;

    if (!pinnedMessages.contains(messageId)) {
      pinnedMessages.add(messageId);
    }

    await setPinnedMessages(pinnedMessages);
  }

  Future<void> unpinMessage(String messageId) async {
    final pinnedMessages = this.pinnedMessages;

    if (pinnedMessages.contains(messageId)) {
      pinnedMessages.remove(messageId);
    }

    await setPinnedMessages(pinnedMessages);
  }

  bool isPinned(String messageId) {
    return pinnedMessages.contains(messageId);
  }
}
