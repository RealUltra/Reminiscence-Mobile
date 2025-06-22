import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/data_storage/pinned_messages.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/components/message_card.dart';

class MessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final Future<void> Function() updatePinnedMessages;

  const MessagesList({
    super.key,
    required this.scrollController,
    required this.updatePinnedMessages,
  });

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ReminiscenceData>(context);
    final chat = Provider.of<ChatDto>(context);
    final pinnedMessages = Provider.of<List<MessageDto>>(context);

    return ListView.separated(
      itemCount: pinnedMessages.length,
      controller: scrollController,
      cacheExtent: 1000.0,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),

      itemBuilder: (BuildContext context, int index) {
        final message = pinnedMessages[index];

        return GestureDetector(
          onTap: () => onMessagePressed(context, message),
          onLongPressStart:
              (details) => showContextMenu(context, details, message),
          child: MessageCard(
            data: data,
            userName: chat.userName,
            message: message,
          ),
        );
      },

      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }

  void onMessagePressed(BuildContext context, MessageDto message) {
    final data = Provider.of<ReminiscenceData>(context, listen: false);
    final chat = Provider.of<ChatDto>(context, listen: false);

    Navigator.of(context).pushNamed(
      "/chat",
      arguments: ChatPageArgs(
        data: data,
        chat: chat,
        startIndex: message.index,
        disabled: true,
      ),
    );
  }

  Future<void> showContextMenu(
    BuildContext context,
    LongPressStartDetails details,
    MessageDto message,
  ) async {
    final result = await showMenu(
      context: context,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        MediaQuery.of(context).size.width - details.globalPosition.dx,
        MediaQuery.of(context).size.height - details.globalPosition.dy,
      ),

      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: "unpinMessage",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.push_pin, size: 16.0),
              SizedBox(width: 12),
              Text(
                "Unpin Message",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );

    if (result != "unpinMessage" || !context.mounted) {
      return;
    }

    await unpinMessage(message.id);

    await updatePinnedMessages();
  }
}
