import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/backup_and_sync/export_settings_button.dart';
import 'package:reminiscence/ui/pages/settings/backup_and_sync/import_settings_button.dart';

class BackupAndSyncTile extends StatelessWidget {
  const BackupAndSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

      child: ExpansionTile(
        title: Text('Backup & Sync'),
        leading: Icon(Icons.sync),
        children: [
          const SizedBox(height: 8.0),
          ExportSettingsButton(),
          ImportSettingsButton(),
        ],
      ),
    );
  }
}
