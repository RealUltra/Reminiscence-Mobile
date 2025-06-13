import 'package:flutter/material.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatDto chat;

  const MyAppBar(this.chat, {super.key});

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
          onPressed: () {
            // List pinned messages
          },
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
}
