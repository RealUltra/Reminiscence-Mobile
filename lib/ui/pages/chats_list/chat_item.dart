import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/utils.dart';

class ChatItem extends StatelessWidget {
  final int index;
  final ChatDto chat;
  final int sortByMode;

  const ChatItem({
    super.key,
    required this.index,
    required this.chat,
    required this.sortByMode,
  });

  @override
  Widget build(BuildContext context) {
    String? subtitle;

    switch (sortByMode) {
      case 1:
        subtitle = "${formatNumber(chat.messageCount)} messages";
        break;
      case 2:
        subtitle = DateFormat(
          'dd/MM/yyyy HH:mm:ss',
        ).format(chat.lastMessageSentAt);
        break;
    }

    return Container(
      color:
          index % 2 == 0
              ? const Color(0xFF2E2E2E) // Light
              : const Color(0xFF1E1E1E), // Dark
      child: ListTile(
        title: Text(chat.title, style: const TextStyle(color: Colors.white)),
        subtitle:
            (subtitle != null)
                ? Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey), // Warm Orange
                )
                : null,
        onTap: () {},
      ),
    );
  }
}
