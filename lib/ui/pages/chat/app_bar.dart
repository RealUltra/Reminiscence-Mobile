import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final chat = sessionData.chat!;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      scrolledUnderElevation: 0.0,

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
          onPressed: () => goToGraph(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<void> goToPins(BuildContext context) async {
    final disabled = Provider.of<bool>(context, listen: false);

    if (!disabled) {
      // List pinned messages
      Navigator.of(context).pushNamed("/pins");
    } else {
      // Show message saying that you can't go to pins right now.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Jump to the message to use this feature!",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> goToGraph(BuildContext context) async {
    final disabled = Provider.of<bool>(context, listen: false);

    if (!disabled) {
      // List pinned messages
      Navigator.of(context).pushNamed("/graph");
    } else {
      // Show message saying that you can't go to pins right now.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Jump to the message to use this feature!",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
