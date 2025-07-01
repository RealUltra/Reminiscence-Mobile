import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/chat_item.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class ChatsList extends StatelessWidget {
  final List<ChatDto> chats;
  final ScrollController? scrollController;
  final int sortMode;

  const ChatsList({
    super.key,
    required this.chats,
    required this.scrollController,
    this.sortMode = 0,
  });

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final data = sessionData.data!;

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
              key: ValueKey(chat.id),
              data: data,
              chat: chat,
              index: index,
              sortMode: sortMode,
            );
          },
        ),
      ),
    );
  }
}
