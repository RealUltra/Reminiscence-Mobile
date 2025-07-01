import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/chat_page_args.dart';
import 'package:reminiscence/ui/components/message_card.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class MessagesList extends StatelessWidget {
  final ScrollController scrollController;
  final List<MessageDto> messages;

  const MessagesList({
    super.key,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final data = sessionData.data!;
    final chat = sessionData.chat!;

    return ListView.separated(
      itemCount: messages.length,
      controller: scrollController,
      cacheExtent: 1000.0,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),

      itemBuilder: (BuildContext context, int index) {
        final message = messages[index];

        return GestureDetector(
          key: ValueKey(message.id),

          onTap: () => onMessagePressed(context, message),

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

  Future<void> onMessagePressed(
    BuildContext context,
    MessageDto message,
  ) async {
    final result =
        await Navigator.of(context).pushNamed(
              "/chat",
              arguments: ChatPageArgs(
                initialMessageId: message.id,
                disabled: true,
              ),
            )
            as String?;

    if (result == null || !context.mounted) {
      return;
    }

    Navigator.of(context).pop(message.id);
  }
}
