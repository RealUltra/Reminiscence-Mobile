import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/components/value_controller.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueController<String?>? jumpController;

  const MyAppBar({super.key, this.jumpController});

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final chat = sessionData.chat!;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      scrolledUnderElevation: 0.0,

      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => goBack(context),
      ),

      title: GestureDetector(
        onTap: () {
          // Display user info
        },

        child: Text(
          chat.title,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.search, size: 22.0),
          onPressed: () => goToPage(context, "/search"),
        ),

        IconButton(
          icon: Icon(Icons.push_pin, size: 22.0),
          onPressed: () => goToPage(context, "/pins"),
        ),

        IconButton(
          icon: Icon(Icons.bar_chart, size: 22.0),
          onPressed: () => goToPage(context, "/graph"),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  void goBack(BuildContext context) {
    final pageController = Provider.of<SelectionController<int>?>(
      context,
      listen: false,
    );

    if (pageController == null) {
      Navigator.of(context).pop();
      return;
    }

    pageController.selected = 0;
  }

  Future<void> goToPage(BuildContext context, String route) async {
    final disabled = Provider.of<bool>(context, listen: false);

    if (!disabled) {
      final messageId = await Navigator.of(context).pushNamed(route) as String?;

      if (messageId != null && jumpController != null) {
        jumpController!.value = messageId;
      }

      return;
    }

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
