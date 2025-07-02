import 'package:flutter/material.dart';
import 'package:reminiscence/ui/pages/settings/appearance/appearance_tile.dart';
import 'package:reminiscence/ui/pages/settings/backup_and_sync/backup_and_sync_tile.dart';
import 'package:reminiscence/ui/pages/settings/system_messages/system_messages_tile.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),

      child: ListView(
        children: [AppearanceTile(), SystemMessagesTile(), BackupAndSyncTile()],
      ),
    );
  }
}
