import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/backup_and_sync/export_settings_button.dart';
import 'package:reminiscence/ui/pages/settings/backup_and_sync/import_settings_button.dart';

class BackupAndSyncTile extends StatelessWidget {
  const BackupAndSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('Backup & Sync'),
      leading: Icon(Icons.sync),
      children: [ExportSettingsButton(), ImportSettingsButton()],
    );
  }
}
