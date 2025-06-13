import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/message_dto.dart';

class MessageWidget extends StatelessWidget {
  final MessageDto message;
  final MessageDto? previousMessage;

  final senderNameExpiryTime = 5 * 60 * 1000; // 5 minutes in ms

  const MessageWidget({super.key, required this.message, this.previousMessage});

  @override
  Widget build(BuildContext context) {
    // The sender name is shown when:
    // 1. The previous message was by a different sender
    // 2. The previous message was over 5 minutes ago.

    final showSenderName =
        (previousMessage == null) ||
        (message.senderName != previousMessage!.senderName) ||
        ((message.sentAt - previousMessage!.sentAt) > senderNameExpiryTime);

    final topPadding =
        (previousMessage == null) ? 0.0 : (showSenderName ? 24.0 : 8.0);

    return Container(
      padding: EdgeInsets.fromLTRB(12, topPadding, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSenderName)
            Text(
              message.senderName,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

          if (showSenderName) const SizedBox(height: 6),

          Text(
            message.content,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
