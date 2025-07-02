import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminiscence/ui/providers/pinned_messages_provider.dart';
import 'package:reminiscence/ui/providers/system_messages_provider.dart';

class ImportSettingsButton extends StatelessWidget {
  const ImportSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.upload),
      title: const Text("Import Settings"),
      subtitle: const Text("Import your system & pinned messages from a file."),
      onTap: () => loadData(context),
    );
  }

  Future<void> loadData(BuildContext context) async {
    final filePath = await loadFile();

    if (filePath == null) {
      return;
    }

    final fileContent = await File(filePath).readAsString();

    if (!context.mounted) {
      return;
    }

    Map<String, dynamic> data;

    try {
      data = jsonDecode(fileContent) as Map<String, dynamic>;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          content: Text(
            "Unrecognized file.",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      );

      return;
    }

    final integrationMode = await askForIntegrationMode(context);

    if (integrationMode == null || !context.mounted) {
      return;
    }

    transferData(context, data, integrationMode);
  }

  Future<String?> loadFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      final file = result.files.single;
      final filePath = file.path!;
      return filePath;
    }

    return null;
  }

  Future<String?> askForIntegrationMode(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                title: Text('Merge new settings with current settings.'),
                onTap: () => Navigator.pop(context, 'merge'),
              ),
              ListTile(
                title: Text('Overwrite current settings.'),
                onTap: () => Navigator.pop(context, 'overwrite'),
              ),
            ],
          ),
        );
      },
    );
  }

  void transferData(
    BuildContext context,
    Map<String, dynamic> data,
    String mode,
  ) {
    final systemMessagesProvider = Provider.of<SystemMessagesProvider>(
      context,
      listen: false,
    );

    final pinnedMessagesProvider = Provider.of<PinnedMessagesProvider>(
      context,
      listen: false,
    );

    // Handle the system messages
    if (data.containsKey("system_messages")) {
      List<String> newSystemMessages;

      try {
        newSystemMessages = data["system_messages"].cast<String>();
      } on TypeError catch (_) {
        newSystemMessages = [];
      }

      if (mode == "overwrite") {
        systemMessagesProvider.systemMessages = newSystemMessages;
      } else {
        final systemMessages = systemMessagesProvider.systemMessages;

        for (final message in newSystemMessages) {
          if (!systemMessages.contains(message)) {
            systemMessagesProvider.markAsSystem(message);
          }
        }
      }
    }

    // Handle the pinned messages
    if (data.containsKey("pinned_messages")) {
      List<String> newPinnedMessages;

      try {
        newPinnedMessages = data["pinned_messages"].cast<String>();
      } on TypeError catch (_) {
        newPinnedMessages = [];
      }

      if (mode == "overwrite") {
        pinnedMessagesProvider.pinnedMessages = newPinnedMessages;
      } else {
        final pinnedMessages = pinnedMessagesProvider.pinnedMessages;

        for (final messageId in newPinnedMessages) {
          if (!pinnedMessages.contains(messageId)) {
            pinnedMessagesProvider.pinMessage(messageId);
          }
        }
      }
    }

    // Show a message saying its done.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,

        content: Text(
          'Settings successfully updated!',

          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
