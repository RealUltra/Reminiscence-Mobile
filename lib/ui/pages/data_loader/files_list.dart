import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/utils.dart';
import 'package:reminiscence/ui/components/message_box.dart';

import 'package:reminiscence/ui/pages/data_loader/file_card.dart';

class FilesList extends StatefulWidget {
  final Map<String, DateTime?> recentFiles;
  final void Function(String filePath) onClick;
  final Future<void> Function(String) onShare;
  final Future<void> Function(String) onDelete;

  const FilesList({
    super.key,
    required this.recentFiles,
    required this.onClick,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  @override
  Widget build(BuildContext context) {
    final filePaths = widget.recentFiles.keys.toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Loaded Files",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filePaths.length,
              itemBuilder: (BuildContext context, int index) {
                final filePath = filePaths[index];

                return Column(
                  key: ValueKey(filePaths[index]),

                  children: [
                    FutureBuilder(
                      future: isRemFileEncrypted(filePath),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<dynamic> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError ||
                            !snapshot.hasData) {
                          return Container();
                        }

                        final bool isEncrypted = snapshot.data;

                        return FileCard(
                          filePath: filePath,
                          lastOpened: widget.recentFiles[filePaths[index]],
                          isEncrypted: isEncrypted,
                          onClick: widget.onClick,
                          onShare: widget.onShare,
                          onDelete: onDelete,
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onDelete(String filePath) async {
    final mustDelete =
        await showDialog<bool?>(
          context: context,
          builder:
              (context) => MessageBox(
                title: "Delete?",
                body: Text(
                  "This file is about to be permanently deleted from your device.",
                  textAlign: TextAlign.center,
                ),
                actions: [
                  MessageBoxButton("Cancel", highlighted: false, value: false),
                  MessageBoxButton("Delete", value: true),
                ],
                actionsAxis: Axis.horizontal,
              ),
        ) ??
        false;

    if (!mustDelete) {
      return;
    }

    await widget.onDelete(filePath);
  }
}
