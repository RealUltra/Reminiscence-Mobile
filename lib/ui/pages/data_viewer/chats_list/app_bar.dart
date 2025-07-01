import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/pages/data_viewer/chats_list/utils.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionData = Provider.of<SessionData>(context);
    final numChats = sessionData.chats!.length;

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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
