import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';
import 'package:reminiscence/ui/pages/chat/message_reader.dart';
import 'package:reminiscence/ui/pages/chat/message_widget.dart';

// ignore: must_be_immutable
class MessagesList extends StatelessWidget {
  final ChatDto chat;
  final MessageReader messageReader;

  const MessagesList({
    super.key,
    required this.chat,
    required this.messageReader,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chat.messageCount,
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 16),

      itemBuilder: (BuildContext context, int index) {
        // Check if the message has already been loaded
        final message = messageReader.cachedMessageAt(index);
        final previousMessage = messageReader.cachedMessageAt(index + 1);

        if (message != null && previousMessage != null) {
          return MessageWidget(
            message: message,
            previousMessage: previousMessage,
          );
        }

        // Load the message if it is not already cached.
        return FutureBuilder<List<MessageDto?>>(
          future:
              (() async {
                final message = await messageReader.messageAt(index);
                final previousMessage = await messageReader.messageAt(
                  index + 1,
                );
                return [message, previousMessage];
              })(),

          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            final emptyWidget = const SizedBox(height: 12);
            final errorWidget = Text(
              "Error at index $index: ${snapshot.error}",
              style: TextStyle(color: Colors.red),
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return emptyWidget;
            } else if (snapshot.hasError) {
              return errorWidget;
            } else if (!snapshot.hasData) {
              return emptyWidget;
            } else {
              final messages = snapshot.data;

              if (messages[0] == null) return emptyWidget;

              return MessageWidget(
                message: messages[0],
                previousMessage: messages[1],
              );
            }
          },
        );
      },
    );
  }
}
