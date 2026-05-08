import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_storage/notifications.dart';
import 'package:reminiscence/features/notifications/reminder_notifications.dart';
import 'package:reminiscence/ui/pages/data_loader/dyi_tutorial/dyi_tutorial_dialog.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Reminiscence"),

      scrolledUnderElevation: 0.0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,

      actions: [
        IconButton(
          onPressed: () => showDownloadPopup(context),
          icon: Icon(Icons.help_outline, size: 30),
        ),
      ],

      actionsPadding: EdgeInsets.only(right: 8),

      titleTextStyle: Theme.of(
        context,
      ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),

      titleSpacing: 24.0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Future<void> showDownloadPopup(BuildContext context) async {
    await markDownloadPopupViewed();
    await refreshReminderNotifications();

    if (context.mounted) {
      await showDialog(context: context, builder: (_) => DyiTutorialDialog());
    }
  }
}
