import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_storage/system_messages.dart'
    as data_storage;
import 'package:shared_preferences/shared_preferences.dart';

class SystemMessagesProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  SystemMessagesProvider({required this.prefs});

  List<String> get systemMessages {
    String systemMessagesJson = prefs.getString('systemMessages') ?? "[]";
    List<String> systemMessages = jsonDecode(systemMessagesJson).cast<String>();
    return systemMessages;
  }

  set systemMessages(List<String> systemMessages) {
    prefs
        .setString("systemMessages", jsonEncode(systemMessages))
        .then((_) => notifyListeners());
  }

  Future<void> markAsSystem(String content) async {
    await data_storage.markAsSystemMessage(content);
    notifyListeners();
  }

  Future<void> unmarkAsSystem(String content) async {
    await data_storage.unmarkAsSystemMessage(content);
    notifyListeners();
  }
}
