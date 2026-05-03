import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_storage/notifications.dart';
import 'package:reminiscence/features/notifications/reminder_notifications.dart';
import 'package:reminiscence/ui/pages/data_loader/download_popup.dart';

class NoFilesWidget extends StatelessWidget {
  const NoFilesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.folder_outlined,
          size: 90,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Text(
          "Use the \"Load New File\" button\nto load your instagram data\nand get started!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => showDownloadPopup(context),
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
          ),

          child: Text(
            "Need help downloading your instagram data?\nClick here.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> showDownloadPopup(BuildContext context) async {
    await markDownloadPopupViewed();
    await refreshReminderNotifications();

    if (context.mounted) {
      await showDialog(context: context, builder: (_) => DownloadPopup());
    }
  }
}
