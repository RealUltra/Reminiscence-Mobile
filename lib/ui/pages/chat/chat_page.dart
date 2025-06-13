import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chat/app_bar.dart';
import 'package:reminiscence/ui/pages/chat/body.dart';

class ChatPage extends StatelessWidget {
  final ReminiscenceData data;
  final ChatDto chat;

  const ChatPage({super.key, required this.data, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(chat), body: Body(data: data, chat: chat));
  }
}
