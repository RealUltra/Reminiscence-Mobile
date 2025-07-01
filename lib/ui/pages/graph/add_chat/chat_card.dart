import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class ChatCard extends StatelessWidget {
  final ChatDto chat;
  final bool checked;
  final VoidCallback? onClick;

  const ChatCard(this.chat, {super.key, required this.checked, this.onClick});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(chat.id),
      minTileHeight: 0.0,

      title: Text(chat.title, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(
        "${chat.messageCount} messages",
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),

      trailing: checked ? Icon(Icons.check, size: 16.0) : null,

      onTap: onClick,
    );
  }
}
