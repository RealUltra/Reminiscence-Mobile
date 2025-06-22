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
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      width: 100.0,

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16.0),
      ),

      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
