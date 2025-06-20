import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/pinned_messages/message_widget.dart';

class MessagesList extends StatelessWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final List<MessageDto> pinnedMessages;
  final ScrollController scrollController;

  const MessagesList({
    super.key,
    required this.data,
    required this.chat,
    required this.pinnedMessages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: pinnedMessages.length,
      controller: scrollController,
      cacheExtent: 1000.0,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),

      itemBuilder: (BuildContext context, int index) {
        final message = pinnedMessages[index];

        return MessageWidget(
          data: data,
          userName: chat.userName,
          message: message,
        );
      },

      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }
}
