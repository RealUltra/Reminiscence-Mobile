import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart'
    as data_storage;
import 'package:shared_preferences/shared_preferences.dart';

class SystemMessagesProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  SystemMessagesProvider({required this.prefs});

  List<String> get systemMessages {
    return data_storage.getSystemMessagesSync(prefs);
  }

  Future<void> setSystemMessages(List<String> systemMessages) async {
    await prefs.setString("systemMessages", jsonEncode(systemMessages));
    notifyListeners();
  }

  Future<void> markAsSystem(String content) async {
    final systemMessages = this.systemMessages;

    if (!systemMessages.contains(content)) {
      systemMessages.add(content);
    }

    await setSystemMessages(systemMessages);
  }

  Future<void> unmarkAsSystem(String content) async {
    final systemMessages = this.systemMessages;

    if (systemMessages.contains(content)) {
      systemMessages.remove(content);
    }

    await setSystemMessages(systemMessages);
  }

  bool isSystemMessage(String content) {
    return systemMessages.contains(content);
  }
}
