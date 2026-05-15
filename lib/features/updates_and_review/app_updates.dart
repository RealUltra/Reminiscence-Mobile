import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:reminiscence/ui/components/message_box.dart';

Future<void> checkForFlexibleUpdate(BuildContext context) async {
  if (!Platform.isAndroid) {
    return;
  }

  try {
    final updateInfo = await InAppUpdate.checkForUpdate();

    if (updateInfo.installStatus == InstallStatus.downloaded) {
      if (context.mounted) {
        await showCompleteUpdateDialog(context);
      }
      return;
    }

    if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
      return;
    }

    if (!updateInfo.flexibleUpdateAllowed) {
      return;
    }

    final result = await InAppUpdate.startFlexibleUpdate();

    if (result != AppUpdateResult.success || !context.mounted) {
      return;
    }

    await showCompleteUpdateDialog(context);
  } catch (_) {}
}

Future<void> showCompleteUpdateDialog(BuildContext context) async {
  if (!context.mounted) {
    return;
  }

  final mustRestart =
      await showDialog<bool?>(
        context: context,
        builder: (context) {
          return MessageBox(
            title: "Update Ready",
            body: Text(
              "A new version has been downloaded. Restart to apply it.",
              textAlign: TextAlign.center,
            ),
            actions: [
              MessageBoxButton("Later", highlighted: false, value: false),
              MessageBoxButton("Restart", value: true),
            ],
            actionsAxis: Axis.horizontal,
          );
        },
      ) ??
      false;

  if (!mustRestart) {
    return;
  }

  try {
    await InAppUpdate.completeFlexibleUpdate();
  } catch (_) {}
}
