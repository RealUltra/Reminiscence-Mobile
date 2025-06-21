import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/reminiscence_data.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/pinned_messages/pinned_messages_page_args.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ReminiscenceData data;
  final ChatDto chat;
  final bool disabled;

  const MyAppBar({
    super.key,
    required this.data,
    required this.chat,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: GestureDetector(
        onTap: () {
          // Display user info
        },
        child: Row(
          children: [
            Flexible(
              child: Text(
                chat.title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color:
                  Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant, // Adjust the arrow color
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, size: 22.0),
          onPressed: () async {
            // Open search page
          },
        ),
        IconButton(
          icon: Icon(Icons.push_pin, size: 22.0),
          onPressed: () => goToPins(context),
        ),
        IconButton(
          icon: Icon(Icons.bar_chart, size: 22.0),
          onPressed: () {
            // Show graph
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<void> goToPins(BuildContext context) async {
    if (!disabled) {
      // List pinned messages
      Navigator.of(context).pushNamed(
        "/pins",
        arguments: PinnedMessagesPageArgs(data: data, chat: chat),
      );
    } else {
      // Show message saying that you can't go to pins right now.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Jump to the message to use this feature!"),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
