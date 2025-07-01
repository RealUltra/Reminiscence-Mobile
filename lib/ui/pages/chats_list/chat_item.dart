import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/utils.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class ChatItem extends StatelessWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final int index;
  final int sortMode;

  const ChatItem({
    super.key,
    required this.data,
    required this.chat,
    required this.index,
    required this.sortMode,
  });

  @override
  Widget build(BuildContext context) {
    String? subtitle;

    switch (sortMode) {
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
        onTap: () => openChat(context),

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
      ),
    );
  }

  Future<void> openChat(BuildContext context) async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    sessionData.setChat(chat);

    if (context.mounted) {
      await Navigator.of(context).pushNamed("/chat");
    }
  }
}
