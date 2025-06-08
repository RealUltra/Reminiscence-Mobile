import 'package:flutter/material.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/chat_item.dart';

class ChatsList extends StatelessWidget {
  final List<ChatDto> chats;
  final ScrollController? scrollController;
  final int sortByMode;

  const ChatsList({
    super.key,
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
                ? const Color(0xFF2E2E2E) // Light
                : const Color(0xFF1E1E1E), // Dark

        child: ListView.builder(
          padding: EdgeInsets.zero,
          controller: scrollController,
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatItem(index: index, chat: chat, sortByMode: sortByMode);
          },
        ),
      ),
    );
  }
}
