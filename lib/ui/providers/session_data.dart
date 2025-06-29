import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chat/message_reader.dart';

class SessionData extends ChangeNotifier {
  ReminiscenceData? _data;
  List<ChatDto>? _chats;
  ChatDto? _chat;
  MessageReader? _messageReader;

  ReminiscenceData? get data => _data;
  List<ChatDto>? get chats => _chats;
  ChatDto? get chat => _chat;
  MessageReader? get messageReader => _messageReader;

  void setData(ReminiscenceData data) {
    _data = data;
    notifyListeners();
  }

  Future<void> loadChats() async {
    _chats = await data!.db.chatDao.getChatDtos();
    notifyListeners();
  }

  void setChat(ChatDto chat) {
    _chat = chat;
    notifyListeners();
  }

  void loadMessageReader() {
    _messageReader = MessageReader(data: data!, chat: chat!);
    _messageReader!.initialize();
    notifyListeners();
  }
}
