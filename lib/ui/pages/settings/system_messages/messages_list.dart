import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/system_messages/message_card.dart';

class MessagesList extends StatelessWidget {
  final List<String> messages;

  const MessagesList({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 16.0),

        child: Text(
          "No system messages marked.",

          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),

      child: Column(
        spacing: 0.0,

        children: List.generate(messages.length, (index) {
          final message = messages[index];
          return MessageCard(message: message);
        }),
      ),
    );
  }
}
