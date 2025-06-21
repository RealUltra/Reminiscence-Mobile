import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/pages/chats_list/utils.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final numChats = Provider.of<List<ChatDto>>(context).length;

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
