import 'package:flutter/material.dart';

class ChartBadge extends StatelessWidget {
  // Chat name if isChat == true, otherwise it will be the participant's name.
  final String title;

  final bool isChat;

  // null if isChat == true, otherwise it will be the chat name.
  final String? chatTitle;

  const ChartBadge({
    super.key,
    required this.title,
    this.isChat = true,
    this.chatTitle,
  });

  @override
  Widget build(BuildContext context) {
    String text = title;

    if (!isChat && chatTitle != null) {
      text += " ($chatTitle)";
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8.0,

        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              overflow: TextOverflow.ellipsis,
              height: 1.0,
            ),
          ),

          const Icon(Icons.close, size: 16.0),
        ],
      ),
    );
  }
}
