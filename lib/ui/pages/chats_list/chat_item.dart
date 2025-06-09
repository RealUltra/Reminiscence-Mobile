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
              ? Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest // Light
              : Theme.of(context).colorScheme.surfaceContainer, // Dark
      child: ListTile(
        title: Text(
          chat.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle:
            (subtitle != null)
                ? Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
                : null,
        onTap: () {},
      ),
    );
  }
}
