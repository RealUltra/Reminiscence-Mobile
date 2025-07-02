import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/providers/pinned_messages_provider.dart';
import 'package:reminiscence/ui/providers/system_messages_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportSettingsButton extends StatelessWidget {
  const ExportSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text("Export Settings"),
      subtitle: const Text("Export your system & pinned messages to a file."),
      onTap: () => export(context),
    );
  }

  Future<void> export(BuildContext context) async {
    final payload = getPayload(context);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/settings.json');
    await file.writeAsString(payload);

    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );

    if (result.status != ShareResultStatus.success || !context.mounted) {
      return;
    }

    // Show a message saying its done.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,

        content: Text(
          'Settings successfully exported!',

          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  String getPayload(BuildContext context) {
    final systemMessagesProvider = Provider.of<SystemMessagesProvider>(
      context,
      listen: false,
    );
    final pinnedMessagesProvider = Provider.of<PinnedMessagesProvider>(
      context,
      listen: false,
    );

    final systemMessages = systemMessagesProvider.systemMessages;
    final pinnedMessages = pinnedMessagesProvider.pinnedMessages;

    final payload = {
      "system_messages": systemMessages,
      "pinned_messages": pinnedMessages,
    };

    return jsonEncode(payload);
  }
}
