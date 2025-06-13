import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/chat_item.dart';

class ChatsList extends StatelessWidget {
  final ReminiscenceData data;
  final List<ChatDto> chats;
  final ScrollController? scrollController;
  final int sortByMode;

  const ChatsList({
    super.key,
    required this.data,
    required this.chats,
    required this.scrollController,
    this.sortByMode = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color:
            chats.length % 2 == 0
                ? Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest // Light
                : Theme.of(context).colorScheme.surface, // Dark

        child: ListView.builder(
          padding: EdgeInsets.zero,
          controller: scrollController,
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatItem(
              data: data,
              chat: chat,
              index: index,
              sortByMode: sortByMode,
            );
          },
        ),
      ),
    );
  }
}
