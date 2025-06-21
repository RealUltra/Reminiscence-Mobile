import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chat/app_bar.dart';
import 'package:reminiscence/ui/pages/chat/body.dart';

class ChatPage extends StatelessWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final int startIndex;
  final bool disabled;

  const ChatPage({
    super.key,
    required this.data,
    required this.chat,
    required this.startIndex,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(data: data, chat: chat, disabled: disabled),
      body: Body(
        data: data,
        chat: chat,
        startIndex: startIndex,
        disabled: disabled,
      ),
    );
  }
}
