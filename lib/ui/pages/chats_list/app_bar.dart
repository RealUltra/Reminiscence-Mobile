import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/chats_list/utils.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int numChats;

  const MyAppBar({super.key, required this.numChats});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("${formatNumber(numChats)} Chats Loaded"),

      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      titleSpacing: 24.0,
      actionsPadding: EdgeInsets.only(right: 8.0),
      titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Handle Settings
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
